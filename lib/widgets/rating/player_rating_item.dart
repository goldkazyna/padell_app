import 'package:flutter/material.dart';
import '../../services/rating_service.dart';
import '../../theme/app_theme.dart';

class PlayerRatingItem extends StatelessWidget {
  final RatingPlayer player;

  const PlayerRatingItem({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = player.isMe;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accent.withAlpha(15) : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? AppTheme.accent.withAlpha(80) : const Color(0xFF2A2A2A),
          width: isMe ? 1 : 0.5,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: _buildRank(player.position),
          ),
          const SizedBox(width: 12),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMe
                  ? AppTheme.accent.withAlpha(40)
                  : const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                player.initials,
                style: TextStyle(
                  color: isMe ? AppTheme.accent : AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'L${_getLevelCategory(player.level)} · ${player.level}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${player.rating}',
            style: TextStyle(
              color: isMe ? AppTheme.accent : AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelCategory(double level) {
    if (level >= 4.0) return '4';
    if (level >= 3.0) return '3';
    if (level >= 2.0) return '2';
    return '1';
  }

  Widget _buildRank(int rank) {
    return Text(
      '$rank',
      style: TextStyle(
        color: rank <= 3 ? AppTheme.accent : AppTheme.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
