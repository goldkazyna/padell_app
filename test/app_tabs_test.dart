import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/app_tabs.dart';

/// Вкладки внутри экрана — один вид на всё приложение.
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('активная вкладка выделена акцентом, остальные приглушены', (tester) async {
    await tester.pumpWidget(wrap(AppTabs(
      labels: const ['Таблица', 'Этапы'],
      current: 1,
      onChanged: (_) {},
    )));

    final active = tester.widget<Text>(find.text('Этапы'));
    final idle = tester.widget<Text>(find.text('Таблица'));

    expect(active.style!.color, AppTheme.accent);
    expect(idle.style!.color, isNot(AppTheme.accent));
  });

  testWidgets('тап переключает вкладку и не дёргает текущую', (tester) async {
    final taps = <int>[];

    await tester.pumpWidget(wrap(AppTabs(
      labels: const ['Таблица', 'Этапы'],
      current: 0,
      onChanged: taps.add,
    )));

    await tester.tap(find.text('Этапы'));
    await tester.tap(find.text('Таблица'));

    expect(taps, [1], reason: 'повторный тап по активной вкладке ничего не шлёт');
  });

  testWidgets('счётчик показывается там, где он задан', (tester) async {
    await tester.pumpWidget(wrap(AppTabs(
      labels: const ['Таблица', 'Этапы', 'Состав'],
      counts: const [null, 8, 16],
      current: 0,
      onChanged: (_) {},
    )));

    expect(find.text('8'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
  });
}
