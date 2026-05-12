import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/rating_formatter.dart';

class ProfileStats extends StatelessWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (_, profile, __) {
        final user = profile.user;
        final stats = profile.statistics;
        final precise = context.watch<SettingsProvider>().preciseRating;

        final l = AppLocalizations.of(context)!;
        return Column(
          children: [
            Row(
              children: [
                _buildStatCard(
                  Icons.trending_up,
                  user != null
                      ? RatingFormatter.formatRating(user.rating, precise)
                      : '0',
                  l.rating,
                  const Color(0xFF22C55E),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.bar_chart,
                  user != null
                      ? RatingFormatter.formatLevel(
                          bucketedLevel: user.level,
                          rating: user.rating,
                          precise: precise,
                        )
                      : '-',
                  l.level,
                  const Color(0xFF22C55E),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.military_tech_outlined,
                  user?.place != null ? '#${user!.place}' : '-',
                  l.place,
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
                  l.matches,
                  const Color(0xFF3B82F6),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.check_circle_outline,
                  stats != null ? '${stats.wins}' : '-',
                  l.wins,
                  const Color(0xFF22C55E),
                ),
                const SizedBox(width: 10),
                _buildStatCard(
                  Icons.star_outline,
                  stats != null ? '${stats.winrate}%' : '-',
                  l.winrate,
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
