import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/rating_formatter.dart';

class HomeStats extends StatelessWidget {
  const HomeStats({super.key});

  @override
  Widget build(BuildContext context) {
    final precise = context.watch<SettingsProvider>().preciseRating;
    return Consumer<HomeProvider>(
      builder: (_, home, __) {
        final user = home.user;
        final rating = user != null
            ? RatingFormatter.formatRating(user.rating, precise)
            : '-';
        final level = user != null
            ? RatingFormatter.formatLevel(
                bucketedLevel: user.level,
                rating: user.rating,
                precise: precise,
              )
            : '-';
        final place = user?.place != null ? '#${user!.place}' : '-';

        return Row(
          children: [
            _buildStatCard(Icons.trending_up, rating, AppLocalizations.of(context)!.rating),
            const SizedBox(width: 12),
            _buildStatCard(Icons.bar_chart, level, AppLocalizations.of(context)!.level),
            const SizedBox(width: 12),
            _buildStatCard(Icons.military_tech_outlined, place, AppLocalizations.of(context)!.place),
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
