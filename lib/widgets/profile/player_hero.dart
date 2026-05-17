import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/rating_formatter.dart';
import '../level_verification_sheet.dart';
import '../verified_badge.dart';
import 'sparkline.dart';

class PlayerHero extends StatelessWidget {
  final int? userId;
  final String name;
  final String? avatar;
  final String initials;
  final int rating;
  final int? rank;
  final double level;
  final bool levelVerified;
  final List<int> trend;
  final int matchesPlayed;
  final int wins;
  final int winrate;
  final int tournamentsCount;

  const PlayerHero({
    super.key,
    this.userId,
    required this.name,
    this.avatar,
    required this.initials,
    required this.rating,
    this.rank,
    required this.level,
    this.levelVerified = false,
    this.trend = const [],
    required this.matchesPlayed,
    required this.wins,
    required this.winrate,
    required this.tournamentsCount,
  });

  @override
  Widget build(BuildContext context) {
    final nextLevel = level >= 5.0 ? 5.0 : level + 0.25;
    final currentLevelRating = (level * 1000).round();
    final nextLevelRating = (nextLevel * 1000).round();
    final progress = nextLevelRating - currentLevelRating > 0
        ? ((rating - currentLevelRating) /
                (nextLevelRating - currentLevelRating))
            .clamp(0.0, 1.0)
        : 1.0;

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
                    _TopRow(
                      userId: userId,
                      name: name,
                      avatar: avatar,
                      initials: initials,
                      levelVerified: levelVerified,
                    ),
                    const SizedBox(height: 16),
                    _RatingRow(
                      rating: rating,
                      rank: rank,
                      trend: trend,
                      userId: userId,
                      playerName: name,
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
                rating: rating,
                matches: matchesPlayed,
                wins: wins,
                winrate: winrate,
                tournamentsCount: tournamentsCount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopRow extends StatelessWidget {
  final int? userId;
  final String name;
  final String? avatar;
  final String initials;
  final bool levelVerified;

  const _TopRow({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.initials,
    required this.levelVerified,
  });

  @override
  Widget build(BuildContext context) {
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

    final hasAvatar = avatar != null && avatar!.isNotEmpty;
    Widget avatarWidget;
    if (hasAvatar) {
      avatarWidget = Hero(
        tag: 'player-avatar-${avatar!}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            avatar!,
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => avatarFallback,
          ),
        ),
      );
    } else {
      avatarWidget = avatarFallback;
    }

    if (hasAvatar) {
      avatarWidget = GestureDetector(
        onTap: () => openFullScreenAvatar(context, avatar!),
        child: avatarWidget,
      );
    }

    return Row(
      children: [
        avatarWidget,
        const SizedBox(width: 14),
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  name,
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
              if (levelVerified) ...[
                const SizedBox(width: 5),
                VerifiedBadge(
                  size: 13,
                  userId: userId,
                  playerName: name,
                ),
              ],
            ],
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
        Text(
          AppLocalizations.of(context)!.rating,
          style: const TextStyle(
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: canTap
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => LevelVerificationSheet.show(
                    context,
                    userId: userId!,
                    playerName: playerName!,
                  ),
                  child: ratingBlock,
                )
              : ratingBlock,
        ),
        const SizedBox(width: 10),
        if (trend.length >= 2)
          Sparkline(
            points: trend,
            color: AppTheme.accent,
            width: 110,
            height: 38,
          ),
      ],
    );
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
              AppLocalizations.of(context)!.levelProgressLabel(
                levelStr,
                nextLevel.toStringAsFixed(2),
              ),
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
  final int rating;
  final int matches;
  final int wins;
  final int winrate;
  final int tournamentsCount;

  const _StatsStrip({
    required this.rating,
    required this.matches,
    required this.wins,
    required this.winrate,
    required this.tournamentsCount,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
          _item('$rating', l10n.playerStatRating, color: AppTheme.accent),
          _item('$matches', l10n.playerStatGames),
          _item('$wins', l10n.playerStatWins),
          _item('$tournamentsCount', l10n.playerStatTournaments),
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

/// Открыть аватар фуллскрином с pinch-zoom и Hero-анимацией.
/// Используется в PlayerHero и ProfileHero.
void openFullScreenAvatar(BuildContext context, String url) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) => FullScreenAvatarViewer(url: url),
    ),
  );
}

class FullScreenAvatarViewer extends StatelessWidget {
  final String url;
  const FullScreenAvatarViewer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Тап по фону закрывает
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            Center(
              child: Hero(
                tag: 'player-avatar-$url',
                child: InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 4.0,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    loadingBuilder: (_, child, progress) => progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.accent,
                              strokeWidth: 2,
                            ),
                          ),
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image,
                          color: AppTheme.textSecondary, size: 48),
                    ),
                  ),
                ),
              ),
            ),
            // Кнопка закрытия в углу
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
