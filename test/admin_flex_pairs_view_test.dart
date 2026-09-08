import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/admin_flex_pairs.dart';
import 'package:padel_app/models/admin_participant.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/admin/admin_flex_pairs_view.dart';

/// Состав парного флекса в админке: сетка вместо плоского списка.
///
/// Место в таком турнире — это место в паре, и организатору нужно видеть всю
/// сетку сразу: где сидят, где свободно, кто остался без места.
Map<String, dynamic> _user(int id, String name, {String status = 'registered'}) => {
      'id': id,
      'name': name,
      'level': 3.0,
      'rating': 2000 + id,
      'status': status,
    };

void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: SingleChildScrollView(child: child),
        ),
      );

  AdminFlexPairs pairs({required List<Map<String, dynamic>> rows, int max = 3}) =>
      AdminFlexPairs.fromJson({'max_pairs': max, 'pairs': rows});

  testWidgets('рисуются занятые, неполные и пустые пары', (tester) async {
    tester.view.physicalSize = const Size(430, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(AdminFlexPairsView(
      pairs: pairs(rows: [
        {
          'id': 1,
          'position': 1,
          'rating_avg': 2500,
          'player1': _user(1, 'Ержан'),
          'player2': _user(2, 'Данияр'),
        },
        {
          'id': 2,
          'position': 2,
          'rating_avg': 2100,
          'player1': _user(3, 'Марат'),
          'player2': null,
        },
      ]),
      participants: [
        AdminParticipant.fromJson(_user(1, 'Ержан')),
        AdminParticipant.fromJson(_user(2, 'Данияр')),
        AdminParticipant.fromJson(_user(3, 'Марат')),
        AdminParticipant.fromJson(_user(4, 'Асель')),
        AdminParticipant.fromJson(_user(5, 'Тимур', status: 'waiting')),
      ],
      maxParticipants: 6,
      canModify: true,
      onFillSeat: (_) {},
      onOpenNewPair: () {},
      onPlayerMenu: (_) {},
      onDisbandPair: (_) {},
      onSeatPlayer: (_) {},
    )));
    await tester.pump();

    expect(find.text('пар 2 / 3'), findsOneWidget);
    // Ожидающие в состав не считаются: их место ещё не занято.
    expect(find.text('игроков 4 / 6'), findsOneWidget);
    expect(find.text('Посадить второго'), findsOneWidget);
    expect(find.text('Открыть пару'), findsOneWidget, reason: 'третья строка пустая');
    expect(find.text('Без пары'), findsOneWidget);
    expect(find.text('Лист ожидания'), findsOneWidget);
    expect(find.text('Асель'), findsOneWidget);
  });

  testWidgets('свободное место и меню игрока вызывают действия', (tester) async {
    tester.view.physicalSize = const Size(430, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    AdminFlexPair? filled;
    AdminParticipant? menuFor;
    AdminParticipant? seated;

    await tester.pumpWidget(wrap(AdminFlexPairsView(
      pairs: pairs(max: 2, rows: [
        {
          'id': 7,
          'position': 1,
          'rating_avg': 2100,
          'player1': _user(3, 'Марат'),
          'player2': null,
        },
      ]),
      participants: [
        AdminParticipant.fromJson(_user(3, 'Марат')),
        AdminParticipant.fromJson(_user(4, 'Асель')),
      ],
      maxParticipants: 4,
      canModify: true,
      onFillSeat: (pair) => filled = pair,
      onOpenNewPair: () {},
      onPlayerMenu: (p) => menuFor = p,
      onDisbandPair: (_) {},
      onSeatPlayer: (p) => seated = p,
    )));
    await tester.pump();

    await tester.tap(find.text('Посадить второго'));
    await tester.pump();
    expect(filled?.id, 7);

    await tester.tap(find.text('Марат'));
    await tester.pump();
    expect(menuFor?.id, 3);

    await tester.tap(find.text('посадить'));
    await tester.pump();
    expect(seated?.id, 4, reason: 'быстрая посадка из пула');
  });

  testWidgets('без прав ничего не нажимается', (tester) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    var touched = false;

    await tester.pumpWidget(wrap(AdminFlexPairsView(
      pairs: pairs(max: 1, rows: [
        {
          'id': 7,
          'position': 1,
          'rating_avg': 2100,
          'player1': _user(3, 'Марат'),
          'player2': null,
        },
      ]),
      participants: [AdminParticipant.fromJson(_user(3, 'Марат'))],
      maxParticipants: 2,
      canModify: false,
      onFillSeat: (_) => touched = true,
      onOpenNewPair: () => touched = true,
      onPlayerMenu: (_) => touched = true,
      onDisbandPair: (_) => touched = true,
      onSeatPlayer: (_) => touched = true,
    )));
    await tester.pump();

    expect(find.text('Место свободно'), findsOneWidget);
    await tester.tap(find.text('Место свободно'));
    await tester.tap(find.text('Марат'));
    await tester.pump();
    expect(touched, isFalse);
  });
}
