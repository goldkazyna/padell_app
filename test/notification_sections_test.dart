import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/widgets/app_checkbox.dart';
import 'package:padel_app/widgets/app_expandable_section.dart';

/// Сворачиваемые блоки настроек: список открывается по нажатию, а до этого
/// виден только заголовок со сводкой — иначе города и клубы топят экран.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: child)),
      );

  testWidgets('свёрнутый блок не показывает список', (tester) async {
    await tester.pumpWidget(wrap(const AppExpandableSection(
      title: 'Города',
      summary: 'Все города',
      children: [Text('Алматы'), Text('Талдыкорган')],
    )));

    expect(find.text('Города'), findsOneWidget);
    expect(find.text('Все города'), findsOneWidget, reason: 'сводка видна сразу');
    expect(find.text('Талдыкорган'), findsNothing);
  });

  testWidgets('нажатие раскрывает и сворачивает обратно', (tester) async {
    await tester.pumpWidget(wrap(const AppExpandableSection(
      title: 'Города',
      description: 'Снимите город — объявления его клубов приходить не будут',
      children: [Text('Алматы'), Text('Талдыкорган')],
    )));

    await tester.tap(find.text('Города'));
    await tester.pumpAndSettle();

    expect(find.text('Талдыкорган'), findsOneWidget);
    expect(find.text('Снимите город — объявления его клубов приходить не будут'),
        findsOneWidget, reason: 'пояснение показываем только в раскрытом виде');

    await tester.tap(find.text('Города'));
    await tester.pumpAndSettle();

    expect(find.text('Талдыкорган'), findsNothing);
  });

  testWidgets('шеврон поворачивается при раскрытии', (tester) async {
    await tester.pumpWidget(wrap(const AppExpandableSection(
      title: 'Клубы',
      children: [Text('ADD Padel')],
    )));

    double turns() => tester
        .widget<AnimatedRotation>(find.byType(AnimatedRotation))
        .turns;

    expect(turns(), 0);

    await tester.tap(find.text('Клубы'));
    await tester.pumpAndSettle();

    expect(turns(), 0.25, reason: 'стрелка смотрит вниз, когда блок открыт');
  });

  testWidgets('блок можно открыть сразу', (tester) async {
    await tester.pumpWidget(wrap(const AppExpandableSection(
      title: 'Клубы',
      initiallyExpanded: true,
      children: [Text('ADD Padel')],
    )));

    expect(find.text('ADD Padel'), findsOneWidget);
  });

  testWidgets('чекбокс: отмеченный с галочкой, снятый — пустой', (tester) async {
    await tester.pumpWidget(wrap(const Column(
      children: [
        AppCheckbox(checked: true),
        AppCheckbox(checked: false),
      ],
    )));

    expect(find.byIcon(Icons.check), findsOneWidget, reason: 'галочка только у отмеченного');
    expect(find.byType(AppCheckbox), findsNWidgets(2));
  });
}
