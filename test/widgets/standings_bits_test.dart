import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/widgets/standings_bits.dart';

/// Имя игрока в турнирной таблице разбивается на две строки, а колонки
/// подписаны буквами с расшифровкой внизу — иначе таблица не влезает в экран.
void main() {
  group('разбиение имени', () {
    test('имя и фамилия расходятся по строкам', () {
      expect(StandingsName.split('Аркадий Абдулов'), ['Аркадий', 'Абдулов']);
    });

    test('всё после первого пробела уходит вниз целиком', () {
      // Отчества и двойные фамилии не должны теряться.
      expect(StandingsName.split('Иван Петров-Водкин'), ['Иван', 'Петров-Водкин']);
      expect(StandingsName.split('Кирилл Колганов Левша'), ['Кирилл', 'Колганов Левша']);
    });

    test('одно слово остаётся одной строкой', () {
      expect(StandingsName.split('Bogdan'), ['Bogdan', '']);
    });

    test('лишние пробелы не создают пустую строку', () {
      expect(StandingsName.split('  Emma   Rakoid '), ['Emma', 'Rakoid']);
    });
  });

  testWidgets('имя рисуется двумя строками', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: StandingsName(name: 'Аркадий Абдулов')),
    ));

    expect(find.text('Аркадий'), findsOneWidget);
    expect(find.text('Абдулов'), findsOneWidget);
    // Целиком одной строкой имя больше не выводится.
    expect(find.text('Аркадий Абдулов'), findsNothing);
  });

  testWidgets('легенда расшифровывает буквы колонок', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: StandingsLegend(items: StandingsLegend.scoring),
      ),
    ));

    // Каждая пара «буква — значение» рисуется одним Text.rich.
    expect(find.byType(Text), findsNWidgets(StandingsLegend.scoring.length));

    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.textSpan!.toPlainText())
        .toList();

    expect(texts, contains('В — победы'));
    expect(texts, contains('П — поражения'));
    expect(texts, contains('Н — ничьи'));
    expect(texts, contains('З — забито'));
    expect(texts, contains('Пр — пропущено'));
    expect(texts, contains('± — разница'));
  });

  test('в наборе для таблиц победы, поражения и ничьи идут первыми', () {
    final order = StandingsLegend.scoring.map((e) => e.$1).toList();

    expect(order.take(3).toList(), ['В', 'П', 'Н']);
  });
}
