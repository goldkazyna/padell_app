import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../screens/edit_profile_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/rating_formatter.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final precise = context.watch<SettingsProvider>().preciseRating;
    return Consumer<ProfileProvider>(
      builder: (_, profile, __) {
        final user = profile.user;
        final stats = profile.statistics;
        final l = AppLocalizations.of(context)!;

        final level = double.tryParse(user?.level ?? '0') ?? 0;
        final rating = user?.rating ?? 0;
        final currentLevelRating = (level * 1000).round();
        final nextLevel = level >= 5.0 ? 5.0 : level + 0.25;
        final nextLevelRating = (nextLevel * 1000).round();
        final step = nextLevelRating - currentLevelRating;
        final progress = step > 0
            ? ((rating - currentLevelRating) / step).clamp(0.0, 1.0)
            : 1.0;
        final ratingStr = RatingFormatter.formatRating(rating, precise);
        final nextLevelRatingStr =
            RatingFormatter.formatRating(nextLevelRating, precise);
        final levelStr = RatingFormatter.formatLevel(
          bucketedLevel: user?.level ?? '0',
          rating: rating,
          precise: precise,
        );

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1a3a2a), Color(0xFF0d1f15), Color(0xFF1a2a1a)],
            ),
            border: Border.all(color: AppTheme.accent.withAlpha(60), width: 1),
          ),
          child: Column(
            children: [
              // Top: avatar + name + rating
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.accent.withAlpha(80), width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: user?.avatar != null
                          ? Image.network(
                              user!.avatar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildInitials(user),
                            )
                          : _buildInitials(user),
                    ),
                    const SizedBox(width: 14),
                    // Name + phone + edit button
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? l.profileUser,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.formattedPhone ?? '',
                            style: const TextStyle(
                              color: Color(0xFF71717A),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                              );
                              if (context.mounted) {
                                context.read<ProfileProvider>().loadProfile();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.accent.withAlpha(60)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined, size: 12, color: AppTheme.accent),
                                  SizedBox(width: 5),
                                  Text(
                                    'Редактировать',
                                    style: TextStyle(
                                      color: AppTheme.accent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rating big
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ratingStr,
                          style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: precise ? 26 : 32,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        Text(
                          user?.place != null ? '#${user!.place} в рейтинге' : '',
                          style: const TextStyle(
                            color: Color(0xFF52525B),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Progress bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l.profileLevelLabel(levelStr),
                          style: TextStyle(
                            color: Colors.white.withAlpha(80),
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          '$ratingStr / $nextLevelRatingStr',
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: Colors.white.withAlpha(20),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                      ),
                    ),
                  ],
                ),
              ),

              // Stats row
              Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: AppTheme.accent.withAlpha(30))),
                ),
                child: Row(
                  children: [
                    _buildStat(ratingStr, l.rating, isAccent: true),
                    _buildStat(stats != null ? '${stats.matchesPlayed}' : '-', l.matches),
                    _buildStat(stats != null ? '${stats.wins}' : '-', l.wins),
                    _buildStat(stats != null ? '${stats.winrate}%' : '-', l.winrate, isLast: true),
                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildInitials(dynamic user) {
    return Center(
      child: Text(
        user?.initials ?? '??',
        style: const TextStyle(
          color: AppTheme.accent,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, {bool isAccent = false, bool isLast = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : Border(right: BorderSide(color: AppTheme.accent.withAlpha(20))),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: isAccent ? AppTheme.accent : AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha(80),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
