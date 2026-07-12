import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/tournament.dart';
import '../../utils/rating_formatter.dart';

class TournamentArchiveCard extends StatelessWidget {
  final String day;
  final String month;
  final String name;
  final String type;
  final Color typeColor;
  final String club;
  final int? placeNumber;
  final int ratingChangeRaw;
  final bool isPositive;
  final bool isRated;

  const TournamentArchiveCard({
    super.key,
    required this.day,
    required this.month,
    required this.name,
    required this.type,
    required this.typeColor,
    required this.club,
    required this.placeNumber,
    required this.ratingChangeRaw,
    required this.isPositive,
    this.isRated = true,
  });

  factory TournamentArchiveCard.fromTournament(Tournament t) {
    final result = t.myResult;
    final change = result?.ratingChange ?? 0;
    return TournamentArchiveCard(
      day: t.dayOfMonth,
      month: t.monthShort,
      name: t.name,
      type: t.typeName,
      typeColor: t.typeColor,
      club: t.club.name,
      placeNumber: result?.place,
      ratingChangeRaw: change,
      isPositive: change >= 0,
      isRated: t.isRated,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final place = placeNumber != null ? l10n.placeResult(placeNumber!) : '-';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Дата
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Text(
                  day,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  month,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: typeColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    type,
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  club,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 10),

                // Результат
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.emoji_events, color: Color(0xFFFBBF24), size: 14),
                          const SizedBox(width: 4),
                          Text(
                            place,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (!isRated)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          l10n.unratedBadge,
                          style: TextStyle(
                            color: AppTheme.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Builder(builder: (ctx) {
                        final precise =
                            ctx.watch<SettingsProvider>().preciseRating;
                        return Text(
                          RatingFormatter.formatRatingChange(
                              ratingChangeRaw, precise),
                          style: TextStyle(
                            color: isPositive ? AppTheme.accent : AppTheme.error,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}