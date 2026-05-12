import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/rating_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/rating_formatter.dart';
import '../verified_badge.dart';

class PlayerRatingItem extends StatelessWidget {
  final RatingPlayer player;

  const PlayerRatingItem({
    super.key,
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final isMe = player.isMe;
    final precise = context.watch<SettingsProvider>().preciseRating;

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
            clipBehavior: Clip.antiAlias,
            child: player.avatar != null
                ? Image.network(
                    player.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        player.initials,
                        style: TextStyle(
                          color: isMe ? AppTheme.accent : AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : Center(
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        player.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (player.levelVerified) ...[
                      const SizedBox(width: 5),
                      VerifiedBadge(
                        size: 12,
                        userId: player.id,
                        playerName: player.name,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  RatingFormatter.formatLevelLabel(
                    bucketedLevel: player.level,
                    rating: player.rating,
                    precise: precise,
                  ),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            RatingFormatter.formatRating(player.rating, precise),
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
