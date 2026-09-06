import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/services/profile_service.dart';

/// Вся динамика рейтинга: разбор ответа и свод.
///
/// В карточке профиля видно последние десять точек, дальше история
/// обрывалась. Экран показывает её целиком.
void main() {
  Map<String, dynamic> _response() => {
        'success': true,
        'points': [
          {
            'tournament_id': 1,
            'name': 'Американо',
            'club_name': 'Padel Sai',
            'date': '1 сент 2026',
            'rating': 1010,
            'delta': null,
          },
          {
            'tournament_id': 2,
            'name': 'Мексикано',
            'club_name': 'Davay Padel',
            'date': '3 сент 2026',
            'rating': 1080,
            'delta': 70,
          },
          {
            'tournament_id': null,
            'name': 'Списание за простой',
            'club_name': 'Padel Kz',
            'date': '5 ноя 2026',
            'rating': 1030,
            'delta': -50,
          },
        ],
        'summary': {
          'total': 3,
          'current': 1030,
          'start': 1010,
          'best': 1080,
          'worst': 1010,
        },
      };

  test('точки и свод разбираются', () {
    final data = RatingHistoryData.fromJson(_response());

    expect(data.points, hasLength(3));
    expect(data.current, 1030);
    expect(data.start, 1010);
    expect(data.best, 1080);
    expect(data.worst, 1010);
    // Изменение за всё время считается, а не приходит с сервера.
    expect(data.total, 20);
  });

  test('списание за простой — точка без турнира', () {
    final data = RatingHistoryData.fromJson(_response());
    final decay = data.points.last;

    expect(decay.tournamentId, isNull);
    expect(decay.name, 'Списание за простой');
    expect(decay.delta, -50);
  });

  test('пустая история не ломает свод', () {
    final data = RatingHistoryData.fromJson({
      'success': true,
      'points': <dynamic>[],
      'summary': {'total': 0, 'current': 1125, 'start': 1125, 'best': 1125, 'worst': 1125},
    });

    expect(data.points, isEmpty);
    expect(data.total, 0);
    expect(data.current, 1125);
  });
}
