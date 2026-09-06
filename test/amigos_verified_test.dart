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
import 'package:padel_app/widgets/verified_badge.dart';
import 'package:provider/provider.dart';

/// Галочка подтверждённого уровня в амигос.
///
/// В рейтинге и в турнире она есть, а в списках амигос имя шло голым: люди
/// не понимали, почему один и тот же игрок «верифицирован» на одном экране и
/// нет на другом.
class _Fake extends AmigoProvider {
  _Fake({this.list = const [], this.cands = const []})
      : super(AmigoService(ApiService()), StorageService());

  final List<Amigo> list;
  final List<AmigoCandidate> cands;

  @override
  List<Amigo> get amigos => list;
  @override
  List<Amigo> get followers => const [];
  @override
  List<Amigo> get playing =>
      list.where((x) => x.status?.isPlaying == true).toList();
  @override
  List<AmigoCandidate> get candidates => cands;

  @override
  Future<void> loadAmigos() async {}
  @override
  Future<void> loadFollowers() async {}
  @override
  Future<void> loadCandidates() async {}
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

  test('флаг приходит с бэка и разбирается', () {
    final amigo = Amigo.fromJson(const {
      'id': 1,
      'name': 'Марина',
      'level_verified': true,
    });
    final plain = Amigo.fromJson(const {'id': 2, 'name': 'Пётр'});

    expect(amigo.levelVerified, isTrue);
    expect(plain.levelVerified, isFalse, reason: 'нет поля — нет галочки');

    final candidate = AmigoCandidate.fromJson(const {
      'id': 3,
      'name': 'Диана',
      'level_verified': true,
    });
    expect(candidate.levelVerified, isTrue);
  });

  testWidgets('у кандидата с подтверждённым уровнем есть галочка',
      (tester) async {
    await tester.pumpWidget(wrap(_Fake(cands: const [
      AmigoCandidate(id: 3, name: 'Диана', gamesTogether: 4, winrate: 75),
      AmigoCandidate(
        id: 4,
        name: 'Ержан',
        gamesTogether: 2,
        winrate: 50,
        levelVerified: true,
      ),
    ])));
    await tester.pump();

    // Ровно одна галочка на двоих: у неподтверждённого её быть не должно.
    expect(find.byType(VerifiedBadge), findsOneWidget);
  });

  testWidgets('в списке амигос галочка тоже есть', (tester) async {
    await tester.pumpWidget(wrap(_Fake(list: const [
      Amigo(id: 1, name: 'Марина', levelVerified: true),
      Amigo(id: 2, name: 'Пётр'),
    ])));
    await tester.pump();

    expect(find.byType(VerifiedBadge), findsOneWidget);
  });
}
