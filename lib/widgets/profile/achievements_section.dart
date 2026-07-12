import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l.achievements,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
            Text(
              l.allButton,
              style: const TextStyle(
                color: AppTheme.accent,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildAchievement(Icons.emoji_events, l.achievementFirstWin, const Color(0xFFEF4444)),
              const SizedBox(width: 10),
              _buildAchievement(Icons.bolt, l.achievementFiveWins, const Color(0xFF22C55E)),
              const SizedBox(width: 10),
              _buildAchievement(Icons.star, l.achievementTopTen, const Color(0xFF3B82F6)),
              const SizedBox(width: 10),
              _buildAchievement(Icons.calendar_month, l.achievementTenTournaments, const Color(0xFFA855F7)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievement(IconData icon, String label, Color color) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}