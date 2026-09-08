import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/models/tournament.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/tournaments/pairs_grid.dart';

/// Сетка пар: турнир виден целиком, включая пустые пары.
///
/// Раньше показывался список записавшихся, и человек не понимал, куда
/// садиться. Теперь 16 мест — это восемь пар, и свободное место кликабельно.
Map<String, dynamic> _player(int id, String name) => {
      'id': id,
      'name': name,
      'level': 1.75,
      'rating': 1875,
    };

Tournament _tournament({
  required List<Map<String, dynamic>> teams,
  int maxPairs = 8,
  int seats = 16,
}) {
  return Tournament.fromJson({
    'id': 1480,
    'name': 'Парный флекс',
    'club': {'id': 1, 'name': 'Padel Hills'},
    'date': '23.09.2026',
    'time': '23:56',
    'datetime': '2026-09-23T23:56:00+05:00',
    'type': 'americano_flex',
    'type_name': 'Americano Flex',
    'status': 'open',
    'status_name': 'Открыт',
    'min_level': 1.0,
    'max_level': 5.75,
    'price': 0,
    'max_participants': seats,
    'open_pairs': true,
    'max_pairs': maxPairs,
    'teams': teams,
    'participants': const [],
  });
}

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
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: SingleChildScrollView(child: child),
        ),
      );

  testWidgets('рисуются все пары турнира, а не только занятые',
      (tester) async {
    tester.view.physicalSize = const Size(390, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap(PairsGrid(
      tournament: _tournament(maxPairs: 4, seats: 8, teams: [
        {
          'id': 10,
          'player1': _player(1, 'Евгения'),
          'player2': null,
          'status': 'approved',
        },
        {
          'id': 11,
          'player1': _player(2, 'Борис С'),
          'player2': _player(3, 'Даник М'),
          'status': 'approved',
        },
      ]),
      currentUserId: 99,
      onJoinTeam: (_) {},
      onTakeEmpty: () {},
    )));
    await tester.pump();

    expect(find.text('2 / 4'), findsOneWidget);
    expect(find.text('Евгения'), findsOneWidget);
    // Одна пара занята наполовину, семь пустых: 1 + 14 свободных мест.
    // Две пары пустые целиком плюс место рядом с Евгенией.
    expect(find.text('Свободно'), findsNWidgets(4));
    expect(find.text('Свободно — играть с Евгения'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/pairs_grid.png'),
    );
  });

  testWidgets('тап по месту рядом с игроком садит в его пару', (tester) async {
    tester.view.physicalSize = const Size(390, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    TournamentTeam? joined;
    var tookEmpty = false;

    await tester.pumpWidget(wrap(PairsGrid(
      tournament: _tournament(
        maxPairs: 2,
        seats: 4,
        teams: [
          {
            'id': 10,
            'player1': _player(1, 'Евгения'),
            'player2': null,
            'status': 'approved',
          },
        ],
      ),
      currentUserId: 99,
      onJoinTeam: (team) => joined = team,
      onTakeEmpty: () => tookEmpty = true,
    )));
    await tester.pump();

    await tester.tap(find.text('Свободно — играть с Евгения'));
    await tester.pump();
    expect(joined?.id, 10);
    expect(tookEmpty, isFalse);

    await tester.tap(find.text('Свободно').first);
    await tester.pump();
    expect(tookEmpty, isTrue, reason: 'пустая пара — своя новая');
  });

  testWidgets('тап по игроку открывает его профиль', (tester) async {
    // В сетке видно соперников, и первое желание — посмотреть, кто это.
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    TournamentTeamPlayer? tapped;

    await tester.pumpWidget(wrap(PairsGrid(
      tournament: _tournament(
        maxPairs: 2,
        seats: 4,
        teams: [
          {
            'id': 10,
            'player1': _player(1, 'Евгения'),
            'player2': _player(2, 'Борис С'),
            'status': 'approved',
          },
        ],
      ),
      currentUserId: 99,
      onJoinTeam: (_) {},
      onTakeEmpty: () {},
      onPlayerTap: (p) => tapped = p,
    )));
    await tester.pump();

    await tester.tap(find.text('Борис С'));
    await tester.pump();
    expect(tapped?.id, 2);

    await tester.tap(find.text('Евгения'));
    await tester.pump();
    expect(tapped?.id, 1, reason: 'жмётся каждый игрок пары');
  });

  testWidgets('в своей паре место рядом не предлагается', (tester) async {
    tester.view.physicalSize = const Size(390, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    var joined = false;

    await tester.pumpWidget(wrap(PairsGrid(
      tournament: _tournament(
        maxPairs: 1,
        seats: 2,
        teams: [
          {
            'id': 10,
            'player1': _player(99, 'Я'),
            'player2': null,
            'status': 'approved',
          },
        ],
      ),
      currentUserId: 99,
      onJoinTeam: (_) => joined = true,
      onTakeEmpty: () {},
    )));
    await tester.pump();

    await tester.tap(find.textContaining('Свободно'));
    await tester.pump();

    expect(joined, isFalse, reason: 'сам к себе не садится');
  });
}
