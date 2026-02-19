import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../theme/app_theme.dart';

class HomeStats extends StatelessWidget {
  const HomeStats({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_, home, __) {
        final user = home.user;
        final rating = user?.rating.toString() ?? '-';
        final level = user?.level ?? '-';
        final place = user?.place != null ? '#${user!.place}' : '-';

        return Row(
          children: [
            _buildStatCard(Icons.trending_up, rating, 'РЕЙТИНГ'),
            const SizedBox(width: 12),
            _buildStatCard(Icons.bar_chart, level, 'УРОВЕНЬ'),
            const SizedBox(width: 12),
            _buildStatCard(Icons.military_tech_outlined, place, 'МЕСТО'),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label) {
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
            Icon(icon, color: AppTheme.accent, size: 20),
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
