import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/admin_participant.dart';

/// Куда пишет организатор из админки.
///
/// Раньше кнопка «WhatsApp» всегда вела на телефон входа — а он логин, и не
/// всегда тот, где человек читает сообщения. Если игрок указал свой номер
/// WhatsApp в профиле, пишем на него.
AdminParticipant _player({String? phone, String? whatsapp}) =>
    AdminParticipant.fromJson({
      'id': 1,
      'name': 'Денис Дудников',
      'phone': phone,
      'whatsapp': whatsapp,
    });

void main() {
  test('указанный WhatsApp важнее телефона входа', () {
    final p = _player(phone: '77771112233', whatsapp: '77774333822');

    expect(p.whatsappNumber, '77774333822');
  });

  test('нет своего — пишем на телефон аккаунта', () {
    expect(_player(phone: '77771112233').whatsappNumber, '77771112233');
  });

  test('пустая строка не считается указанным номером', () {
    final p = _player(phone: '77771112233', whatsapp: '   ');

    expect(p.whatsappNumber, '77771112233');
  });

  test('нет ни того, ни другого — писать некуда', () {
    expect(_player().whatsappNumber, isNull);
    expect(_player(phone: '').whatsappNumber, isNull);
  });
}
