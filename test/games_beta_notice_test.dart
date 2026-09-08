import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';

/// Плашка про доработку модуля игр должна быть на всех языках.
void main() {
  testWidgets('текст плашки есть в ru, en и kk', (tester) async {
    for (final locale in const [Locale('ru'), Locale('en'), Locale('kk')]) {
      late AppLocalizations l10n;

      await tester.pumpWidget(MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return const SizedBox();
        }),
      ));
      await tester.pump();

      expect(l10n.gamesBetaNotice.isNotEmpty, isTrue,
          reason: 'локаль ${locale.languageCode}');
      // Обещание срока — то, ради чего плашка и висит.
      expect(l10n.gamesBetaNotice.length, greaterThan(60));
    }
  });
}
