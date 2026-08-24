import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/admin_matches.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:padel_app/screens/admin/tournament_standings_share_screen.dart';

/// В выгрузке картинкой имя игрока идёт двумя строками — как в таблицах
/// приложения. В строчку «Турсунова Лейла» растягивало колонку и жало цифры.
void main() {
  // Карточка печатает дату по-русски — без локали intl бросает исключение.
  setUpAll(() => initializeDateFormatting('ru'));

  AdminLeaderboardRow row(int position, String name) =>
      AdminLeaderboardRow.fromJson({
        'position': position,
        'id': position,
        'name': name,
        'wins': 5,
        'losses': 3,
        'draws': 1,
        'points_for': 121,
        'points_against': 95,
        'matches_played': 9,
        'total_points': 121,
      });

  Future<void> pump(WidgetTester tester, List<AdminLeaderboardRow> rows) async {
    await tester.pumpWidget(MaterialApp(
      home: TournamentStandingsShareScreen(
        tournamentId: 1,
        tournamentName: 'BRUNCH МЕКСИКАНО',
        type: 'mexicano',
        typeName: 'Мексикано',
        startDate: DateTime(2026, 8, 21),
        clubName: 'Padel Hills',
        rows: rows,
      ),
    ));
    await tester.pump();
  }

  testWidgets('имя и фамилия расходятся по строкам', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pump(tester, [row(1, 'Турсунова Лейла'), row(2, 'Bibigul N')]);

    expect(find.text('Турсунова'), findsOneWidget);
    expect(find.text('Лейла'), findsOneWidget);
    expect(find.text('Турсунова Лейла'), findsNothing);

    expect(find.text('Bibigul'), findsOneWidget);
    expect(find.text('N'), findsOneWidget);
  });

  testWidgets('имя из одного слова остаётся одной строкой', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await pump(tester, [row(1, 'Bogdan')]);

    expect(find.text('Bogdan'), findsOneWidget);
  });
}
