import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class UpcomingList extends StatelessWidget {
  final List<Tournament> tournaments;
  final Function(Tournament)? onTap;

  const UpcomingList({
    super.key,
    required this.tournaments,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tournaments.isEmpty) {
      return _buildEmptyState(context);
    }

    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: tournaments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) => _buildCard(context, tournaments[index]),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Tournament t) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.62;

    return GestureDetector(
      onTap: () => onTap?.call(t),
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    '${t.dayOfMonth} ${t.monthShort.toUpperCase()} · ${t.time}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                _buildParticipantsBadge(t),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              t.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              t.club.name,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsBadge(Tournament t) {
    final isFull = t.isFull;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFull
            ? AppTheme.error.withAlpha(40)
            : AppTheme.accent.withAlpha(40),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        t.participantsText,
        style: TextStyle(
          color: isFull ? AppTheme.error : AppTheme.accent,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.noUpcomingTournaments,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
      ),
    );
  }
}
