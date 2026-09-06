import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/models/amigo.dart';
import 'package:padel_app/widgets/amigos/amigo_open_sheet.dart';

/// Выбор при тапе по амигос.
///
/// Раньше тап сразу уводил в трансляцию, и попасть в профиль было нечем.
/// Теперь спрашиваем — но только когда выбор действительно есть.
void main() {
  Widget harness(void Function(BuildContext) onTap) => MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: GestureDetector(
                onTap: () => onTap(context),
                child: const Text('тап'),
              ),
            ),
          ),
        ),
      );

  testWidgets('играющий — спрашиваем: трансляция или профиль', (tester) async {
    await tester.pumpWidget(harness((context) => openAmigoTarget(
          context,
          playerId: 1,
          playerName: 'Асхат Ким',
          status: const AmigoStatus(
            kind: 'playing',
            title: 'играет',
            subtitle: 'Американо · Padel Sai',
            tournamentId: 1439,
          ),
        )));

    await tester.tap(find.text('тап'));
    await tester.pumpAndSettle();

    expect(find.text('Смотреть трансляцию'), findsOneWidget);
    expect(find.text('Профиль игрока'), findsOneWidget);
    expect(find.text('Американо · Padel Sai'), findsOneWidget);
  });

  testWidgets('у кого турнир скоро — предлагаем открыть турнир', (tester) async {
    await tester.pumpWidget(harness((context) => openAmigoTarget(
          context,
          playerId: 2,
          playerName: 'Диана',
          status: const AmigoStatus(
            kind: 'soon',
            title: 'турнир',
            subtitle: 'сегодня 19:00',
            tournamentId: 77,
          ),
        )));

    await tester.tap(find.text('тап'));
    await tester.pumpAndSettle();

    expect(find.text('Открыть турнир'), findsOneWidget);
    expect(find.text('Профиль игрока'), findsOneWidget);
  });

  testWidgets('ищет игроков — предлагаем открыть игру', (tester) async {
    await tester.pumpWidget(harness((context) => openAmigoTarget(
          context,
          playerId: 3,
          playerName: 'Ержан',
          status: const AmigoStatus(
            kind: 'looking',
            title: 'ищет игроков',
            subtitle: 'сегодня 20:00',
            gameId: 44,
          ),
        )));

    await tester.tap(find.text('тап'));
    await tester.pumpAndSettle();

    expect(find.text('Открыть игру'), findsOneWidget);
  });

  test('когда открывать нечего — вопрос не задаём', () {
    // Навигацию в профиль тут не проверить (экрану нужны провайдеры и сеть),
    // но само правило — чистая функция, и оно важнее.
    expect(amigoHasChoice(null), isFalse);

    expect(
      amigoHasChoice(const AmigoStatus(kind: 'playing', title: '', subtitle: '')),
      isFalse,
      reason: 'статус без id открывать некуда',
    );

    expect(
      amigoHasChoice(const AmigoStatus(
        kind: 'playing',
        title: '',
        subtitle: '',
        tournamentId: 1,
      )),
      isTrue,
    );
  });
}
