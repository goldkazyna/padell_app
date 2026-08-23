import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/club_card.dart';

/// Описание карты приходит свободным текстом от клуба: клуб набирает
/// условия строками, а экран карты показывает их отдельными пунктами.
void main() {
  ClubCard cardWith(String? description) => ClubCard.fromJson({
        'id': 1,
        'code': 'VIP000001',
        'type_name': '10 часов',
        'description': description,
      });

  test('строки описания становятся отдельными пунктами', () {
    final card = cardWith('10 часов корта\nАренда ракетки\nМожно с гостем');

    expect(card.benefits, ['10 часов корта', 'Аренда ракетки', 'Можно с гостем']);
  });

  test('пустые строки и отступы не создают пустых пунктов', () {
    final card = cardWith('  Первый пункт  \n\n\n   \nВторой пункт\n');

    expect(card.benefits, ['Первый пункт', 'Второй пункт']);
  });

  test('перенос из Windows-редактора не оставляет возврат каретки', () {
    final card = cardWith('Первый\r\nВторой');

    expect(card.benefits, ['Первый', 'Второй']);
  });

  test('без описания блок пустой — экран его не покажет', () {
    expect(cardWith(null).benefits, isEmpty);
    expect(cardWith('').benefits, isEmpty);
    expect(cardWith('   \n  ').benefits, isEmpty);
  });

  test('описание из одной строки — один пункт', () {
    expect(cardWith('Безлимит по будням до 17:00').benefits,
        ['Безлимит по будням до 17:00']);
  });
}
