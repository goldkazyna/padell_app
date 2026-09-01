import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/models/game.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/games/club_picker_sheet.dart';

/// Выбор клуба при создании игры: список прокручивается, поиск ищет и по
/// названию, и по адресу.
void main() {
  final clubs = [
    GameClub(id: 1, name: 'Padel Sai', city: 'Алматы', address: 'ул. Жамбыла, 200'),
    GameClub(id: 2, name: 'Padel Hills', city: 'Алматы', address: 'мкр. Самал'),
    GameClub(id: 3, name: 'Davai Padel', city: 'Астана', address: 'пр. Кабанбай'),
  ];

  group('поиск клуба', () {
    test('пустой запрос — все клубы', () {
      expect(clubs.where((c) => c.matches('')).length, 3);
    });

    test('ищем по названию, регистр не важен', () {
      final found = clubs.where((c) => c.matches('sai')).toList();
      expect(found.single.name, 'Padel Sai');
    });

    test('ищем по адресу и городу', () {
      expect(clubs.where((c) => c.matches('Жамбыла')).single.id, 1);
      expect(clubs.where((c) => c.matches('Астана')).single.id, 3);
    });

    test('город и адрес склеиваются в одну строку', () {
      expect(clubs.first.place, 'Алматы, ул. Жамбыла, 200');
      expect(GameClub(id: 9, name: 'X').place, '');
    });
  });

  testWidgets('шторка ищет по мере ввода и отдаёт выбранный клуб', (tester) async {
    GameClub? picked;

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              picked = await showGameClubPicker(context, clubs: clubs);
            },
            child: const Text('открыть'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();

    // Видны все клубы.
    expect(find.text('Padel Sai'), findsOneWidget);
    expect(find.text('Davai Padel'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'hill');
    await tester.pumpAndSettle();

    expect(find.text('Padel Hills'), findsOneWidget);
    expect(find.text('Padel Sai'), findsNothing);

    await tester.tap(find.text('Padel Hills'));
    await tester.pumpAndSettle();

    expect(picked?.id, 2);
  });

  testWidgets('ничего не нашли — так и говорим', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showGameClubPicker(context, clubs: clubs),
            child: const Text('открыть'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'зззз');
    await tester.pumpAndSettle();

    expect(find.text('Ничего не нашли'), findsOneWidget);
  });

  testWidgets('у выбранного клуба есть «убрать»', (tester) async {
    GameClub? picked;

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              picked = await showGameClubPicker(context,
                  clubs: clubs, selected: clubs.first);
            },
            child: const Text('открыть'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('открыть'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Убрать клуб'));
    await tester.pumpAndSettle();

    expect(picked?.id, clearedClub.id, reason: 'отличается от «закрыли шторку»');
  });
}
