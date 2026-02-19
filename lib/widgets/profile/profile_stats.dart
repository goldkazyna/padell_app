import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../theme/app_theme.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (_, profile, __) {
        final user = profile.user;
        final stats = profile.statistics;

        return Column(
          children: [
            Row(
              children: [
                _buildStatCard(
                  Icons.trending_up,
                  '${user?.rating ?? 0}',
                  'РЕЙТИНГ',
                  const Color(0xFF22C55E),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.bar_chart,
                  user?.level ?? '-',
                  'УРОВЕНЬ',
                  const Color(0xFF22C55E),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.military_tech_outlined,
                  user?.place != null ? '#${user!.place}' : '-',
                  'МЕСТО',
                  const Color(0xFF22C55E),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildStatCard(
                  Icons.grid_view,
                  stats != null ? '${stats.matchesPlayed}' : '-',
                  'МАТЧЕЙ',
                  const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.check_circle_outline,
                  stats != null ? '${stats.wins}' : '-',
                  'ПОБЕД',
                  const Color(0xFF22C55E),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.star_outline,
                  stats != null ? '${stats.winrate}%' : '-',
                  'ВИНРЕЙТ',
                  const Color(0xFFFBBF24),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
