import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/standings_table.dart';

/// Снимок новой таблицы: пара закреплена слева, цифры листаются вбок.
void main() {
  // Тестовый шрифт рисует прямоугольники вместо букв — по такому снимку не
  // проверишь ни длину ФИО, ни выравнивание цифр. Подкладываем системный.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final path in [
      r'C:\Windows\Fonts\segoeui.ttf',
      r'C:\Windows\Fontsrial.ttf',
    ]) {
      final file = File(path);
      if (!file.existsSync()) continue;
      final loader = FontLoader('Roboto')
        ..addFont(Future.value(file.readAsBytesSync().buffer.asByteData()));
      await loader.load();
      break;
    }
  });

  final rows = [
    ('Ержан Тлеубаев', 'Данияр Кимбаев', 61, 2, 1, 7, 20.3, true),
    ('Марат Сулейменов', 'Асель Волкова', 58, 2, 1, 3, 19.3, true),
    ('Тимур Попов', 'София Данилова', 52, 1, 2, -2, 17.3, false),
    ('Николай Морозов', 'Павел Новиков', 47, 1, 2, -8, 15.7, false),
    ('Тестовый1 Тестовый1', 'Тест #8', 44, 0, 3, -16, 14.7, false),
  ];

  Widget table() => StandingsTable(
        nameHeader: 'Пара',
        entries: [
          for (var i = 0; i < rows.length; i++)
            StandingsEntry(
              place: i + 1,
              players: [
                StandingsPlayer(name: rows[i].$1, verified: rows[i].$8),
                StandingsPlayer(name: rows[i].$2),
              ],
            ),
        ],
        columns: [
          StandingsColumn(
            title: 'Очки',
            value: (i) => '${rows[i].$3}',
            bold: true,
            width: 56,
          ),
          StandingsColumn(title: 'В', value: (i) => '${rows[i].$4}', width: 42),
          StandingsColumn(title: 'П', value: (i) => '${rows[i].$5}', width: 42),
          StandingsColumn(title: 'Н', value: (i) => '0', width: 42),
          StandingsColumn(
            title: '±',
            value: (i) => rows[i].$6 > 0 ? '+${rows[i].$6}' : '−${rows[i].$6.abs()}',
            width: 50,
            color: (i) => rows[i].$6 > 0 ? AppTheme.accent : AppTheme.error,
          ),
          StandingsColumn(
            title: 'Ср',
            value: (i) => rows[i].$7.toStringAsFixed(1),
            width: 52,
          ),
        ],
      );

  testWidgets('снимок таблицы', (tester) async {
    tester.view.physicalSize = const Size(430, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: AppTheme.background,
        body: Padding(padding: const EdgeInsets.all(12), child: table()),
      ),
    ));
    await tester.pump();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/standings_table.png'),
    );
  });

  testWidgets('цифры листаются, имена остаются', (tester) async {
    tester.view.physicalSize = const Size(430, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: AppTheme.background,
        body: Padding(padding: const EdgeInsets.all(12), child: table()),
      ),
    ));
    await tester.pump();

    await tester.drag(find.text('20.3'), const Offset(-160, 0));
    await tester.pumpAndSettle();

    expect(find.text('Ержан Тлеубаев'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/standings_table_scrolled.png'),
    );
  });
}
