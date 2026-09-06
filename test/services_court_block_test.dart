import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/providers/game_provider.dart';
import 'package:padel_app/services/api_service.dart';
import 'package:padel_app/services/game_service.dart';
import 'package:padel_app/services/storage_service.dart';
import 'package:padel_app/services/training_service.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/court_menu_panel.dart';
import 'package:padel_app/widgets/home/services_court_block.dart';
import 'package:provider/provider.dart';

/// «Сервисы» на главной — тот же корт, что в меню профиля.
///
/// Снимок держит блок целиком: восемь зон в два ряда, метка новой фичи.
/// Разъедется с профилем — увидим.
void main() {
  Widget wrap() {
    final api = ApiService();
    final storage = StorageService();

    return MultiProvider(
      providers: [
        Provider<TrainingService>.value(value: TrainingService(api, storage)),
        ChangeNotifierProvider<GameProvider>.value(
          value: GameProvider(GameService(api), storage),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: const ServicesCourtBlock(),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('восемь зон в два ряда', (tester) async {
    tester.view.physicalSize = const Size(390, 320);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pump();

    // Пока идёт выбор раскладки, на главной три панели подряд: 8 зон в
    // каждой. Выберем — останется одна.
    final panels = kServicesPreview ? 3 : 1;
    expect(find.byType(CourtMenuZone), findsNWidgets(8 * panels));

    // Названия на месте — все восемь входов видны без прокрутки блока.
    for (final name in [
      'Лиги',
      'Клубы',
      'Тренировки',
      'Игры',
      'Комьюнити',
      'Клубные карты',
      'Сертификаты',
      'Магазин',
    ]) {
      expect(find.text(name), findsNWidgets(panels), reason: name);
    }

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/services_court.png'),
    );
  });

  testWidgets('пока занятий нет — метка NEW вместо числа', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.pump();

    expect(find.text('NEW'), findsNWidgets(kServicesPreview ? 3 : 1));
  });
}
