import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/admin_matches.dart';

/// Матчи раунда показывают лица, а не только имена.
///
/// В раунде подряд идут «Тест #5 / София» и «Тест #9 / Тест #8» — одинаковые
/// строки не отличить, поэтому в строке команды нужны аватары.
void main() {
  test('в команде матча есть игроки с аватарами', () {
    final team = AdminMatchTeam.fromJson({
      'players': [
        {'id': 1, 'name': 'Денис Дудников', 'initials': 'ДД', 'avatar_url': 'https://x/1.webp'},
        {'id': 2, 'name': 'Марина Дудникова', 'initials': 'МД', 'avatar_url': null},
      ],
      'score': 12,
    });

    expect(team.players.length, 2);
    expect(team.players.first.avatarUrl, 'https://x/1.webp');
    // У кого фото нет — рисуем инициалы, поле остаётся пустым.
    expect(team.players.last.avatarUrl, isNull);
    expect(team.title, 'Денис Дудников / Марина Дудникова');
  });
}
