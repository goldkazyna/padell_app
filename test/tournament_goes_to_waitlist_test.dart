import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/tournament.dart';

/// Кнопка записи должна знать заранее, что состав полон: иначе человек жмёт
/// «Записаться», а попадает в очередь и узнаёт об этом уже из сообщения.
Map<String, dynamic> _json({bool? full}) => {
      'id': 1488,
      'name': 'Парный флекс',
      'club': {'id': 1, 'name': 'Padel Hills'},
      'date': '23.09.2026',
      'time': '20:00',
      'datetime': '2026-09-23T20:00:00+05:00',
      'type': 'americano_flex',
      'type_name': 'Americano Flex',
      'status': 'open',
      'status_name': 'Открыт',
      'min_level': 1.0,
      'max_level': 5.75,
      'price': 0,
      'max_participants': 12,
      'open_pairs': true,
      'can_register': true,
      if (full != null) 'goes_to_waitlist': full,
    };

void main() {
  test('goes_to_waitlist разбирается из ответа', () {
    expect(Tournament.fromJson(_json(full: true)).goesToWaitlist, isTrue);
    expect(Tournament.fromJson(_json(full: false)).goesToWaitlist, isFalse);
    // Старый бэкенд поля не отдаёт — считаем запись обычной.
    expect(Tournament.fromJson(_json()).goesToWaitlist, isFalse);
  });
}
