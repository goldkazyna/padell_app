import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/main_nav_pill.dart';

/// Плавающее меню: один вид на главном экране и на вложенных, где человек
/// продолжает ходить по приложению.
void main() {
  Widget wrap(Widget child) => MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('активная вкладка подсвечена, остальные приглушены', (tester) async {
    await tester.pumpWidget(wrap(MainNavPill(
      current: 1,
      onSelect: (_) {},
      onLockedTap: () {},
    )));

    final active = tester.widget<Text>(find.text('Турниры'));
    final idle = tester.widget<Text>(find.text('Главная'));

    expect(active.style!.color, AppTheme.accent);
    expect(idle.style!.color, isNot(AppTheme.accent));
  });

  testWidgets('тап отдаёт номер вкладки', (tester) async {
    final taps = <int>[];

    await tester.pumpWidget(wrap(MainNavPill(
      current: 1,
      onSelect: taps.add,
      onLockedTap: () {},
    )));

    await tester.tap(find.text('Рейтинг'));
    expect(taps, [3]);
  });

  testWidgets('с незаполненным профилем закрытые вкладки просят заполнить', (tester) async {
    final taps = <int>[];
    var locked = 0;

    await tester.pumpWidget(wrap(MainNavPill(
      current: 0,
      profileIncomplete: true,
      onSelect: taps.add,
      onLockedTap: () => locked++,
    )));

    await tester.tap(find.text('Турниры'));
    await tester.tap(find.text('Профиль'));

    expect(locked, 1, reason: 'турниры закрыты до заполнения профиля');
    expect(taps, [4], reason: 'профиль открыт всегда — иначе его не заполнить');
  });
}
