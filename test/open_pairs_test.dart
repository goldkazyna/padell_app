import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/models/tournament.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/tournaments/team_list_section.dart';
import 'package:provider/provider.dart';
import 'package:padel_app/providers/settings_provider.dart';
import 'package:padel_app/services/storage_service.dart';

/// Открытые пары: пустое место рядом с тем, кто записался один.
///
/// Раньше человек записывался в общий список и до старта не знал, с кем
/// играет. Теперь запись создаёт половину пары, и второй садится тапом.
Map<String, dynamic> _player(int id, String name) => {
      'id': id,
      'name': name,
      'level': '3.00',
      'rating': 3000,
    };

Tournament _tournament({
  required List<Map<String, dynamic>> teams,
  bool openPairs = true,
}) {
  return Tournament.fromJson({
    'id': 1,
    'name': 'Парный флекс',
    'club': {'id': 1, 'name': 'Davay Padel'},
    'date': '10.09.2026',
    'time': '20:00',
    'datetime': '2026-09-10T20:00:00+05:00',
    'type': 'americano_flex',
    'type_name': 'Americano Flex',
    'status': 'open',
    'status_name': 'Открыт',
    'min_level': 1.0,
    'max_level': 7.0,
    'price': 10000,
    'max_participants': 12,
    'open_pairs': openPairs,
    'max_pairs': 6,
    'teams': teams,
    'participants': const [],
  });
}

void main() {
  Widget wrap(Widget child) => MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsProvider>.value(
            value: SettingsProvider(StorageService()),
          ),
        ],
        child: MaterialApp(
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
        ),
      );

  test('пары со свободным местом отделяются от полных', () {
    final t = _tournament(teams: [
      {
        'id': 10,
        'player1': _player(1, 'Ольга'),
        'player2': null,
        'status': 'approved',
      },
      {
        'id': 11,
        'player1': _player(2, 'Борис'),
        'player2': _player(3, 'Павел'),
        'status': 'approved',
      },
    ]);

    expect(t.openPairs, isTrue);
    expect(t.maxPairs, 6);
    expect(t.openTeams.map((x) => x.id), [10]);
  });

  testWidgets('у неполной пары видно свободное место', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    TournamentTeam? tapped;

    await tester.pumpWidget(wrap(TeamListSection(
      tournament: _tournament(teams: [
        {
          'id': 10,
          'player1': _player(1, 'Ольга'),
          'player2': null,
          'status': 'approved',
        },
      ]),
      currentUserId: 99,
      onJoinPair: (team) => tapped = team,
    )));
    await tester.pump();

    expect(find.text('Свободное место — играть в этой паре'), findsOneWidget);

    await tester.tap(find.text('Свободное место — играть в этой паре'));
    await tester.pump();

    expect(tapped?.id, 10);
  });

  testWidgets('у полной пары места нет', (tester) async {
    await tester.pumpWidget(wrap(TeamListSection(
      tournament: _tournament(teams: [
        {
          'id': 11,
          'player1': _player(2, 'Борис'),
          'player2': _player(3, 'Павел'),
          'status': 'approved',
        },
      ]),
      currentUserId: 99,
      onJoinPair: (_) {},
    )));
    await tester.pump();

    expect(find.textContaining('Свободное место'), findsNothing);
  });

  testWidgets('без обработчика место не предлагаем', (tester) async {
    // Так выглядит турнир, где пары собирает клуб, — там садиться нельзя.
    await tester.pumpWidget(wrap(TeamListSection(
      tournament: _tournament(
        openPairs: false,
        teams: [
          {
            'id': 10,
            'player1': _player(1, 'Ольга'),
            'player2': null,
            'status': 'approved',
          },
        ],
      ),
      currentUserId: 99,
    )));
    await tester.pump();

    expect(find.textContaining('Свободное место'), findsNothing);
  });
}
