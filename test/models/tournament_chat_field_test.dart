import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/tournament.dart';

Map<String, dynamic> _baseJson() => {
      'id': 1, 'name': 'T', 'club': {'id': 1, 'name': 'C'},
      'date': '2026-07-01', 'time': '19:00',
      'datetime': '2026-07-01T19:00:00Z',
      'type': 'americano', 'type_name': 'Американо',
      'status': 'open', 'status_name': 'Открыт',
      'min_level': 1.0, 'max_level': 5.0, 'price': 0,
      'max_participants': 8, 'participants_count': 0,
    };

void main() {
  test('Tournament.chat парсится из блока chat', () {
    final json = _baseJson()
      ..['chat'] = {'enabled': true, 'can_read': true, 'unread_count': 2};
    final t = Tournament.fromJson(json);
    expect(t.chat, isNotNull);
    expect(t.chat!.canRead, true);
    expect(t.chat!.unreadCount, 2);
  });

  test('Tournament.chat == null если блока нет', () {
    final t = Tournament.fromJson(_baseJson());
    expect(t.chat, isNull);
  });
}
