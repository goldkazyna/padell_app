import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/tournament.dart';

class TournamentCard extends StatelessWidget {
  final String day;
  final String month;
  final String time;
  final String name;
  final String type;
  final Color typeColor;
  final String club;
  final String participants;
  final String price;
  final String level;
  final bool isRegistered;
  final bool isFull;
  final bool isRated;
  final bool verifiedOnly;
  final bool flat;

  const TournamentCard({
    super.key,
    required this.day,
    required this.month,
    required this.time,
    required this.name,
    required this.type,
    required this.typeColor,
    required this.club,
    required this.participants,
    required this.price,
    required this.level,
    this.isRegistered = false,
    this.isFull = false,
    this.isRated = true,
    this.verifiedOnly = false,
    this.flat = false,
  });

  factory TournamentCard.fromTournament(Tournament t, {bool flat = false}) {
    return TournamentCard(
      day: t.dayOfMonth,
      month: t.monthShort,
      time: t.time,
      name: t.name,
      type: t.typeName,
      typeColor: t.typeColor,
      club: t.club.name,
      participants: t.participantsText,
      price: t.priceText,
      level: t.levelText,
      isRegistered: t.isRegistered,
      isFull: t.isFull,
      isRated: t.isRated,
      verifiedOnly: t.verifiedOnly,
      flat: flat,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: flat
          ? null
          : BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF1E1E1E), width: 1),
            ),
      clipBehavior: flat ? Clip.none : Clip.antiAlias,
      child: Column(
        children: [
          // Date strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              border: Border(
                bottom: BorderSide(color: Color(0xFF1E1E1E), width: 1),
              ),
            ),
            child: Row(
              children: [
                // Day
                Text(
                  day,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                    height: 1,
                  ),
                ),
                const SizedBox(width: 4),
                // Month
                Text(
                  month,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                // Dot separator
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 3,
                  height: 3,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4A4A4A),
                    shape: BoxShape.circle,
                  ),
                ),
                // Time
                Text(
                  time,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 12),
                // Tournament name
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Badge + Club row
                Row(
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: typeColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (!isRated) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.orange.withAlpha(25),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.tournamentUnrated,
                          style: const TextStyle(
                            color: AppTheme.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                    if (verifiedOnly) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withAlpha(25),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified,
                                color: AppTheme.accent, size: 11),
                            const SizedBox(width: 3),
                            Text(
                              AppLocalizations.of(context)!
                                  .tournamentVerifiedBadge,
                              style: const TextStyle(
                                color: AppTheme.accent,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    // Club
                    Text(
                      club,
                      style: const TextStyle(
                        color: Color(0xFF4A4A4A),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Meta + Action button row
                Row(
                  children: [
                    // Meta items
                    Expanded(
                      child: Row(
                        children: [
                          _buildMetaItem(Icons.people_outline, participants),
                          const SizedBox(width: 12),
                          _buildMetaItem(Icons.payments_outlined, price),
                          const SizedBox(width: 12),
                          _buildMetaItem(Icons.trending_up, level),
                        ],
                      ),
                    ),
                    // Action button
                    _buildActionButton(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 13),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isRegistered) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check, color: AppTheme.accent, size: 14),
            const SizedBox(width: 5),
            Text(
              l10n.tournamentRegistered,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    if (isFull) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: AppTheme.error,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          l10n.noSpotsLeft,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withAlpha(76),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        l10n.register,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
