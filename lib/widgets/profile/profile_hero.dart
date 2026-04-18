import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../screens/edit_profile_screen.dart';
import '../../theme/app_theme.dart';
import 'sparkline.dart';

class ProfileHero extends StatelessWidget {
  const ProfileHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (_, profile, __) {
        final user = profile.user;
        final stats = profile.statistics;

        final rating = user?.rating ?? 0;
        final rank = user?.place;
        final level = double.tryParse(user?.level ?? '0') ?? 0;
        final nextLevel = level >= 5.0 ? 5.0 : level + 0.25;
        final currentLevelRating = (level * 1000).round();
        final nextLevelRating = (nextLevel * 1000).round();
        final progress = nextLevelRating - currentLevelRating > 0
            ? ((rating - currentLevelRating) /
                    (nextLevelRating - currentLevelRating))
                .clamp(0.0, 1.0)
            : 1.0;

        final matches = stats?.matchesPlayed ?? 0;
        final wins = stats?.wins ?? 0;
        final winrate = stats?.winrate ?? 0;
        final losses = stats?.losses ?? (matches - wins);
        final winrateColor = winrate >= 60
            ? AppTheme.accent
            : (winrate >= 40 ? AppTheme.amber : AppTheme.error);
        final trend = stats?.ratingTrend ?? const <int>[];

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Base gradient
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.4, 1.0],
                      colors: [
                        Color(0xFF1E3A2B),
                        Color(0xFF1A241E),
                        Color(0xFF1A1A1F),
                      ],
                    ),
                  ),
                ),
                // Decorative radial glow top-right
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        radius: 0.5,
                        colors: [
                          Color(0x1F22C47A), // rgba(34,196,122,0.12)
                          Color(0x0022C47A),
                        ],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                ),
                // Content
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
                      child: Column(
                        children: [
                          _buildTopRow(context, user),
                          const SizedBox(height: 16),
                          _buildRatingRow(rating, rank, trend),
                          const SizedBox(height: 14),
                          _buildLevelProgress(
                            level: level,
                            nextLevel: nextLevel,
                            progress: progress,
                            rating: rating,
                            target: nextLevelRating,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    _buildStatsStrip(
                      matches: matches,
                      wins: wins,
                      winrate: winrate,
                      losses: losses,
                      winrateColor: winrateColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopRow(BuildContext context, dynamic user) {
    return Row(
      children: [
        _buildAvatar(user),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? '—',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                user?.formattedPhone ?? '',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          ).then((_) {
            if (context.mounted) {
              context.read<ProfileProvider>().loadProfile();
            }
          }),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0x0FFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Icon(Icons.edit_outlined, size: 16, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(dynamic user) {
    final avatarUrl = user?.avatar as String?;
    final initials = user?.initials as String? ?? '??';

    Widget fallback = Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A4A36), Color(0xFF1C2B22)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppTheme.accent,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          avatarUrl,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => fallback,
        ),
      );
    }
    return fallback;
  }

  Widget _buildRatingRow(int rating, int? rank, List<int> trend) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'РЕЙТИНГ',
              style: TextStyle(
                color: AppTheme.textDim,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$rating',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -1.3,
                    height: 1,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
                if (rank != null) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '#$rank',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const Spacer(),
        Sparkline(
          points: trend.isNotEmpty ? trend : const [0, 0],
          color: AppTheme.accent,
          width: 110,
          height: 38,
        ),
      ],
    );
  }

  Widget _buildLevelProgress({
    required double level,
    required double nextLevel,
    required double progress,
    required int rating,
    required int target,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Уровень ${level.toStringAsFixed(2)} → ${nextLevel.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              '$rating / $target',
              style: const TextStyle(
                color: AppTheme.textDim,
                fontSize: 10,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 3,
            backgroundColor: const Color(0x0DFFFFFF),
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsStrip({
    required int matches,
    required int wins,
    required int winrate,
    required int losses,
    required Color winrateColor,
  }) {
    final items = [
      _StatItem('$matches', 'Матчей'),
      _StatItem('$wins', 'Побед'),
      _StatItem('$winrate%', 'Винрейт', color: winrateColor),
      _StatItem('$losses', 'Пораж.', color: AppTheme.textSecondary),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0x33000000),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((it) => _buildStatItem(it)).toList(),
      ),
    );
  }

  Widget _buildStatItem(_StatItem it) {
    return Column(
      children: [
        Text(
          it.value,
          style: TextStyle(
            color: it.color ?? AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          it.label,
          style: const TextStyle(
            color: AppTheme.textDim,
            fontSize: 10,
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  final String value;
  final String label;
  final Color? color;
  _StatItem(this.value, this.label, {this.color});
}
