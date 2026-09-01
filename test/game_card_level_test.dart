import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/game.dart';

/// Уровень игры в карточке: игру видно всем, поэтому строка про уровень
/// должна читаться при любых границах, а несовпадение — приходить с сервера.
void main() {
  Game game(Map<String, dynamic> extra) => Game.fromJson({
        'id': 1,
        'creator_id': 2,
        'starts_at': '2026-09-05T19:00:00+05:00',
        'type': 'friendly',
        'visibility': 'public',
        'format': 'sets',
        'capacity': 4,
        'status': 'open',
        'players': const [],
        ...extra,
      });

  test('обе границы — диапазон', () {
    expect(game({'rating_min': 2.0, 'rating_max': 3.5}).levelText, '2.0 – 3.5');
  });

  test('одна граница — «от» или «до»', () {
    expect(game({'rating_min': 2.0}).levelText, 'От 2.0');
    expect(game({'rating_max': 3.5}).levelText, 'До 3.5');
  });

  test('без границ — любой уровень, а не пустой прочерк', () {
    expect(game({}).levelText, 'Любой уровень');
  });

  test('несовпадение уровня приходит с сервера', () {
    expect(game({'level_matches': false}).levelMatches, isFalse);
    // Поля нет (старый ответ) — считаем, что подходит: пугать зря не надо.
    expect(game({}).levelMatches, isTrue);
  });
}
