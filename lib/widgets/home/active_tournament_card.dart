import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';

class ActiveTournamentCard extends StatelessWidget {
  final Tournament? tournament;
  final VoidCallback? onTap;

  const ActiveTournamentCard({
    super.key,
    this.tournament,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (tournament == null) {
      return _buildEmptyState();
    }

    final t = tournament!;
    final isLive = t.status == 'in_progress';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isLive
                        ? AppTheme.accent.withAlpha(25)
                        : const Color(0xFF3B82F6).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLive) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Live',
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ] else ...[
                        Icon(Icons.check_circle,
                          color: const Color(0xFF3B82F6),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Вы записаны',
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                _buildInfoChip(t.typeName, t.typeColor),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              t.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.club.name,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${t.date} · ${t.time}',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  t.participantsText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.sports_tennis, color: AppTheme.textSecondary, size: 40),
            SizedBox(height: 12),
            Text(
              'Вы не участвуете в турнирах',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
