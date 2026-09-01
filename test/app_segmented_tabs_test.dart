import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/app_segmented_tabs.dart';

/// Переключатель разделов «Турниры / Лиги»: активный виден цветом,
/// повторный тап по активному ничего не шлёт.
void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('активный раздел выделен акцентом', (tester) async {
    await tester.pumpWidget(wrap(AppSegmentedTabs(
      labels: const ['Турниры', 'Лиги'],
      current: 1,
      onChanged: (_) {},
    )));

    final active = tester.widget<Text>(find.text('Лиги'));
    final idle = tester.widget<Text>(find.text('Турниры'));

    expect(active.style!.color, AppTheme.accent);
    expect(idle.style!.color, isNot(AppTheme.accent));
  });

  testWidgets('тап переключает раздел, повторный по активному — нет', (tester) async {
    final taps = <int>[];

    await tester.pumpWidget(wrap(AppSegmentedTabs(
      labels: const ['Турниры', 'Лиги'],
      current: 0,
      onChanged: taps.add,
    )));

    await tester.tap(find.text('Лиги'));
    await tester.tap(find.text('Турниры'));

    expect(taps, [1]);
  });

  testWidgets('разделы делят ширину поровну', (tester) async {
    await tester.pumpWidget(wrap(AppSegmentedTabs(
      labels: const ['Турниры', 'Лиги'],
      current: 0,
      onChanged: (_) {},
    )));

    final first = tester.getSize(find.ancestor(
        of: find.text('Турниры'), matching: find.byType(AnimatedContainer)));
    final second = tester.getSize(find.ancestor(
        of: find.text('Лиги'), matching: find.byType(AnimatedContainer)));

    expect(first.width, second.width);
  });
}
