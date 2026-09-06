import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/models/league.dart';
import 'package:padel_app/models/tournament.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/home/upcoming_list.dart';
import 'package:padel_app/widgets/tournaments/league_stage_tag.dart';

/// Этап лиги в списке «Скоро».
///
/// Этап — обычный турнир, и в календаре он выглядел как все остальные:
/// человек записывался в лигу, не понимая этого.
Tournament _tournament({
  required int id,
  required String name,
  TournamentLeagueRef? league,
}) {
  return Tournament.fromJson({
    'id': id,
    'name': name,
    'club': {'id': 1, 'name': 'Davay Padel'},
    'date': '08.09.2026',
    'time': '21:28',
    // Полдень сегодняшнего дня: список показывает выбранный день, а +3
    // часа от «сейчас» под вечер уезжают на завтра.
    'datetime': _today.toIso8601String(),
    'type': 'americano_flex',
    'type_name': 'Americano Flex',
    'status': 'open',
    'status_name': 'Открыт',
    'min_level': 1.0,
    'max_level': 7.0,
    'price': 19000,
    'max_participants': 18,
    'participants_count': 18,
    if (league != null)
      'league': {
        'id': league.id,
        'name': league.name,
        'stage': league.stage,
        'stages_total': league.stagesTotal,
      },
  });
}

final DateTime _today = () {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, 12);
}();

void main() {
  Widget wrap(List<Tournament> items) => MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        // Тестовый шрифт рисует каждую букву квадратом в кегль, и лента
        // дней в нём не помещается по высоте. Ужимаем текст — проверяем
        // метку, а не метрики Ahem.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(0.7),
          ),
          child: child!,
        ),
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: UpcomingList(tournaments: items),
            ),
          ),
        ),
      );

  testWidgets('этап лиги помечен, обычный турнир — нет', (tester) async {
    tester.view.physicalSize = const Size(390, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap([
      _tournament(id: 1, name: 'Открытый американо'),
      _tournament(
        id: 2,
        name: '111',
        league: const TournamentLeagueRef(
          id: 3,
          name: 'Осенняя лига',
          stage: 3,
          stagesTotal: 8,
        ),
      ),
    ]));
    await tester.pump();

    // Два турнира в списке, метка ровно у одного.
    expect(find.text('111'), findsOneWidget);
    expect(find.text('Открытый американо'), findsOneWidget);
    expect(find.byType(LeagueStageTag), findsOneWidget);
    expect(find.text('ЛИГА · ЭТАП 3'), findsOneWidget);
  });

  test('без лиги в ответе поле пустое', () {
    expect(_tournament(id: 1, name: 'Обычный').league, isNull);
    expect(
      _tournament(
        id: 2,
        name: 'Этап',
        league: const TournamentLeagueRef(
          id: 3,
          name: 'Лига',
          stage: 2,
          stagesTotal: 8,
        ),
      ).league?.stage,
      2,
    );
  });
}
