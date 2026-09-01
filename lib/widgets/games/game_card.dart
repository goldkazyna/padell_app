import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/game.dart';
import '../../l10n/app_localizations.dart';

class GameCard extends StatelessWidget {
  final Game game;
  final VoidCallback onTap;

  const GameCard({
    super.key,
    required this.game,
    required this.onTap,
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
                    game.club?.name ?? AppLocalizations.of(context)!.gameTitleFallback,
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
                const SizedBox(width: 6),
                _buildFormatBadge(context),
              ],
            ),
            const SizedBox(height: 10),

            // Location
            _buildMetaRow(
              Icons.location_on,
              game.club?.name ?? AppLocalizations.of(context)!.gameTitleFallback,
            ),
            const SizedBox(height: 6),

            // Date/time
            _buildMetaRow(
              Icons.calendar_today,
              '${game.dateFormatted}, ${game.timeFormatted}',
            ),
            const SizedBox(height: 6),

            // Level. Игры видно все, поэтому рядом честная пометка, если
            // уровень не мой: решение всё равно за организатором.
            Row(
              children: [
                Expanded(child: _buildMetaRow(Icons.trending_up, game.levelText)),
                if (!game.levelMatches)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.orange.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'не ваш уровень',
                      style: TextStyle(
                        color: AppTheme.orange,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
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
    final isRated = game.isRated;
    final color = isRated ? AppTheme.accent : AppTheme.orange;
    final l10n = AppLocalizations.of(context)!;
    final label = isRated ? l10n.gameTypeRated : l10n.gameTypeFriendly;

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

  Widget _buildFormatBadge(BuildContext context) {
    const color = Color(0xFF7C3AED);
    final l10n = AppLocalizations.of(context)!;
    final String label;
    if (game.isSets) {
      label = l10n.gameFormatSets;
    } else if (game.isPoints) {
      label = l10n.gameFormatPoints;
    } else if (game.isAmericano) {
      label = l10n.gameFormatAmericano;
    } else {
      label = game.formatName;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
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
    final capacity = game.capacity;
    final List<GamePlayer?> slots = List.filled(capacity, null);
    for (final player in game.players) {
      if (!player.isAccepted) continue;
      final idx = player.position - 1;
      if (idx >= 0 && idx < capacity) {
        slots[idx] = player;
      }
    }

    return Row(
      children: List.generate(capacity, (index) {
        final player = slots[index];
        final isFilled = player != null;

        return Padding(
          padding: EdgeInsets.only(right: index < capacity - 1 ? 6 : 0),
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
                        errorBuilder: (context, error, stackTrace) => Text(
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
    final bool hasOpenSlot = game.availablePositions.isNotEmpty &&
        !game.isParticipant;

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
          AppLocalizations.of(context)!.gameJoinSlot,
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
        AppLocalizations.of(context)!.gameDetails,
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
