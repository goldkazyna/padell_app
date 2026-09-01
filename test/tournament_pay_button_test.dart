import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/models/tournament.dart';
import 'package:padel_app/widgets/tournaments/tournament_pay_button.dart';

/// Кнопка оплаты участия: человек платит вперёд, поэтому на кнопке должно
/// быть видно сумму, способы оплаты и что будет после оплаты.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  const payment = TournamentPaymentInfo(
    required: true,
    amount: 14000,
    methods: ['card', 'apple_pay', 'google_pay'],
  );

  testWidgets('на кнопке видно сумму и способы оплаты', (tester) async {
    await tester.pumpWidget(wrap(TournamentPayButton(
      payment: payment,
      onPay: () {},
    )));

    expect(find.text('14 000 ₸'), findsOneWidget);
    // Значки платёжных систем — общий блок, тот же что на главной.
    expect(find.text('VISA'), findsOneWidget);
    expect(find.text('БЕЗОПАСНАЯ ОПЛАТА'), findsOneWidget);
    // Apple Pay и Google Pay: две подписи «Pay».
    expect(find.text('Pay'), findsNWidgets(2));
    // Главный страх «заплачу и буду ждать модерации» снимаем прямо тут.
    expect(find.textContaining('без модерации'), findsOneWidget);
  });

  testWidgets('способы берём из ответа сервера, а не рисуем всегда', (tester) async {
    await tester.pumpWidget(wrap(TournamentPayButton(
      payment: const TournamentPaymentInfo(
        required: true,
        amount: 9000,
        methods: ['card'],
      ),
      onPay: () {},
    )));

    // Без Google Pay остаётся один значок «Pay» — от Apple.
    expect(find.text('VISA'), findsOneWidget);
    expect(find.text('Pay'), findsOneWidget);
  });

  testWidgets('оплата за двоих показывает двойную сумму', (tester) async {
    var withFriend = 0;

    await tester.pumpWidget(wrap(TournamentPayButton(
      payment: payment,
      onPay: () {},
      onPayWithFriend: () => withFriend++,
    )));

    expect(find.textContaining('28 000 ₸'), findsOneWidget);

    await tester.tap(find.textContaining('28 000 ₸'));
    expect(withFriend, 1);
  });

  testWidgets('без друга второй кнопки нет', (tester) async {
    await tester.pumpWidget(wrap(TournamentPayButton(
      payment: payment,
      onPay: () {},
    )));

    expect(find.textContaining('28 000 ₸'), findsNothing);
  });

  testWidgets('тап по кнопке запускает оплату', (tester) async {
    var pays = 0;

    await tester.pumpWidget(wrap(TournamentPayButton(
      payment: payment,
      onPay: () => pays++,
    )));

    await tester.tap(find.text('14 000 ₸'));
    expect(pays, 1);
  });

  test('цена форматируется по три цифры, без копеек', () {
    expect(TournamentPayButton.formatPrice(14000), '14 000 ₸');
    expect(TournamentPayButton.formatPrice(9000.4), '9 000 ₸');
    expect(TournamentPayButton.formatPrice(500), '500 ₸');
    expect(TournamentPayButton.formatPrice(1250000), '1 250 000 ₸');
  });

  group('разбор ответа сервера', () {
    test('турнир без оплаты не приносит блок payment', () {
      final t = Tournament.fromJson(_tournamentJson());
      expect(t.payment, isNull);
    });

    test('платный турнир приносит сумму и способы', () {
      final t = Tournament.fromJson(_tournamentJson(payment: {
        'required': true,
        'amount': 14000,
        'methods': ['card', 'apple_pay', 'google_pay'],
        'provider': 'plexy',
      }));

      expect(t.payment!.required, isTrue);
      expect(t.payment!.amount, 14000);
      expect(t.payment!.hasApplePay, isTrue);
      expect(t.payment!.hasGooglePay, isTrue);
    });
  });
}

Map<String, dynamic> _tournamentJson({Map<String, dynamic>? payment}) => {
      'id': 1,
      'name': 'Американо',
      'club': {'id': 6, 'name': 'Padel Sai'},
      'date': '01.09.2026',
      'time': '19:00',
      'datetime': '2026-09-01T19:00:00+05:00',
      'type': 'americano',
      'type_name': 'Американо',
      'status': 'open',
      'status_name': 'Открыт',
      'min_level': 1.0,
      'max_level': 5.75,
      'price': 14000,
      'max_participants': 16,
      'participants_count': 4,
      'spots_left': 12,
      if (payment != null) 'payment': payment,
    };
