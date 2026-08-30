import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:padel_app/models/league.dart';
import 'package:padel_app/widgets/flex_standings_table.dart';
import 'package:padel_app/widgets/tournaments/club_logo.dart';
import 'package:padel_app/widgets/tournaments/league_card.dart';

/// Карточка лиги: та же в списке турниров и в «Моих лигах».
String _stages(Map<String, dynamic> row) => '${row['stages'] ?? 0}';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru');
  });

  // Карточка форматирует даты по локали экрана — в тесте включаем русскую,
  // иначе сентябрь станет September.
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: const [Locale('ru')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  League league({
    int? myPlace,
    int? myPoints,
    int stagesDone = 2,
    int stagesTotal = 8,
    DateTime? nextStageAt,
  }) =>
      League(
        id: 1,
        name: 'Сентябрь Кап',
        status: 'in_progress',
        statusName: 'Идёт',
        clubName: 'Padel Hills',
        clubCity: 'Алматы',
        clubLogo: 'https://x/logo.png',
        formatName: 'Americano Flex',
        stagesTotal: stagesTotal,
        stagesDone: stagesDone,
        players: 12,
        isRegistered: true,
        myPlace: myPlace,
        myPoints: myPoints,
        totalPlayers: 14,
        nextStage: nextStageAt == null
            ? null
            : LeagueStage(id: 5, stage: 3, name: 'Этап 3', startDate: nextStageAt),
      );

  testWidgets('карточка показывает лигу, клуб и прогресс', (tester) async {
    await tester.pumpWidget(wrap(LeagueCard(league: league(), onTap: () {})));

    expect(find.text('Сентябрь Кап'), findsOneWidget);
    expect(find.textContaining('Padel Hills'), findsOneWidget);
    expect(find.text('этап 2 из 8'), findsOneWidget);
    expect(find.text('ЛИГА'), findsOneWidget, reason: 'карточку не спутать с турниром');
    // Формат этапов и логотип клуба — как у карточки турнира.
    expect(find.text('Americano Flex'), findsOneWidget);
    // Логотип клуба 38×38 — тот же размер, что в шапке клуба над турнирами.
    final logo = tester.widget<ClubLogoTile>(find.byType(ClubLogoTile));
    expect(logo.size, 38);
    expect(logo.url, 'https://x/logo.png');
  });

  testWidgets('место и очки показываются, когда игрок уже играл', (tester) async {
    await tester.pumpWidget(wrap(LeagueCard(league: league(myPlace: 3, myPoints: 148), onTap: () {})));

    expect(find.text('3 из 14'), findsOneWidget);
    expect(find.text('148 очков'), findsOneWidget);
  });

  testWidgets('без сыгранных этапов место не показывается', (tester) async {
    await tester.pumpWidget(wrap(LeagueCard(league: league(), onTap: () {})));

    expect(find.text('3 из 14'), findsNothing, reason: 'играть ещё не начинал');
    expect(find.text('вы в составе'), findsOneWidget);
  });

  testWidgets('ближайший этап виден с датой', (tester) async {
    await tester.pumpWidget(wrap(LeagueCard(
      league: league(nextStageAt: DateTime(2026, 9, 12, 19, 0)),
      onTap: () {},
    )));

    expect(find.textContaining('Этап 3'), findsOneWidget);
    expect(find.textContaining('12 сентября'), findsOneWidget);
  });

  test('прогресс лиги считается долей сыгранных этапов', () {
    expect(league(stagesDone: 2, stagesTotal: 8).progress, 0.25);
    expect(league(stagesDone: 0, stagesTotal: 0).progress, 0, reason: 'делить не на что');
  });

  test('записаться можно только в открытую лигу со свободными местами', () {
    final open = League(
      id: 1, name: 'Л', status: 'open', statusName: 'Открыта',
      stagesTotal: 8, stagesDone: 0, players: 4, maxPlayers: 12, isRegistered: false,
    );
    expect(open.canRegister, isTrue);

    final full = League(
      id: 1, name: 'Л', status: 'open', statusName: 'Открыта',
      stagesTotal: 8, stagesDone: 0, players: 12, maxPlayers: 12, isRegistered: false,
    );
    expect(full.canRegister, isFalse, reason: 'мест нет');

    final done = League(
      id: 1, name: 'Л', status: 'completed', statusName: 'Завершена',
      stagesTotal: 8, stagesDone: 8, players: 4, isRegistered: false,
    );
    expect(done.canRegister, isFalse, reason: 'лига закончилась');
  });

  test('разбор ответа сервера', () {
    final league = League.fromJson({
      'id': 7,
      'name': 'Сентябрь Кап',
      'status': 'in_progress',
      'status_name': 'Идёт',
      'club': {'id': 21, 'name': 'Padel Hills', 'city': 'Алматы', 'logo': 'https://x/logo.png'},
      'format_name': 'Americano Flex, парный',
      'stages_total': 8,
      'stages_done': 3,
      'players': 12,
      'is_registered': true,
      'my_place': 2,
      'standings': [
        {
          'position': 1, 'user_id': 5, 'name': 'Игрок', 'stages': 3,
          'wins': 7, 'losses': 2, 'draws': 1, 'points_for': 148,
          'points_against': 120, 'diff': 28, 'average': 14.8, 'is_me': true,
        }
      ],
      'stages': [
        {'id': 11, 'stage': 1, 'name': 'Этап 1', 'status': 'completed', 'status_name': 'Завершён'}
      ],
    });

    expect(league.clubName, 'Padel Hills');
    expect(league.clubLogo, 'https://x/logo.png');
    expect(league.formatName, 'Americano Flex, парный');
    expect(league.myPlace, 2);
    expect(league.standings.single.pointsFor, 148);
    expect(league.standings.single.isMe, isTrue);
    expect(league.stages.single.isFinished, isTrue);
  });

  testWidgets('колонка имени в таблице шире заданного минимума', (tester) async {
    // В лиге ФИО просят места, поэтому колонке задаём минимум,
    // а остальные колонки уезжают в горизонтальный скролл.
    await tester.pumpWidget(wrap(SizedBox(
      width: 360,
      child: FlexStandingsTable(
        nameMinWidth: 112,
        leaderboard: const [
          {
            'position': 1, 'id': 5, 'name': 'Андрей Кузнецов', 'verified': true,
            'wins': 3, 'losses': 1, 'draws': 0, 'points_for': 100,
            'points_against': 80, 'matches_played': 4, 'stages': 2,
          },
        ],
        extraColumn: ('Э', 'этапов сыграно', _stages),
      ),
    )));

    final nameBox = tester.getSize(find.text('Андрей').first);
    expect(nameBox.width, greaterThan(0));
    expect(find.text('Кузнецов'), findsOneWidget, reason: 'фамилия на второй строке');
  });

  test('строка таблицы лиги несёт галочку верификации', () {
    // Галочку показывает та же таблица, что и у этапа: поле verified.
    final row = LeagueStandingRow.fromJson({
      'position': 1, 'user_id': 5, 'name': 'Игрок', 'verified': true,
      'stages': 2, 'wins': 7, 'losses': 2, 'draws': 1,
      'points_for': 148, 'points_against': 120, 'diff': 28, 'average': 14.8,
      'is_me': true,
    });

    expect(row.verified, isTrue);

    final plain = LeagueStandingRow.fromJson({
      'position': 2, 'user_id': 6, 'name': 'Второй', 'stages': 1,
      'wins': 1, 'losses': 1, 'draws': 0, 'points_for': 60,
      'points_against': 70, 'diff': -10, 'average': 30, 'is_me': false,
    });

    expect(plain.verified, isFalse, reason: 'без поля — без галочки');
  });

  test('этап несёт моё место и очки', () {
    // Медальку за этап рисует лига: из истории турниров этапы убраны.
    final stage = LeagueStage.fromJson({
      'id': 11, 'stage': 1, 'name': 'Этап 1', 'status': 'completed',
      'status_name': 'Завершён', 'participants': 12, 'max_participants': 12,
      'my_place': 2, 'my_points': 148,
    });

    expect(stage.myPlace, 2);
    expect(stage.myPoints, 148);
    expect(stage.isFinished, isTrue);

    final pending = LeagueStage.fromJson({
      'id': 12, 'stage': 2, 'name': 'Этап 2', 'status': 'open',
      'status_name': 'Открыт', 'participants': 4,
    });

    expect(pending.myPlace, isNull, reason: 'этап ещё не сыгран');
    expect(pending.myPoints, isNull);
  });

  test('формат этапов приходит в админском ответе', () {
    // Галочка «парный этап» в форме нового этапа встаёт по настройке лиги.
    final league = League.fromJson({
      'id': 7, 'name': 'Л', 'status': 'open', 'status_name': 'Открыта',
      'stages_total': 8, 'stages_done': 0, 'players': 0, 'is_registered': false,
      'is_paired': true, 'courts_count': 3,
    });

    expect(league.isPaired, isTrue);
    expect(league.courtsCount, 3);

    final plain = League.fromJson({
      'id': 8, 'name': 'Л', 'status': 'open', 'status_name': 'Открыта',
      'stages_total': 8, 'stages_done': 0, 'players': 0, 'is_registered': false,
    });

    expect(plain.isPaired, isFalse, reason: 'в игроцком ответе поля нет');
    expect(plain.courtsCount, 2);
  });
}
