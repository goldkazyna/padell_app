import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/tournament.dart';

/// Пары до старта: кто уже в паре, а кто ещё нет.
///
/// В парном флексе люди записываются поодиночке, пары собирает клуб. Экран
/// показывал только общий список — человек не видел, с кем играет.
Tournament _tournament({
  required List<Map<String, dynamic>> participants,
  List<Map<String, dynamic>> teams = const [],
}) {
  return Tournament.fromJson({
    'id': 1477,
    'name': 'Парный флекс',
    'club': {'id': 1, 'name': 'Davay Padel'},
    'date': '08.09.2026',
    'time': '20:00',
    'datetime': '2026-09-08T20:00:00+05:00',
    'type': 'americano_flex',
    'type_name': 'Americano Flex',
    'status': 'open',
    'status_name': 'Открыт',
    'min_level': 1.0,
    'max_level': 7.0,
    'price': 10000,
    'max_participants': 8,
    'participants': participants,
    'teams': teams,
  });
}

Map<String, dynamic> _player(int id, String name) =>
    {'id': id, 'name': name, 'level': '3.00', 'rating': 2000, 'status': 'registered'};

void main() {
  test('без пар список остаётся целиком', () {
    final t = _tournament(participants: [
      _player(1, 'Ольга'),
      _player(2, 'Борис'),
    ]);

    expect(t.teams, isEmpty);
    expect(t.unpairedParticipants.map((p) => p.id), [1, 2]);
  });

  test('кто в паре — из списка без пары уходит', () {
    final t = _tournament(
      participants: [
        _player(1, 'Ольга'),
        _player(2, 'Борис'),
        _player(3, 'Павел'),
        _player(4, 'Николай'),
        _player(5, 'Даник'),
      ],
      teams: [
        {
          'id': 10,
          'player1': _player(1, 'Ольга'),
          'player2': _player(2, 'Борис'),
          'status': 'approved',
        },
        {
          'id': 11,
          'player1': _player(3, 'Павел'),
          'player2': _player(4, 'Николай'),
          'status': 'approved',
        },
      ],
    );

    expect(t.teams, hasLength(2));
    // Пятый остался без пары — его и покажем отдельным блоком.
    expect(t.unpairedParticipants.map((p) => p.id), [5]);
  });

  test('неполная пара не съедает второго игрока', () {
    final t = _tournament(
      participants: [_player(1, 'Ольга'), _player(2, 'Борис')],
      teams: [
        {
          'id': 10,
          'player1': _player(1, 'Ольга'),
          'player2': null,
          'status': 'pending',
        },
      ],
    );

    expect(t.unpairedParticipants.map((p) => p.id), [2]);
  });
}
