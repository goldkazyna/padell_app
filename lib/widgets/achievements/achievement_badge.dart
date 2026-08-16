import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../theme/app_theme.dart';

/// Иконки значков по имени с сервера.
///
/// Карта явная, а не динамический доступ: динамика ломает tree shaking,
/// и в сборку уехал бы весь набор Material-иконок.
const _icons = <String, IconData>{
  'emoji_events': Icons.emoji_events,
  'flag': Icons.flag,
  'calendar_month': Icons.calendar_month,
  'workspace_premium': Icons.workspace_premium,
  'military_tech': Icons.military_tech,
  'bolt': Icons.bolt,
  'shield': Icons.shield,
  'trending_up': Icons.trending_up,
  'star': Icons.star,
  'explore': Icons.explore,
  'auto_awesome': Icons.auto_awesome,
  'location_city': Icons.location_city,
  'handshake': Icons.handshake,
};

/// Цвета по группам: у каждой своей смысл, поэтому и оттенок свой.
const _groupColors = <String, Color>{
  'first_steps': Color(0xFF4A8BF5),
  'wins': Color(0xFFEAB34E),
  'rating': Color(0xFF22C47A),
  'variety': Color(0xFFA89CF5),
  'together': Color(0xFFF08446),
};

/// Карточка значка.
///
/// Полученный — цветной. Неполученный — приглушённый, с полоской прогресса:
/// человек должен видеть, сколько осталось, иначе цель не тянет.
class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    super.key,
    required this.achievement,
    this.showProgress = true,
    this.width = 96,
  });

  final Achievement achievement;

  /// Показывать ли полоску и счётчик у неполученных. На чужой карточке
  /// неполученных нет вовсе, там это не нужно.
  final bool showProgress;

  final double width;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    final color = _groupColors[achievement.group] ?? AppTheme.accent;
    final icon = _icons[achievement.icon] ?? Icons.emoji_events;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: unlocked ? color.withAlpha(38) : AppTheme.cardRaised,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: unlocked ? color.withAlpha(120) : Colors.transparent,
              ),
            ),
            child: Icon(
              icon,
              size: 26,
              color: unlocked ? color : AppTheme.textDim,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.title,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: unlocked ? AppTheme.textPrimary : AppTheme.textSecondary,
              fontSize: 11,
              height: 1.25,
              fontWeight: unlocked ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (!unlocked && showProgress) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: achievement.progressRatio,
                minHeight: 4,
                backgroundColor: AppTheme.cardRaised,
                valueColor: AlwaysStoppedAnimation(color.withAlpha(150)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${achievement.progress} / ${achievement.target}',
              style: TextStyle(color: AppTheme.textDim, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}
