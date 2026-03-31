import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late List<Map<String, String>> _weekDays;
  int _selectedCourtIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedDate = _formatDate(DateTime.now());
    _weekDays = _generateWeek(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourtProvider>().loadSchedule(widget.club.id, _selectedDate);
    });
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<Map<String, String>> _generateWeek(DateTime from) {
    final monday = from.subtract(Duration(days: from.weekday - 1));
    const dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    const monthNames = ['', 'янв', 'фев', 'мар', 'апр', 'май', 'июн', 'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'];
    return List.generate(7, (i) {
      final d = monday.add(Duration(days: i));
      return {
        'date': _formatDate(d),
        'dayName': dayNames[i],
        'dayNum': d.day.toString(),
        'month': monthNames[d.month],
      };
    });
  }

  void _changeWeek(int delta) {
    final current = DateTime.parse(_weekDays[0]['date']!);
    final newWeek = current.add(Duration(days: 7 * delta));
    setState(() {
      _weekDays = _generateWeek(newWeek);
      _selectedDate = _weekDays[0]['date']!;
    });
    context.read<CourtProvider>().loadSchedule(widget.club.id, _selectedDate);
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
            Text(widget.club.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            if (widget.club.address != null)
              Text(widget.club.address!, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Неделя
          _buildWeekSelector(),
          const SizedBox(height: 12),

          // Контент
          Expanded(
            child: Consumer<CourtProvider>(
              builder: (context, provider, _) {
                if (provider.isScheduleLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accent));
                }
                if (provider.scheduleError != null) {
                  return Center(
                    child: Text(provider.scheduleError!, style: const TextStyle(color: AppTheme.textSecondary)),
                  );
                }
                if (provider.scheduleData == null) {
                  return const SizedBox.shrink();
                }

                final courts = provider.scheduleData!['courts'] as List<dynamic>? ?? [];
                if (courts.isEmpty) {
                  return const Center(
                    child: Text('Нет доступных кортов', style: TextStyle(color: AppTheme.textSecondary)),
                  );
                }

                return Column(
                  children: [
                    // Табы кортов
                    _buildCourtTabs(courts),
                    const SizedBox(height: 8),
                    // Слоты
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

  Widget _buildWeekSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _changeWeek(-1),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
              ),
              child: const Icon(Icons.chevron_left, color: AppTheme.textSecondary, size: 20),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _weekDays.length,
                separatorBuilder: (_, __) => const SizedBox(width: 4),
                itemBuilder: (context, index) {
                  final day = _weekDays[index];
                  final isSelected = day['date'] == _selectedDate;
                  final isToday = day['date'] == _formatDate(DateTime.now());
                  return GestureDetector(
                    onTap: () => _selectDate(day['date']!),
                    child: Container(
                      width: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.accent : AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isToday && !isSelected ? AppTheme.accent : (isSelected ? AppTheme.accent : const Color(0xFF2A2A2A)),
                          width: 0.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            day['dayName']!,
                            style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.black : const Color(0xFF52525B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            day['dayNum']!,
                            style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.black : (isToday ? AppTheme.accent : AppTheme.textSecondary),
                            ),
                          ),
                          Text(
                            day['month']!,
                            style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.black.withAlpha(150) : const Color(0xFF52525B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _changeWeek(1),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
              ),
              child: const Icon(Icons.chevron_right, color: AppTheme.textSecondary, size: 20),
            ),
          ),
        ],
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
                  color: isActive ? const Color(0xFF3B82F6) : AppTheme.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF2A2A2A),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  court['name'] as String? ?? 'Корт ${i + 1}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700,
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
    final coaches = (context.read<CourtProvider>().scheduleData?['coaches'] as List<dynamic>?) ?? [];

    if (slots.isEmpty) {
      return const Center(
        child: Text('Нет слотов на этот день', style: TextStyle(color: AppTheme.textSecondary)),
      );
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
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  time,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF71717A)),
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
                    height: 48,
                    decoration: BoxDecoration(
                      color: _slotColor(status),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _slotBorderColor(status), width: 0.5),
                    ),
                    child: Center(
                      child: status == 'free'
                          ? Text(
                              '${_formatPrice(price ?? 0)} ₸',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent),
                            )
                          : Text(
                              status == 'booked' ? 'Занято' : 'Заблок.',
                              style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600,
                                color: status == 'booked' ? const Color(0xFF3B82F6) : const Color(0xFF52525B),
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

  Color _slotColor(String status) {
    switch (status) {
      case 'free': return AppTheme.accent.withAlpha(15);
      case 'booked': return const Color(0xFF3B82F6).withAlpha(20);
      default: return const Color(0xFF71717A).withAlpha(15);
    }
  }

  Color _slotBorderColor(String status) {
    switch (status) {
      case 'free': return AppTheme.accent.withAlpha(40);
      case 'booked': return const Color(0xFF3B82F6).withAlpha(40);
      default: return const Color(0xFF71717A).withAlpha(30);
    }
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]} ',
    );
  }
}
