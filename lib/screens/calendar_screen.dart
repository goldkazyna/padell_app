import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/tournament.dart';
import '../providers/home_provider.dart';
import '../theme/app_theme.dart';
import '../utils/profile_incomplete_guard.dart';
import '../widgets/app_back_button.dart';
import '../widgets/tournaments/club_logo.dart';
import '../widgets/tournaments/league_stage_tag.dart';
import 'tournament_detail_screen.dart';

/// Полный календарь предстоящих турниров — все ближайшие, сгруппированы по дню.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  static const _months = [
    'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
    'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
  ];
  static const _dows = ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];

  static DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text(
                    l.calendarTitle,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<HomeProvider>(
                builder: (_, home, __) {
                  final today = _startOfDay(DateTime.now());
                  final tournaments = home.upcomingTournaments
                      .where((t) => !_startOfDay(t.datetime).isBefore(today))
                      .toList()
                    ..sort((a, b) => a.datetime.compareTo(b.datetime));

                  if (tournaments.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l.calendarEmptyAll,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }

                  // Группировка по дню
                  final byDay = <DateTime, List<Tournament>>{};
                  for (final t in tournaments) {
                    final key = _startOfDay(t.datetime);
                    byDay.putIfAbsent(key, () => []).add(t);
                  }
                  final sortedDays = byDay.keys.toList()..sort();

                  return RefreshIndicator(
                    color: AppTheme.accent,
                    backgroundColor: AppTheme.card,
                    onRefresh: () async => context.read<HomeProvider>().refresh(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: sortedDays.length,
                      itemBuilder: (context, index) {
                        final day = sortedDays[index];
                        final list = byDay[day]!;
                        final isToday = day == today;
                        return Padding(
                          padding: EdgeInsets.only(top: index == 0 ? 0 : 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _DayHeader(
                                day: day,
                                isToday: isToday,
                                count: list.length,
                                todayLabel: l.calendarTodayDow,
                              ),
                              const SizedBox(height: 8),
                              for (var i = 0; i < list.length; i++) ...[
                                _CalendarRow(
                                  tournament: list[i],
                                  onTap: () {
                                    if (!ensureProfileComplete(context)) return;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TournamentDetailScreen(
                                          tournamentId: list[i].id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (i < list.length - 1) const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  final DateTime day;
  final bool isToday;
  final int count;
  final String todayLabel;

  const _DayHeader({
    required this.day,
    required this.isToday,
    required this.count,
    required this.todayLabel,
  });

  @override
  Widget build(BuildContext context) {
    final dow = isToday
        ? todayLabel
        : CalendarScreen._dows[(day.weekday - 1) % 7];
    final dateStr = '${day.day} ${CalendarScreen._months[day.month - 1]}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          dow,
          style: TextStyle(
            color: isToday ? AppTheme.accent : AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '· $dateStr',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.accent.withAlpha(28),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CalendarRow extends StatelessWidget {
  final Tournament tournament;
  final VoidCallback onTap;

  const _CalendarRow({required this.tournament, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = tournament;
    final filled = t.participantsCount;
    final max = t.maxParticipants;
    final isCritical = max > 0 && filled / max >= 0.875;
    final l = AppLocalizations.of(context)!;

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
                      if (t.league != null) ...[
                        LeagueStageTag(league: t.league!),
                        const SizedBox(width: 6),
                      ],
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
                          '${t.typeName} · ${l.levelShort(t.levelText)}',
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
                  l.calendarSeats(filled, max),
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
