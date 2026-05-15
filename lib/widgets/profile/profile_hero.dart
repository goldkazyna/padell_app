import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../screens/edit_profile_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/rating_formatter.dart';
import '../level_verification_sheet.dart';
import 'player_hero.dart' show openFullScreenAvatar;
import '../verified_badge.dart';

class ProfileHero extends StatelessWidget {
  final Widget? trailing;

  const ProfileHero({super.key, this.trailing});

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
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _TopRow(user: user, trailing: trailing),
                        const SizedBox(height: 16),
                        _RatingRow(
                          rating: rating,
                          rank: rank,
                          trend: trend,
                          userId: user?.id,
                          playerName: user?.name,
                        ),
                        const SizedBox(height: 14),
                        _LevelProgress(
                          level: level,
                          nextLevel: nextLevel,
                          progress: progress,
                          rating: rating,
                          target: nextLevelRating,
                        ),
                      ],
                    ),
                  ),
                  _StatsStrip(
                    matches: matches,
                    wins: wins,
                    winrate: winrate,
                    losses: losses,
                    winrateColor: winrateColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopRow extends StatelessWidget {
  final dynamic user;
  final Widget? trailing;
  const _TopRow({required this.user, this.trailing});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user?.avatar as String?;
    final initials = (user?.initials as String?) ?? '??';

    Widget avatarFallback = Container(
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

    Widget avatar;
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;
    if (hasAvatar) {
      avatar = Hero(
        tag: 'player-avatar-$avatarUrl',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            avatarUrl,
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => avatarFallback,
          ),
        ),
      );
    } else {
      avatar = avatarFallback;
    }

    if (hasAvatar) {
      avatar = GestureDetector(
        onTap: () => openFullScreenAvatar(context, avatarUrl),
        child: avatar,
      );
    }

    return Row(
      children: [
        avatar,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
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
                  ),
                  if (user?.levelVerified == true) ...[
                    const SizedBox(width: 5),
                    VerifiedBadge(
                      size: 13,
                      userId: user?.id,
                      playerName: user?.name,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                user?.formattedPhone ?? '',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        trailing ??
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
}

class _RatingRow extends StatelessWidget {
  final int rating;
  final int? rank;
  final List<int> trend;
  final int? userId;
  final String? playerName;

  const _RatingRow({
    required this.rating,
    required this.rank,
    required this.trend,
    this.userId,
    this.playerName,
  });

  @override
  Widget build(BuildContext context) {
    final canTap = userId != null && (playerName ?? '').isNotEmpty;
    final precise = context.watch<SettingsProvider>().preciseRating;

    final ratingBlock = Column(
      mainAxisSize: MainAxisSize.min,
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              RatingFormatter.formatRating(rating, precise),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: precise ? 32 : 38,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.3,
                height: 1,
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
    );

    // График-спарклайн рядом с рейтингом убран — теперь есть полноразмерная
    // карточка «Динамика рейтинга» под hero-блоком.
    return canTap
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => LevelVerificationSheet.show(
              context,
              userId: userId!,
              playerName: playerName!,
            ),
            child: ratingBlock,
          )
        : ratingBlock;
  }
}

class _LevelProgress extends StatelessWidget {
  final double level;
  final double nextLevel;
  final double progress;
  final int rating;
  final int target;

  const _LevelProgress({
    required this.level,
    required this.nextLevel,
    required this.progress,
    required this.rating,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final precise = context.watch<SettingsProvider>().preciseRating;
    final levelStr = RatingFormatter.formatLevel(
      bucketedLevel: level,
      rating: rating,
      precise: precise,
    );
    final ratingStr = RatingFormatter.formatRating(rating, precise);
    final targetStr = RatingFormatter.formatRating(target, precise);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Уровень $levelStr → ${nextLevel.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              '$ratingStr / $targetStr',
              style: const TextStyle(
                color: AppTheme.textDim,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final p = progress.clamp(0.0, 1.0);
            return SizedBox(
              width: w,
              height: 3,
              child: Stack(
                children: [
                  Container(
                    width: w,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0x14FFFFFF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Container(
                    width: w * p,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _StatsStrip extends StatelessWidget {
  final int matches;
  final int wins;
  final int winrate;
  final int losses;
  final Color winrateColor;

  const _StatsStrip({
    required this.matches,
    required this.wins,
    required this.winrate,
    required this.losses,
    required this.winrateColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0x33000000),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _item('$matches', 'Матчей'),
          _item('$wins', 'Побед'),
          _item('$winrate%', 'Винрейт', color: winrateColor),
          _item('$losses', 'Пораж.', color: AppTheme.textSecondary),
        ],
      ),
    );
  }

  Widget _item(String value, String label, {Color? color}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color ?? AppTheme.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
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
