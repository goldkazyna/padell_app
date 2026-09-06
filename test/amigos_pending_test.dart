import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/models/amigo.dart';
import 'package:padel_app/providers/amigo_provider.dart';
import 'package:padel_app/screens/amigos_screen.dart';
import 'package:padel_app/services/amigo_service.dart';
import 'package:padel_app/services/api_service.dart';
import 'package:padel_app/services/storage_service.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:provider/provider.dart';

/// Отклик на нажатие в амигос.
///
/// Сервер отвечает не мгновенно. Пока ответа нет, кнопка должна показывать,
/// что нажатие поймано, — иначе человек жмёт второй и третий раз.
class _SlowProvider extends AmigoProvider {
  _SlowProvider(this._candidates)
      : super(AmigoService(ApiService()), StorageService());

  final List<AmigoCandidate> _candidates;
  final _completer = Completer<void>();
  final Set<int> _pendingIds = {};
  int follows = 0;

  @override
  List<Amigo> get amigos => const [];
  @override
  List<Amigo> get followers => const [];
  @override
  List<AmigoCandidate> get candidates => _candidates;
  @override
  bool isPending(int userId) => _pendingIds.contains(userId);

  @override
  Future<void> loadAmigos() async {}
  @override
  Future<void> loadFollowers() async {}
  @override
  Future<void> loadCandidates() async {}

  @override
  Future<bool> follow(int userId) async {
    if (_pendingIds.contains(userId)) return false;

    follows++;
    _pendingIds.add(userId);
    notifyListeners();

    await _completer.future;

    _pendingIds.remove(userId);
    notifyListeners();
    return true;
  }

  /// Ответ сервера «пришёл».
  void finish() => _completer.complete();
}

void main() {
  Widget wrap(AmigoProvider provider) =>
      ChangeNotifierProvider<AmigoProvider>.value(
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
          theme: ThemeData(scaffoldBackgroundColor: AppTheme.background),
          home: const AmigosScreen(),
        ),
      );

  testWidgets('нажатие на плюс сразу показывает крутилку', (tester) async {
    final provider = _SlowProvider(const [
      AmigoCandidate(id: 3, name: 'Diana', gamesTogether: 4, winrate: 75),
    ]);

    await tester.pumpWidget(wrap(provider));
    await tester.pump();

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Плюс сменился крутилкой прямо в кнопке.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);

    provider.finish();
    await tester.pumpAndSettle();
  });

  testWidgets('после ответа сервера крутилка сменяется галочкой', (tester) async {
    final provider = _SlowProvider(const [
      AmigoCandidate(id: 3, name: 'Diana', gamesTogether: 4, winrate: 75),
    ]);

    await tester.pumpWidget(wrap(provider));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    provider.finish();
    await tester.pumpAndSettle();

    // Запрос ушёл ровно один раз: повторные нажатия отсекает сам провайдер
    // (isPending), поэтому в UI второго запроса взяться неоткуда.
    expect(provider.follows, 1);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
