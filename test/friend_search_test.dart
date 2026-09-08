import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/models/tournament.dart';
import 'package:padel_app/providers/tournament_provider.dart';
import 'package:padel_app/services/api_service.dart';
import 'package:padel_app/services/storage_service.dart';
import 'package:padel_app/services/tournament_service.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/tournaments/friend_registration_sheet.dart';
import 'package:provider/provider.dart';

/// Поиск друга при записи на турнир.
///
/// Поле принимало только цифры и искало от пяти: найти человека по имени
/// было нельзя, хотя сервер это умеет — как в рейтинге.
class _Fake extends TournamentProvider {
  _Fake() : super(TournamentService(ApiService()), StorageService());

  final queries = <String>[];

  @override
  Future<void> searchPartner(int tournamentId, String query) async {
    queries.add(query);
  }

  @override
  void clearPartnerSearch() {}

  @override
  List<PartnerSearchResult> get partnerSearchResults => const [];

  @override
  bool get isSearchingPartner => false;
}

void main() {
  Future<_Fake> pump(WidgetTester tester) async {
    final provider = _Fake();

    await tester.pumpWidget(ChangeNotifierProvider<TournamentProvider>.value(
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
        home: Scaffold(
          backgroundColor: AppTheme.background,
          body: const FriendRegistrationSheet(tournamentId: 1),
        ),
      ),
    ));
    await tester.pump();

    return provider;
  }

  testWidgets('ищет по имени, а не только по цифрам', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final provider = await pump(tester);

    await tester.enterText(find.byType(TextField), 'Ержан');
    await tester.pump(const Duration(milliseconds: 600));

    expect(provider.queries, ['Ержан']);
  });

  testWidgets('номер уходит как есть — сервер разберётся', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final provider = await pump(tester);

    await tester.enterText(find.byType(TextField), '+7 777 433');
    await tester.pump(const Duration(milliseconds: 600));

    expect(provider.queries, ['+7 777 433']);
  });

  testWidgets('одна буква запрос не шлёт', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final provider = await pump(tester);

    await tester.enterText(find.byType(TextField), 'Е');
    await tester.pump(const Duration(milliseconds: 600));

    expect(provider.queries, isEmpty);
  });
}
