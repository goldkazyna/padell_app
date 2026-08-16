import 'package:flutter/material.dart';
import '../../models/achievement.dart';
import '../../theme/app_theme.dart';
import 'medal.dart';
import 'medal_art.dart';

/// Что значит медаль и за что её дают.
///
/// Открывается по тапу на любую медаль — и на своём профиле, и на чужой
/// карточке. Значок без объяснения выглядит случайной картинкой; здесь он
/// становится наградой с понятным условием.
void showAchievementSheet(BuildContext context, Achievement achievement) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _AchievementSheet(achievement: achievement),
  );
}

class _AchievementSheet extends StatelessWidget {
  const _AchievementSheet({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    final metal = MedalMetal.of(achievement.tier);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppTheme.textDim.withAlpha(90),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Свет за медалью — она главный предмет на этом экране.
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  (unlocked ? metal.light : AppTheme.textDim).withAlpha(38),
                  Colors.transparent,
                ],
              ),
            ),
            child: Medal(achievement: achievement, size: 104),
          ),

          const SizedBox(height: 14),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              letterSpacing: -.2,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            MedalMetal.nameOf(achievement.tier).toUpperCase(),
            style: TextStyle(
              color: unlocked ? metal.light : AppTheme.textDim,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),

          const SizedBox(height: 14),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13.5,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _cell(
                  unlocked ? 'Получено' : 'Прогресс',
                  unlocked
                      ? _date(achievement.unlockedAt!)
                      : '${achievement.progress} / ${achievement.target}',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _cell(
                  'Условие',
                  '${achievement.target}',
                ),
              ),
            ],
          ),

          if (achievement.rarity != null) ...[
            const SizedBox(height: 14),
            Text(
              'Есть у ${achievement.rarity}% игроков',
              style: TextStyle(
                color: AppTheme.amber,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _cell(String key, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            key.toUpperCase(),
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  static const _months = [
    'янв', 'фев', 'мар', 'апр', 'мая', 'июн',
    'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
  ];

  String _date(DateTime d) => '${d.day} ${_months[d.month - 1]}';
}
