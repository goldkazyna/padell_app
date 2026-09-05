import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/widgets/live_share_button.dart';

/// Кнопка «поделиться трансляцией» в шапке live-экранов.
///
/// Проверяем две вещи: круг того же размера, что и «назад» рядом, и что
/// уходит ссылка вида /live/{id} — по ней зритель попадает на тот же live.
void main() {
  const channel = MethodChannel('dev.fluttercommunity.plus/share');
  final shared = <Map<String, dynamic>>[];

  setUp(() {
    shared.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      shared.add(Map<String, dynamic>.from(call.arguments as Map));
      return 'dev.fluttercommunity.plus/share/success';
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

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

  testWidgets('круг 34×34 — как у кнопки «назад» рядом', (tester) async {
    await tester.pumpWidget(wrap(
      const LiveShareButton(tournamentId: 1439, tournamentName: 'AMERICANO'),
    ));

    final circle = tester.getSize(
      find.descendant(
        of: find.byType(LiveShareButton),
        matching: find.byType(Container),
      ),
    );

    expect(circle, const Size(34, 34));
  });

  testWidgets('делится ссылкой на трансляцию и названием турнира',
      (tester) async {
    await tester.pumpWidget(wrap(
      const LiveShareButton(tournamentId: 1439, tournamentName: 'AMERICANO'),
    ));

    await tester.tap(find.byType(LiveShareButton));
    await tester.pumpAndSettle();

    expect(shared, hasLength(1));
    final text = shared.first['text'] as String;
    expect(text, contains('https://padel-p.kz/live/1439'));
    expect(text, contains('AMERICANO'));
  });

  testWidgets('без названия турнира ссылка всё равно уходит', (tester) async {
    await tester.pumpWidget(wrap(const LiveShareButton(tournamentId: 7)));

    await tester.tap(find.byType(LiveShareButton));
    await tester.pumpAndSettle();

    expect(shared.first['text'] as String, contains('/live/7'));
  });
}
