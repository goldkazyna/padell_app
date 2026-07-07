import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/coach_schedule.dart';
import '../services/coach_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_back_button.dart';

/// Расписание тренера (просмотр). Прокручиваемая лента дат (прошлое/будущее)
/// + таймлайн дня. Слоты как в расписании кортов: зелёный «Свободно»,
/// синий — занято (клиент + корт).
class CoachScheduleScreen extends StatefulWidget {
  const CoachScheduleScreen({super.key});

  @override
  State<CoachScheduleScreen> createState() => _CoachScheduleScreenState();
}

class _CoachScheduleScreenState extends State<CoachScheduleScreen> {
  static const _blue = Color(0xFF3B82F6);
  static const int _pastDays = 30;
  static const int _futureDays = 60;
  static const double _chipExtent = 62; // 56 ширина + 3+3 отступы

  final ScrollController _dayScroll = ScrollController();
  final List<String> _days = [];
  final Map<String, double> _hoursByDate = {};
  String _selectedDate = '';
  late final String _today;

  CoachDaySchedule? _data;
  bool _loading = true;
  String? _error;
  bool _scrolledToInitial = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    _today = _fmtDate(base);
    _selectedDate = _today;
    for (int i = -_pastDays; i <= _futureDays; i++) {
      _days.add(_fmtDate(base.add(Duration(days: i))));
    }
    _load();
    _loadHoursRange();
  }

  /// Разом грузим часы занятости по всему диапазону — чтобы полоски в ленте
  /// были заполнены сразу, а не только после тапа/скролла.
  Future<void> _loadHoursRange() async {
    try {
      final hours = await context
          .read<CoachService>()
          .getHoursRange(from: _days.first, to: _days.last);
      if (!mounted) return;
      setState(() => _hoursByDate.addAll(hours));
    } catch (_) {
      // тихо — полоски просто останутся пустыми
    }
  }

  @override
  void dispose() {
    _dayScroll.dispose();
    super.dispose();
  }

  Future<void> _load({String? date}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (date != null) _selectedDate = date;
    });
    try {
      final data =
          await context.read<CoachService>().getSchedule(date: _selectedDate);
      if (!mounted) return;
      // Накапливаем часы занятости по датам из недели ответа.
      for (final w in data.week) {
        _hoursByDate[w.date] = w.hours;
      }
      setState(() {
        _data = data;
        _loading = false;
      });
      if (!_scrolledToInitial) {
        _scrolledToInitial = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected());
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _scrollToSelected() {
    if (!_dayScroll.hasClients) return;
    final idx = _days.indexOf(_selectedDate);
    if (idx < 0) return;
    final w = MediaQuery.of(context).size.width;
    final target = (idx * _chipExtent) - (w / 2) + (_chipExtent / 2);
    _dayScroll.jumpTo(target.clamp(0.0, _dayScroll.position.maxScrollExtent));
  }

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  String _fmt(String date, String pattern) {
    final dt = DateTime.tryParse(date);
    if (dt == null) return '';
    try {
      final lang = Localizations.localeOf(context).languageCode;
      return DateFormat(pattern, lang).format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _data?.clubName ?? l.coachScheduleButton,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          l.coachScheduleButton,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Лента дат (скролл в прошлое/будущее).
            SizedBox(
              height: 82,
              child: ListView.builder(
                controller: _dayScroll,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                itemCount: _days.length,
                itemBuilder: (_, i) => _dayChip(_days[i]),
              ),
            ),
            Expanded(child: _buildBody(l)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l) {
    if (_loading && _data == null) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.accent));
    }
    if (_error != null && _data == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.error,
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => _load(),
              child:
                  Text(l.retry, style: const TextStyle(color: AppTheme.accent)),
            ),
          ],
        ),
      );
    }
    final slots = _data?.slots ?? const [];
    if (slots.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => _load(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 80, 32, 0),
              child: Column(
                children: [
                  const Icon(Icons.event_busy_outlined,
                      size: 44, color: AppTheme.textDim),
                  const SizedBox(height: 12),
                  Text(
                    l.coachDayOff,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        itemCount: slots.length,
        itemBuilder: (_, i) => _slotTile(slots[i], l),
      ),
    );
  }

  Widget _slotTile(CoachSlot s, AppLocalizations l) {
    final booking = s.booking;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              s.time,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF52525B)),
            ),
          ),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 46),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _slotBg(s.status),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _slotBorder(s.status), width: 0.5),
              ),
              alignment: Alignment.center,
              child: _slotContent(s, booking, l),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slotContent(CoachSlot s, CoachSlotBooking? booking, AppLocalizations l) {
    if (s.status == 'free') {
      return Text(
        l.coachSlotFree,
        style: const TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.accent),
      );
    }
    if (s.status == 'blocked') {
      return Text(
        l.coachSlotBlocked,
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF3F3F46)),
      );
    }
    final client = (booking?.client ?? '').isNotEmpty
        ? booking!.client!
        : l.coachSlotBooked;
    final court = booking?.court;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          client,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: _blue),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if ((court ?? '').isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            court!,
            style: TextStyle(fontSize: 11, color: _blue.withValues(alpha: 0.75)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _dayChip(String date) {
    final active = date == _selectedDate;
    final isToday = date == _today;
    final hours = _hoursByDate[date] ?? 0;
    final frac = (hours / 6).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: () => _load(date: date),
      child: Container(
        width: 56,
        margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.accent : AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday && !active
                ? AppTheme.accent
                : (active ? AppTheme.accent : const Color(0xFF2A2A2A)),
            width: active ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _fmt(date, 'EEE'),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active ? Colors.black : const Color(0xFF52525B),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _fmt(date, 'd'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: active
                    ? Colors.black
                    : (isToday ? AppTheme.accent : const Color(0xFFD4D4D8)),
              ),
            ),
            Text(
              _fmt(date, 'MMM'),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: active
                    ? Colors.black.withValues(alpha: 0.6)
                    : const Color(0xFF52525B),
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: active
                    ? Colors.black.withValues(alpha: 0.12)
                    : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: frac,
                  child: Container(
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.black.withValues(alpha: 0.45)
                          : AppTheme.orange,
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

  Color _slotBg(String s) {
    switch (s) {
      case 'free':
        return AppTheme.accent.withAlpha(15);
      case 'booked':
        return _blue.withAlpha(18);
      default:
        return const Color(0xFF71717A).withAlpha(12);
    }
  }

  Color _slotBorder(String s) {
    switch (s) {
      case 'free':
        return AppTheme.accent.withAlpha(40);
      case 'booked':
        return _blue.withAlpha(35);
      default:
        return const Color(0xFF71717A).withAlpha(25);
    }
  }
}
