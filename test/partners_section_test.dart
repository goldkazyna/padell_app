import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/services/profile_service.dart';

/// Разбор ответа «с кем играю» и склонения в подписи блока.
void main() {
  test('лучший партнёр и топ разбираются из ответа', () {
    final data = PlayerPartners.fromJson({
      'partners_count': 4,
      'best': {
        'user_id': 21,
        'name': 'Андрей Кузнецов',
        'avatar': 'https://x/a.png',
        'games': 12,
        'wins': 9,
        'losses': 3,
        'draws': 0,
        'winrate': 75,
      },
      'top': [
        {'user_id': 21, 'name': 'Андрей Кузнецов', 'games': 12, 'wins': 9, 'winrate': 75},
        {'user_id': 33, 'name': 'София', 'games': 6, 'wins': 3, 'winrate': 50},
      ],
    });

    expect(data.best!.userId, 21);
    expect(data.best!.games, 12);
    expect(data.best!.wins, 9);
    expect(data.best!.winrate, 75);
    expect(data.partnersCount, 4);
    expect(data.top.length, 2);
  });

  test('без партнёров ответ пустой, а не падает', () {
    final data = PlayerPartners.fromJson({'partners_count': 0, 'best': null});

    expect(data.best, isNull);
    expect(data.top, isEmpty);
    expect(data.partnersCount, 0);
  });
}
