import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/court_menu_panel.dart';

/// «Приглашения на турнир» краснеют только когда есть что закрыть.
///
/// Раньше зона была красной всегда — и с тремя приглашениями, и с нулём.
/// Постоянная тревога перестаёт читаться как тревога.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: SizedBox(width: 195, child: child),
        ),
      );

  Color? zoneBackground(WidgetTester tester) {
    final box = tester.widget<Container>(
      find.descendant(
        of: find.byType(CourtMenuZone),
        matching: find.byType(Container),
      ).first,
    );

    return (box.color);
  }

  testWidgets('без приглашений зона обычная', (tester) async {
    await tester.pumpWidget(wrap(CourtMenuZone(
      icon: Icons.mail_outline,
      alert: true,
      title: 'Приглашения',
      subtitle: 'на турнир',
      badge: 0,
      onTap: () {},
    )));

    expect(zoneBackground(tester), isNull, reason: 'красного фона нет');
    expect(
      tester.widget<Icon>(find.byIcon(Icons.mail_outline)).color,
      AppTheme.textPrimary,
    );
  });

  testWidgets('с приглашениями краснеют иконка и фон', (tester) async {
    await tester.pumpWidget(wrap(CourtMenuZone(
      icon: Icons.mail_outline,
      alert: true,
      title: 'Приглашения',
      subtitle: 'на турнир',
      badge: 3,
      onTap: () {},
    )));

    expect(zoneBackground(tester), isNotNull);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.mail_outline)).color,
      AppTheme.error,
    );
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('обычная зона не краснеет даже с числом', (tester) async {
    await tester.pumpWidget(wrap(CourtMenuZone(
      icon: Icons.sports_tennis_outlined,
      title: 'Мои тренировки',
      subtitle: 'расписание',
      value: '2',
      onTap: () {},
    )));

    expect(zoneBackground(tester), isNull);
    expect(
      tester.widget<Icon>(find.byIcon(Icons.sports_tennis_outlined)).color,
      AppTheme.textPrimary,
    );
  });
}
