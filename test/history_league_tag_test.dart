import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/tournament.dart';
import 'package:padel_app/services/rating_service.dart';

/// Этап лиги в истории турниров.
///
/// Архив своего профиля этапы прятал, а в чужом профиле они были неотличимы
/// от обычных турниров. Теперь оба конца несут лигу — по ней рисуется метка.
void main() {
  Map<String, dynamic> _league() => {
        'id': 3,
        'name': 'Осенняя лига',
        'stage': 2,
        'stages_total': 8,
      };

  test('своя история: этап несёт лигу, обычный турнир — нет', () {
    final stage = Tournament.fromJson({
      'id': 1,
      'name': '2й этап ПАРНОЙ ЛИГИ',
      'club': {'id': 1, 'name': 'Davay Padel'},
      'date': '03.09.2026',
      'time': '20:00',
      'datetime': '2026-09-03T20:00:00+05:00',
      'type': 'americano',
      'type_name': 'Американо',
      'status': 'completed',
      'status_name': 'Завершён',
      'min_level': 1.0,
      'max_level': 7.0,
      'price': 15000,
      'league': _league(),
    });

    final plain = Tournament.fromJson({
      'id': 2,
      'name': 'Обычный американо',
      'club': {'id': 1, 'name': 'Davay Padel'},
      'date': '05.09.2026',
      'time': '20:00',
      'datetime': '2026-09-05T20:00:00+05:00',
      'type': 'americano',
      'type_name': 'Американо',
      'status': 'completed',
      'status_name': 'Завершён',
      'min_level': 1.0,
      'max_level': 7.0,
      'price': 15000,
    });

    expect(stage.league?.stage, 2);
    expect(stage.league?.name, 'Осенняя лига');
    expect(plain.league, isNull);
  });

  test('чужой профиль: строка истории знает про этап и место', () {
    final row = RatingHistoryItem.fromJson({
      'tournament_id': 7,
      'tournament_name': '3й этап ПАРНОЙ ЛИГИ',
      'tournament_type': 'americano',
      'date': '03.09.2026',
      'change': 20,
      'rating_after': 1500,
      'place': 2,
      'is_rated': true,
      'league': {..._league(), 'stage': 3},
    });

    expect(row.league?.stage, 3);
    expect(row.place, 2, reason: 'место как у обычного турнира');
    expect(row.change, 20);
  });

  test('чужой профиль: у обычного турнира лиги нет', () {
    final row = RatingHistoryItem.fromJson({
      'tournament_id': 8,
      'tournament_name': 'Обычный американо',
      'date': '05.09.2026',
      'change': -12,
      'rating_after': 1488,
      'place': 5,
      'is_rated': true,
    });

    expect(row.league, isNull);
    expect(row.place, 5);
  });
}
