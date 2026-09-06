import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/models/amigo.dart';
import 'package:padel_app/providers/amigo_provider.dart';
import 'package:padel_app/services/amigo_service.dart';
import 'package:padel_app/services/api_service.dart';
import 'package:padel_app/services/storage_service.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/profile/amigos_card.dart';
import 'package:provider/provider.dart';

/// Карточка амигос в профиле: куда попадает палец.
///
/// Раньше открыть список можно было только тапом по узкой строке заголовка —
/// в неё не попадали. Теперь нажимается вся карточка, а аватары и «Добавить»
/// внутри перехватывают тап и ведут по-своему.
class _Fake extends AmigoProvider {
  _Fake(this._a) : super(AmigoService(ApiService()), StorageService());
  final List<Amigo> _a;

  @override
  List<Amigo> get amigos => _a;
  @override
  List<Amigo> get playing =>
      _a.where((x) => x.status?.isPlaying == true).toList();
  @override
  Future<void> loadSummary() async {}
}

void main() {
  Widget wrap(AmigoProvider provider, List<Route<dynamic>> pushed) {
    return ChangeNotifierProvider<AmigoProvider>.value(
      value: provider,
      child: MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorObservers: [_Spy(pushed)],
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: const Center(child: AmigosCard()),
        ),
      ),
    );
  }

  testWidgets('тап по пустому месту карточки открывает раздел', (tester) async {
    final pushed = <Route<dynamic>>[];
    await tester.pumpWidget(wrap(
      _Fake(const [Amigo(id: 1, name: 'Борис С')]),
      pushed,
    ));
    await tester.pump();

    // Заголовок «Амигос» — это уже не единственная зона нажатия: бьём по
    // пустому месту справа от него.
    final card = tester.getRect(find.byType(AmigosCard));
    await tester.tapAt(Offset(card.center.dx, card.top + 24));
    await tester.pump();

    expect(pushed.length, 1, reason: 'карточка целиком ведёт в список амигос');
  });

  testWidgets('тап по аватару перехватывается и ведёт по-своему', (tester) async {
    final pushed = <Route<dynamic>>[];
    await tester.pumpWidget(wrap(
      _Fake(const [
        Amigo(
          id: 1,
          name: 'Борис С',
          status: AmigoStatus(
            kind: 'playing',
            title: 'играет',
            subtitle: 'Американо · Davay Padel',
            tournamentId: 7,
          ),
        ),
      ]),
      pushed,
    ));
    await tester.pump();

    await tester.tap(find.text('Борис'));
    await tester.pumpAndSettle();

    // Открылся выбор «трансляция или профиль», а не список амигос.
    expect(find.text('Смотреть трансляцию'), findsOneWidget);
    expect(find.text('Профиль игрока'), findsOneWidget);
  });
}

/// Считает открытые экраны.
class _Spy extends NavigatorObserver {
  _Spy(this.pushed);

  final List<Route<dynamic>> pushed;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Первый маршрут — сам home, его не считаем.
    if (previousRoute != null) pushed.add(route);
  }
}
