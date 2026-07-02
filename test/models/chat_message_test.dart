import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/chat_message.dart';

void main() {
  test('ChatMessage.fromJson парсит все поля', () {
    final m = ChatMessage.fromJson({
      'id': 123,
      'user': {'id': 7, 'name': 'Иван', 'avatar': 'u', 'level': '3.5'},
      'text': 'Кто на 19:00?',
      'is_admin': true,
      'is_mine': false,
      'created_at': '2026-07-01T12:00:00Z',
    });
    expect(m.id, 123);
    expect(m.user.name, 'Иван');
    expect(m.user.level, '3.5');
    expect(m.text, 'Кто на 19:00?');
    expect(m.isAdmin, true);
    expect(m.isMine, false);
    expect(m.createdAt, isNotNull);
  });

  test('ChatMessage.fromJson терпит отсутствующие поля', () {
    final m = ChatMessage.fromJson({'id': 1, 'user': {'id': 2, 'name': 'A'}, 'text': ''});
    expect(m.isAdmin, false);
    expect(m.isMine, false);
    expect(m.user.avatar, isNull);
    expect(m.createdAt, isNull);
  });
}
