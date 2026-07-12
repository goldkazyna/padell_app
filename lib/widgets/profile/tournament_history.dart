import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../models/tournament.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/tournament_navigation.dart';
import '../../theme/app_theme.dart';
import '../../utils/rating_formatter.dart';
import 'medal.dart';

class TournamentHistory extends StatelessWidget {
  const TournamentHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (_, profile, __) {
        final tournaments = profile.tournamentHistory;
        final visible = tournaments.take(4).toList();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  'История турниров',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (profile.isLoadingHistory && tournaments.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
                )
              else if (tournaments.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.noFinishedTournamentsYet,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (int i = 0; i < visible.length; i++)
                        TournamentHistoryRow(
                          tournament: visible[i],
                          isLast: i == visible.length - 1,
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class TournamentHistoryRow extends StatelessWidget {
  final Tournament tournament;
  final bool isLast;

  const TournamentHistoryRow({
    super.key,
    required this.tournament,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final place = tournament.myResult?.place;
    final delta = tournament.myResult?.ratingChange ?? 0;
    final isPositive = delta >= 0;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat('d MMMM', locale).format(tournament.datetime);

    return InkWell(
      onTap: () => openTournamentLive(context, tournament),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : AppTheme.divider,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0x08FFFFFF),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: (place != null && place >= 1 && place <= 3)
                  ? Medal(place: place, size: 22)
                  : (place != null && place > 3)
                      ? Text(
                          '$place',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      : Icon(
                          Icons.emoji_events_outlined,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.name,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateText,
                    style: TextStyle(color: AppTheme.textDim, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!tournament.isRated)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  AppLocalizations.of(context)!.unratedBadge,
                  style: TextStyle(
                    color: AppTheme.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Builder(builder: (ctx) {
                final precise = ctx.watch<SettingsProvider>().preciseRating;
                return SizedBox(
                  width: precise ? 80 : 50,
                  child: Text(
                    RatingFormatter.formatRatingChange(delta, precise,
                        decimals: 4),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: isPositive ? AppTheme.accent : AppTheme.error,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
