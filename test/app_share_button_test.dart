import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/widgets/app_share_button.dart';

/// Общая кнопка «поделиться» — та же, что стоит у трансляции и у лиги.
///
/// Проверяем круг того же размера, что и «назад» рядом, и что в мессенджер
/// уходит именно переданный текст со ссылкой.
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

  testWidgets('круг 34×34 — как у кнопки «назад»', (tester) async {
    await tester.pumpWidget(wrap(const AppShareButton(
      text: 'x',
      errorTitle: 'y',
    )));

    expect(
      tester.getSize(find.descendant(
        of: find.byType(AppShareButton),
        matching: find.byType(Container),
      )),
      const Size(34, 34),
    );
  });

  testWidgets('уходит ссылка на лигу', (tester) async {
    await tester.pumpWidget(wrap(const AppShareButton(
      text: 'Заходи в лигу\n«Осенняя лига»\nhttps://padel-p.kz/l/12',
      errorTitle: 'Не удалось',
    )));

    await tester.tap(find.byType(AppShareButton));
    await tester.pump();

    expect(shared, hasLength(1));
    expect(shared.first['text'], contains('https://padel-p.kz/l/12'));
    expect(shared.first['text'], contains('Осенняя лига'));
  });
}
