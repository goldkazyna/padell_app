import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/game.dart';
import '../../providers/settings_provider.dart';
import '../../utils/rating_formatter.dart';
import '../../l10n/app_localizations.dart';

/// Список участников игры: карточка со слотами 1..capacity.
/// Кнопки-колбэки опциональны — используются только в Task 2.
class GamePlayersList extends StatelessWidget {
  final Game game;
  final void Function(GamePlayer)? onApprove;
  final void Function(GamePlayer)? onReject;
  final void Function(GamePlayer)? onRemove;
  final void Function(int position)? onInviteSlot;

  const GamePlayersList({
    super.key,
    required this.game,
    this.onApprove,
    this.onReject,
    this.onRemove,
    this.onInviteSlot,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final capacity = game.capacity;
    final List<GamePlayer?> slots = List.filled(capacity, null);
    for (final player in game.players) {
      final idx = player.position - 1;
      if (idx >= 0 && idx < capacity) {
        slots[idx] = player;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A3330),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.gamePlayersTitle,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(capacity, (index) {
            final player = slots[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < capacity - 1 ? 10 : 0,
              ),
              child: player != null
                  ? _buildPlayerRow(context, player)
                  : _buildFreeSlot(context, index + 1),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAvatar(GamePlayer player) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: player.avatar != null
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
            ),
    );
  }

  Widget _buildStatusChip(BuildContext context, GamePlayer player) {
    final l10n = AppLocalizations.of(context)!;
    final Color color;
    final String label;
    if (player.isAccepted) {
      color = AppTheme.accent;
      label = l10n.gameStatusAccepted;
    } else if (player.isCandidate) {
      color = AppTheme.orange;
      label = l10n.gameStatusCandidate;
    } else {
      color = AppTheme.textSecondary;
      label = l10n.gameStatusInvited;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

  Widget _buildPlayerRow(BuildContext context, GamePlayer player) {
    final l10n = AppLocalizations.of(context)!;
    final precise = context.watch<SettingsProvider>().preciseRating;
    final ratingText = RatingFormatter.formatLevelLabel(
      bucketedLevel: player.level,
      rating: player.rating,
      precise: precise,
    );

    return Row(
      children: [
        _buildAvatar(player),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      player.fullName,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (player.isMe) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(${l10n.gamePlayerYou})',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                ratingText,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusChip(context, player),
        if (player.isCandidate && onApprove != null) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onApprove!(player),
            child: Icon(Icons.check_circle, color: AppTheme.accent, size: 22),
          ),
        ],
        if (player.isCandidate && onReject != null) ...[
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => onReject!(player),
            child: Icon(Icons.cancel, color: AppTheme.error, size: 22),
          ),
        ],
        if (onRemove != null && !player.isCandidate) ...[
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => onRemove!(player),
            child: Icon(Icons.close, color: AppTheme.textSecondary, size: 20),
          ),
        ],
      ],
    );
  }

  Widget _buildFreeSlot(BuildContext context, int position) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF2A3330),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            l10n.gameSlotFree,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (onInviteSlot != null)
          GestureDetector(
            onTap: () => onInviteSlot!(position),
            child: Icon(Icons.add_circle_outline, color: AppTheme.accent, size: 22),
          ),
      ],
    );
  }
}
