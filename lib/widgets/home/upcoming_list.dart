import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../../utils/tournament_type_l10n.dart';
import '../tournaments/club_logo.dart';

/// «Скоро» V2: горизонтальная лента дней (14) + список турниров выбранного дня.
class UpcomingList extends StatefulWidget {
  final List<Tournament> tournaments;
  final Function(Tournament)? onTap;

  const UpcomingList({
    super.key,
    required this.tournaments,
    this.onTap,
  });

  @override
  State<UpcomingList> createState() => _UpcomingListState();
}

class _UpcomingListState extends State<UpcomingList> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final today = _startOfDay(DateTime.now());
    final days = List<DateTime>.generate(
      14,
      (i) => today.add(Duration(days: i)),
    );

    final byDay = <DateTime, List<Tournament>>{};
    for (final t in widget.tournaments) {
      final key = _startOfDay(t.datetime);
      if (key.isBefore(today)) continue;
      if (key.difference(today).inDays >= 14) continue;
      byDay.putIfAbsent(key, () => []).add(t);
    }
    for (final list in byDay.values) {
      list.sort((a, b) => a.datetime.compareTo(b.datetime));
    }

    final selectedDay = days[_selectedDayIndex.clamp(0, days.length - 1)];
    final selectedTournaments = byDay[selectedDay] ?? const <Tournament>[];

    final hasAny = byDay.values.any((list) => list.isNotEmpty);
    if (!hasAny) {
      return _buildEmptyAll(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DayStrip(
          days: days,
          byDay: byDay,
          selectedIndex: _selectedDayIndex,
          onSelect: (i) => setState(() => _selectedDayIndex = i),
        ),
        const SizedBox(height: 12),
        if (selectedTournaments.isEmpty)
          _buildEmptyForDay(context)
        else
          Column(
            children: [
              for (var i = 0; i < selectedTournaments.length; i++) ...[
                _TournamentRow(
                  tournament: selectedTournaments[i],
                  onTap: () => widget.onTap?.call(selectedTournaments[i]),
                ),
                if (i < selectedTournaments.length - 1) const SizedBox(height: 8),
              ],
            ],
          ),
      ],
    );
  }

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  Widget _buildEmptyForDay(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.calendarNoTournamentsForDay,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildEmptyAll(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.calendarEmptyAll,
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _DayStrip extends StatefulWidget {
  final List<DateTime> days;
  final Map<DateTime, List<Tournament>> byDay;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _DayStrip({
    required this.days,
    required this.byDay,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  State<_DayStrip> createState() => _DayStripState();
}

class _DayStripState extends State<_DayStrip> {
  final ScrollController _ctrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _cellWidth = 50.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dows = <String>[
      l10n.weekdayShortMon,
      l10n.weekdayShortTue,
      l10n.weekdayShortWed,
      l10n.weekdayShortThu,
      l10n.weekdayShortFri,
      l10n.weekdayShortSat,
      l10n.weekdayShortSun,
    ];
    return SizedBox(
      height: 70,
      child: ListView.separated(
        controller: _ctrl,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: widget.days.length,
        separatorBuilder: (_, __) => const SizedBox(width: _gap),
        itemBuilder: (_, i) {
          final day = widget.days[i];
          final list = widget.byDay[day] ?? const <Tournament>[];
          return _DayCell(
            dow: dows[(day.weekday - 1) % 7],
            day: day.day,
            count: list.length,
            selected: i == widget.selectedIndex,
            onTap: () => widget.onSelect(i),
            width: _cellWidth,
          );
        },
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String dow;
  final int day;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final double width;

  const _DayCell({
    required this.dow,
    required this.day,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accent;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withAlpha(36) : AppTheme.card,
          border: Border.all(
            color: selected ? accent.withAlpha(82) : AppTheme.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dow,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: selected ? accent : AppTheme.textDim,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$day',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                height: 1,
                color: selected ? accent : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 5,
              child: count > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < count.clamp(1, 4); i++) ...[
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          if (i < count.clamp(1, 4) - 1) const SizedBox(width: 2),
                        ],
                      ],
                    )
                  : Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
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

class _TournamentRow extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback? onTap;

  const _TournamentRow({required this.tournament, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final filled = t.participantsCount;
    final max = t.maxParticipants;
    final isCritical = max > 0 && filled / max >= 0.875;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClubLogoTile(
              url: t.club.logo,
              name: t.club.name,
              size: 38,
              radius: 8,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.time,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accent,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.textDim,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          '${localizeTournamentType(context, t.type, fallback: t.typeName)} · ${AppLocalizations.of(context)!.levelShort(t.levelText)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.priceText,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.calendarSeats(filled, max),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isCritical ? AppTheme.error : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
