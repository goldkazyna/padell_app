import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../theme/app_theme.dart';
import 'medal.dart';

/// Медаль с подписью — то, из чего собраны и лента в профиле, и экран «Все».
///
/// У незакрытой под названием стоит счёт «8 / 10»: цель тянет только тогда,
/// когда видно, сколько осталось.
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showProgress = true,
    this.width = 84,
    this.medalSize = 64,
    this.onTap,
  });

  final Achievement achievement;

  /// На чужой карточке незакрытых нет вовсе, счёт там не нужен.
  final bool showProgress;

  final double width;
  final double medalSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Medal(achievement: achievement, size: medalSize),
            const SizedBox(height: 9),
            Text(
              achievement.title,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: unlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 10.5,
                height: 1.25,
                fontWeight: unlocked ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (!unlocked && showProgress) ...[
              const SizedBox(height: 3),
              Text(
                '${achievement.progress} / ${achievement.target}',
                style: TextStyle(color: AppTheme.textDim, fontSize: 9.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
