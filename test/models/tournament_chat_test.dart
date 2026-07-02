import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/tournament_chat.dart';

void main() {
  test('TournamentChat.fromJson парсит capabilities', () {
    final c = TournamentChat.fromJson({
      'enabled': true,
      'write_mode': 'participants',
      'can_read': true,
      'can_write': true,
      'is_admin': false,
      'unread_count': 3,
    });
    expect(c.enabled, true);
    expect(c.writeMode, 'participants');
    expect(c.canRead, true);
    expect(c.canWrite, true);
    expect(c.isAdmin, false);
    expect(c.unreadCount, 3);
  });

  test('TournamentChat.fromJson дефолты при пустом объекте', () {
    final c = TournamentChat.fromJson(const {});
    expect(c.enabled, false);
    expect(c.writeMode, 'participants');
    expect(c.canRead, false);
    expect(c.unreadCount, 0);
  });
}
