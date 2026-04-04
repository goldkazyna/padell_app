import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/club.dart';
import '../providers/court_provider.dart';
import '../theme/app_theme.dart';
import 'court_booking_screen.dart';

class CourtScheduleScreen extends StatefulWidget {
  final Club club;

  const CourtScheduleScreen({super.key, required this.club});

  @override
  State<CourtScheduleScreen> createState() => _CourtScheduleScreenState();
}

class _CourtScheduleScreenState extends State<CourtScheduleScreen> {
  late String _selectedDate;
  List<_DayInfo>? _weekDays;
  int _selectedCourtIndex = 0;
  Map<String, int> _occupancy = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = _fmt(now);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _ensureWeekBuilt(AppLocalizations l10n) {
    if (!_initialized) {
      _weekDays = _buildWeek(DateTime.now(), _localizedDayNames(l10n), _localizedMonthShorts(l10n));
      _initialized = true;
    }
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<String> _localizedDayNames(AppLocalizations l10n) => [
    l10n.dayMon, l10n.dayTue, l10n.dayWed, l10n.dayThu, l10n.dayFri, l10n.daySat, l10n.daySun,
  ];

  List<String> _localizedMonthShorts(AppLocalizations l10n) => [
    '', l10n.monthShortJan, l10n.monthShortFeb, l10n.monthShortMar, l10n.monthShortApr,
    l10n.monthShortMay, l10n.monthShortJun, l10n.monthShortJul, l10n.monthShortAug,
    l10n.monthShortSep, l10n.monthShortOct, l10n.monthShortNov, l10n.monthShortDec,
  ];

  List<_DayInfo> _buildWeek(DateTime from, [List<String>? dn, List<String>? mn]) {
    final monday = from.subtract(Duration(days: from.weekday - 1));
    final dayNames = dn ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = mn ?? ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return _DayInfo(
        date: _fmt(d),
        dayName: dayNames[i],
        dayNum: d.day.toString(),
        month: monthNames[d.month],
        isToday: _fmt(d) == _fmt(DateTime.now()),
      );
    });
  }

  void _loadData() {
    context.read<CourtProvider>().loadSchedule(widget.club.id, _selectedDate);
    _loadOccupancy();
  }

  Future<void> _loadOccupancy() async {
    try {
      final provider = context.read<CourtProvider>();
      final response = await provider.courtService.getWeekOccupancy(
        widget.club.id,
        _weekDays![0].date,
      );
      if (response['success'] == true && mounted) {
        final occ = response['occupancy'] as Map<String, dynamic>? ?? {};
        setState(() {
          _occupancy = occ.map((k, v) => MapEntry(k, (v as num).toInt()));
        });
      }
    } catch (_) {}
  }

  void _changeWeek(int delta) {
    final l10n = AppLocalizations.of(context)!;
    final current = DateTime.parse(_weekDays![0].date);
    final newStart = current.add(Duration(days: 7 * delta));
    setState(() {
      _weekDays = _buildWeek(newStart, _localizedDayNames(l10n), _localizedMonthShorts(l10n));
      _selectedDate = _weekDays![0].date;
      _selectedCourtIndex = 0;
      _occupancy = {};
    });
    _loadData();
  }

  void _selectDate(String date) {
    setState(() {
      _selectedDate = date;
      _selectedCourtIndex = 0;
    });
    context.read<CourtProvider>().loadSchedule(widget.club.id, date);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _ensureWeekBuilt(l10n);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.club.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            if (widget.club.address != null)
              Text(widget.club.address!,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDayPicker(),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<CourtProvider>(
              builder: (context, provider, _) {
                if (provider.isScheduleLoading) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppTheme.accent));
                }
                if (provider.scheduleError != null) {
                  return Center(
                      child: Text(provider.scheduleError!,
                          style: const TextStyle(color: AppTheme.textSecondary)));
                }
                if (provider.scheduleData == null) return const SizedBox.shrink();

                final courts =
                    provider.scheduleData!['courts'] as List<dynamic>? ?? [];
                if (courts.isEmpty) {
                  return Center(
                      child: Text(l10n.noCourtsAvailable,
                          style: const TextStyle(color: AppTheme.textSecondary)));
                }

                return Column(
                  children: [
                    _buildCourtTabs(courts),
                    const SizedBox(height: 8),
                    Expanded(child: _buildSlots(courts)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPicker() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < -200) {
            _changeWeek(1); // свайп влево → следующая неделя
          } else if (details.primaryVelocity! > 200) {
            _changeWeek(-1); // свайп вправо → предыдущая неделя
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        child: SizedBox(
          height: 76,
          child: Row(
            children: _weekDays!.map((day) {
              final isSelected = day.date == _selectedDate;
              final occ = _occupancy[day.date] ?? 0;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _DayChip(
                    day: day,
                    isSelected: isSelected,
                    occupancy: occ,
                    onTap: () => _selectDate(day.date),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCourtTabs(List<dynamic> courts) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(courts.length, (i) {
          final court = courts[i] as Map<String, dynamic>;
          final isActive = i == _selectedCourtIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCourtIndex = i),
              child: Container(
                margin: EdgeInsets.only(left: i > 0 ? 6 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF3B82F6)
                      : AppTheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF2A2A2A),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  court['name'] as String? ?? AppLocalizations.of(context)!.courtDefault(i + 1),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSlots(List<dynamic> courts) {
    if (_selectedCourtIndex >= courts.length) return const SizedBox.shrink();

    final court = courts[_selectedCourtIndex] as Map<String, dynamic>;
    final courtId = court['id'] as int;
    final slots = court['slots'] as List<dynamic>? ?? [];
    final coaches =
        (context.read<CourtProvider>().scheduleData?['coaches'] as List<dynamic>?) ?? [];

    if (slots.isEmpty) {
      return Center(
          child: Text(AppLocalizations.of(context)!.noSlotsForDay,
              style: const TextStyle(color: AppTheme.textSecondary)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index] as Map<String, dynamic>;
        final time = slot['time'] as String? ?? '';
        final status = slot['status'] as String? ?? 'free';
        final price = (slot['price'] as num?)?.toDouble();

        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                child: Text(
                  time,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF52525B)),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: status == 'free'
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourtBookingScreen(
                                club: widget.club,
                                courtId: courtId,
                                courtName: court['name'] as String? ?? '',
                                date: _selectedDate,
                                startTime: time,
                                price: price ?? 0,
                                coaches: coaches,
                                slots: slots,
                                slotIndex: index,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: _slotBg(status),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _slotBorder(status), width: 0.5),
                    ),
                    child: Center(
                      child: status == 'free'
                          ? Text(
                              '${_fmtPrice(price ?? 0)} ₸',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.accent),
                            )
                          : Text(
                              status == 'booked' ? AppLocalizations.of(context)!.occupied : AppLocalizations.of(context)!.blocked,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: status == 'booked'
                                    ? const Color(0xFF3B82F6)
                                    : const Color(0xFF3F3F46),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _slotBg(String s) {
    switch (s) {
      case 'free':
        return AppTheme.accent.withAlpha(15);
      case 'booked':
        return const Color(0xFF3B82F6).withAlpha(18);
      default:
        return const Color(0xFF71717A).withAlpha(12);
    }
  }

  Color _slotBorder(String s) {
    switch (s) {
      case 'free':
        return AppTheme.accent.withAlpha(40);
      case 'booked':
        return const Color(0xFF3B82F6).withAlpha(35);
      default:
        return const Color(0xFF71717A).withAlpha(25);
    }
  }

  String _fmtPrice(double p) {
    return p.toInt().toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');
  }
}

// --- Модели и виджеты ---

class _DayInfo {
  final String date, dayName, dayNum, month;
  final bool isToday;
  _DayInfo(
      {required this.date,
      required this.dayName,
      required this.dayNum,
      required this.month,
      required this.isToday});
}

class _DayChip extends StatelessWidget {
  final _DayInfo day;
  final bool isSelected;
  final int occupancy;
  final VoidCallback onTap;

  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.occupancy,
    required this.onTap,
  });

  Color _occColor(int occ) {
    if (occ >= 80) return const Color(0xFFEF4444);
    if (occ >= 40) return const Color(0xFFFB923C);
    return const Color(0xFF22C55E);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: day.isToday && !isSelected
                ? AppTheme.accent
                : (isSelected ? AppTheme.accent : const Color(0xFF2A2A2A)),
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              day.dayName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.black : const Color(0xFF52525B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              day.dayNum,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isSelected
                    ? Colors.black
                    : (day.isToday ? AppTheme.accent : const Color(0xFFD4D4D8)),
              ),
            ),
            Text(
              day.month,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.black.withAlpha(150)
                    : const Color(0xFF52525B),
              ),
            ),
            const SizedBox(height: 4),
            // Прогресс-бар загруженности
            Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black.withAlpha(30)
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: occupancy / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.black.withAlpha(100)
                          : _occColor(occupancy),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
