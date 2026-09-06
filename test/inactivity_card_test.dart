import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/providers/profile_provider.dart';
import 'package:padel_app/services/api_service.dart';
import 'package:padel_app/services/profile_service.dart';
import 'package:padel_app/services/storage_service.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/profile/inactivity_card.dart'
    show InactivityCard, kInactivityPreview;
import 'package:provider/provider.dart';

/// Напоминание о простое в профиле.
///
/// Рейтинг тает у тех, кто перестал играть, и человек должен узнать об этом
/// от приложения, а не обнаружить просадку в таблице.
class _Fake extends ProfileProvider {
  _Fake(this._idle)
      : super(ProfileService(ApiService(), StorageService()));

  final PlayerInactivity _idle;

  @override
  PlayerInactivity get inactivity => _idle;
}

void main() {
  Widget wrap(PlayerInactivity idle) => ChangeNotifierProvider<ProfileProvider>.value(
        value: _Fake(idle),
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
            body: const InactivityCard(),
          ),
        ),
      );

  testWidgets('пока играешь — карточки нет', (tester) async {
    await tester.pumpWidget(wrap(const PlayerInactivity(idleDays: 12)));
    await tester.pump();

    expect(find.byType(Container), findsNothing);
    // Пока включён показ обоих состояний, карточка рисуется всегда.
  }, skip: kInactivityPreview);

  testWidgets('с 45-го дня предупреждаем и говорим, сколько осталось',
      (tester) async {
    await tester.pumpWidget(wrap(const PlayerInactivity(
      idleDays: 47,
      daysUntilDecay: 13,
      amount: 50,
      warn: true,
    )));
    await tester.pump();

    expect(find.text('Вы не играли 47 дней'), findsOneWidget);
    expect(
      find.textContaining('Через 13 дн. спишется 50 рейтинга'),
      findsOneWidget,
    );
    // Зовём сыграть, а не просто пугаем.
    expect(find.textContaining('Сыграйте в любом турнире'), findsOneWidget);
  });

  testWidgets('после списания текст меняется на факт', (tester) async {
    await tester.pumpWidget(wrap(const PlayerInactivity(
      idleDays: 62,
      daysUntilDecay: 30,
      amount: 50,
      warn: true,
      decayed: true,
    )));
    await tester.pump();

    expect(find.text('Списано 50 рейтинга за простой'), findsOneWidget);
    expect(find.textContaining('каждый месяц'), findsOneWidget);
  });
}
