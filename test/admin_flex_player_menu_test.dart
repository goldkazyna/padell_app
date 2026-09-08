import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/admin_flex_pairs.dart';
import 'package:padel_app/models/admin_participant.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/admin/admin_flex_player_menu.dart';

/// Меню игрока в сетке пар: шторка по содержимому, а не во весь экран.
///
/// Пунктов «пересадить» бывает под двадцать, и простыня на весь экран
/// читалась как бесконечный список без начала и конца.
Map<String, dynamic> _user(int id, String name, {String status = 'registered'}) => {
      'id': id,
      'name': name,
      'level': 3.0,
      'rating': 2000 + id,
      'status': status,
    };

AdminFlexPairs _grid({int max = 6}) => AdminFlexPairs.fromJson({
      'max_pairs': max,
      'pairs': [
        {
          'id': 1,
          'position': 1,
          'rating_avg': 2100,
          'player1': _user(1, 'Ержан'),
          'player2': _user(2, 'Данияр'),
        },
        {
          'id': 2,
          'position': 2,
          'rating_avg': 2200,
          'player1': _user(3, 'Марат'),
          'player2': null,
        },
      ],
    });

void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 600),
              child: child,
            ),
          ),
        ),
      );

  testWidgets('меню показывает статус, пересадку и удаление', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    FlexPlayerAction? action;
    FlexSeatTarget? seat;

    await tester.pumpWidget(wrap(AdminFlexPlayerMenuBody(
      player: AdminParticipant.fromJson(_user(9, 'Асель')),
      pairs: _grid(),
      onAction: (a) => action = a,
      onSeat: (t) => seat = t,
    )));
    await tester.pump();

    // Шапка говорит, кого двигаем.
    expect(find.text('Асель'), findsOneWidget);
    expect(find.text('в составе, без пары'), findsOneWidget);

    expect(find.text('На модерацию'), findsOneWidget);
    expect(find.text('В лист ожидания'), findsOneWidget);
    expect(find.text('Открыть новую пару'), findsOneWidget);
    expect(find.text('Пара 2 · свободное место'), findsOneWidget);
    expect(find.text('Пара 1 · вместо: Ержан'), findsOneWidget);

    await tester.tap(find.text('Пара 2 · свободное место'));
    await tester.pump();
    expect(seat?.teamId, 2);
    expect(seat?.seat, 2);

    await tester.tap(find.text('В лист ожидания'));
    await tester.pump();
    expect(action, FlexPlayerAction.toWaiting);
  });

  testWidgets('заявке предлагаем одобрение, а не модерацию', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(AdminFlexPlayerMenuBody(
      player: AdminParticipant.fromJson(_user(9, 'Асель', status: 'pending')),
      pairs: _grid(),
      onAction: (_) {},
      onSeat: (_) {},
    )));
    await tester.pump();

    expect(find.text('Одобрить заявку'), findsOneWidget);
    expect(find.text('На модерацию'), findsNothing);
    expect(find.text('на модерации, без пары'), findsOneWidget);
  });

  testWidgets('свою же пару в пересадках не предлагаем', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(AdminFlexPlayerMenuBody(
      // Данияр сидит в первой паре.
      player: AdminParticipant.fromJson(_user(2, 'Данияр')),
      pairs: _grid(),
      onAction: (_) {},
      onSeat: (_) {},
    )));
    await tester.pump();

    expect(find.text('в составе, пара 1'), findsOneWidget);
    expect(find.text('Пара 1 · вместо: Ержан'), findsNothing);
    expect(find.text('Пара 2 · свободное место'), findsOneWidget);
  });

  testWidgets('когда сетка полна, новую пару не предлагаем', (tester) async {
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(AdminFlexPlayerMenuBody(
      player: AdminParticipant.fromJson(_user(9, 'Асель')),
      pairs: _grid(max: 2),
      onAction: (_) {},
      onSeat: (_) {},
    )));
    await tester.pump();

    expect(find.text('Открыть новую пару'), findsNothing);
  });
}
