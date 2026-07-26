import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/challenge.dart';
import '../../l10n/app_localizations.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF2A3330),
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    challenge.club?.name ?? AppLocalizations.of(context)!.challenge,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildTypeBadge(context),
              ],
            ),
            const SizedBox(height: 10),

            // Location
            _buildMetaRow(
              Icons.location_on,
              challenge.club?.name ?? AppLocalizations.of(context)!.challengeNotSpecified,
            ),
            const SizedBox(height: 6),

            // Date/time
            _buildMetaRow(
              Icons.calendar_today,
              '${challenge.dateFormatted}, ${challenge.timeFormatted}',
            ),
            const SizedBox(height: 6),

            // Level
            _buildMetaRow(
              Icons.trending_up,
              AppLocalizations.of(context)!.challengeLevel(challenge.levelText),
            ),
            const SizedBox(height: 12),

            // Slots + action button
            Row(
              children: [
                Expanded(child: _buildSlots()),
                const SizedBox(width: 12),
                _buildActionButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final isRated = challenge.isRated;
    final color = challenge.typeColor;
    final l10n = AppLocalizations.of(context)!;
    final label = isRated ? l10n.challengeRated : l10n.challengeFriendly;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.textSecondary, size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSlots() {
    // Build 4 slot positions
    final List<ChallengePlayer?> slots = List.filled(4, null);
    for (final player in challenge.players) {
      final idx = player.position - 1;
      if (idx >= 0 && idx < 4) {
        slots[idx] = player;
      }
    }

    return Row(
      children: List.generate(4, (index) {
        final player = slots[index];
        final isFilled = player != null;

        return Padding(
          padding: EdgeInsets.only(right: index < 3 ? 6 : 0),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isFilled
                  ? AppTheme.accent
                  : const Color(0xFF2A3330),
              borderRadius: BorderRadius.circular(10),
            ),
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            child: isFilled
                ? (player.avatar != null
                    ? Image.network(
                        player.avatar!,
                        fit: BoxFit.cover,
                        width: 36,
                        height: 36,
                        errorBuilder: (_, __, ___) => Text(
                          player.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : Text(
                        player.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ))
                : Icon(
                    Icons.add,
                    color: AppTheme.textSecondary,
                    size: 18,
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final bool hasOpenSlot = challenge.availablePositions.isNotEmpty &&
        !challenge.isParticipant;

    if (hasOpenSlot) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withAlpha(76),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          AppLocalizations.of(context)!.challengeJoinSlot,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accent, width: 1.5),
      ),
      child: Text(
        AppLocalizations.of(context)!.challengeDetails,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
