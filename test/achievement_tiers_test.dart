import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/achievement.dart';
import 'package:padel_app/widgets/achievements/medal_art.dart';

/// Экран достижений разложен по сложности: цвет медали и был вопросом
/// игроков, поэтому он стал заголовком раздела.
void main() {
  test('разделы идут от простого к редкому', () {
    expect(achievementTiers.keys.toList(), ['bronze', 'silver', 'gold']);
  });

  test('у каждой сложности есть объяснение', () {
    for (final entry in achievementTiers.entries) {
      expect(entry.value.trim(), isNotEmpty, reason: 'сложность ${entry.key} без подписи');
    }
  });

  test('значок знает свою сложность и долю обладателей', () {
    final a = Achievement.fromJson({
      'code': 'gold_3',
      'title': 'Трижды первый',
      'description': 'Выиграть три турнира',
      'group': 'wins',
      'tier': 'gold',
      'progress': 2,
      'target': 3,
      'rarity': 1,
    });

    expect(a.tier, 'gold');
    expect(a.rarity, 1);
    expect(a.isUnlocked, isFalse);
    expect(a.progressRatio, closeTo(0.666, 0.01));
  });

  test('значки за мячи выбиты числом', () {
    // Гравировка у них числовая, как у «5 / 10 / 50 турниров».
    expect(medalNumbers['points_500'], '500');
    expect(medalNumbers['points_1700'], '1.7K');
    expect(medalNumbers['points_5000'], '5K');
  });

  test('группа «Мячи» есть в списке групп', () {
    expect(achievementGroups['scoring'], 'Мячи');
  });
}
