import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/widgets/flex_standings_table.dart';
import 'package:padel_app/widgets/standings_bits.dart';

/// Турнирная таблица должна оставаться читаемой при крупном системном
/// шрифте: людям с увеличенным текстом имя схлопывалось в «B… N», а
/// заголовок «ИГРОК» переносился по слогам.
void main() {
  final leaderboard = [
    {
      'position': 1,
      'id': 1,
      'name': 'Константин Верещагин',
      'wins': 5,
      'losses': 3,
      'draws': 1,
      'points_for': 121,
      'points_against': 95,
      'matches_played': 9,
      'total_points': 121,
    },
    {
      'position': 2,
      'id': 2,
      'name': 'Bibigul N',
      'wins': 4,
      'losses': 4,
      'draws': 1,
      'points_for': 110,
      'points_against': 108,
      'matches_played': 9,
      'total_points': 110,
    },
  ];

  Widget harness(double scale, double width) => MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(scale)),
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: width,
              child: FlexStandingsTable(leaderboard: leaderboard),
            ),
          ),
        ),
      );

  testWidgets('при крупном шрифте таблица прокручивается вбок', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness(1.6, 360));
    await tester.pumpAndSettle();

    // Ошибок переполнения быть не должно — иначе тест упал бы сам.
    final scroll = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView).first,
    );
    expect(scroll.scrollDirection, Axis.horizontal);
  });

  testWidgets('имя показывается целиком, обеими строками', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(harness(1.6, 360));
    await tester.pumpAndSettle();

    expect(find.text('Константин'), findsOneWidget);
    expect(find.text('Верещагин'), findsOneWidget);
    expect(find.text('Bibigul'), findsOneWidget);
    expect(find.text('N'), findsOneWidget);
  });

  testWidgets('легенда не растягивает полотно прокрутки', (tester) async {
    // Внутри горизонтального скролла ширина не ограничена, и Wrap легенды
    // разворачивается в одну строку — справа от таблицы появляется пустота.
    await tester.pumpWidget(harness(1.0, 360));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(StandingsLegend),
      ),
      findsNothing,
      reason: 'легенда должна быть под прокруткой, а не внутри неё',
    );
  });

  testWidgets('заголовки колонок не переносятся', (tester) async {
    await tester.pumpWidget(harness(1.6, 360));
    await tester.pumpAndSettle();

    for (final letter in ['В', 'П', 'Н', 'З', 'Пр', '±']) {
      expect(find.text(letter), findsOneWidget, reason: 'колонка $letter');
    }
    // Процента в таблице больше нет — он путал людей.
    expect(find.text('%'), findsNothing);
  });
}
