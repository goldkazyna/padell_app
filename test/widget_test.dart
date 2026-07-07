import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/user.dart';

void main() {
  group('User model', () {
    test('fromJson creates user correctly', () {
      final json = {
        'id': 4,
        'name': 'Денис Казына',
        'phone': '77774333822',
        'avatar': null,
        'rating': 2625,
        'level': '2.50',
        'level_name': 'Любитель',
      };

      final user = User.fromJson(json);

      expect(user.id, 4);
      expect(user.name, 'Денис Казына');
      expect(user.initials, 'ДК');
      expect(user.rating, 2625);
    });

    test('formattedPhone formats correctly', () {
      final user = User(
        id: 1,
        name: 'Test User',
        phone: '77774333822',
        rating: 1000,
        level: '2.50',
        levelName: 'Test',
      );

      expect(user.formattedPhone, '+7 777 433 38 22');
    });
  });
}
