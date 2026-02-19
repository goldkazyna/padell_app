import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/tournament.dart';

class TeamInfoCard extends StatelessWidget {
  final TournamentTeam team;

  static const Color _pendingColor = Color(0xFFF59E0B);

  const TeamInfoCard({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    final isPending = team.isPending;
    final statusColor = isPending ? _pendingColor : AppTheme.accent;
    final statusText = isPending ? 'На модерации' : 'Подтверждена';
    final statusIcon = isPending ? Icons.access_time : Icons.check_circle;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: statusColor.withAlpha(15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withAlpha(60), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.groups, color: statusColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Ваша команда',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withAlpha(60), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Players
          _buildPlayerInfo(team.player1),
          if (team.player2 != null) ...[
            const SizedBox(height: 8),
            _buildPlayerInfo(team.player2!),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(TournamentTeamPlayer player) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: AppTheme.accent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              player.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                player.name,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                player.levelText,
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
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
