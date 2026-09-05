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

/// Карточка амигос в профиле — лента аватаров.
///
/// В профиле важно не «кто у меня есть», а «кто сейчас на корте»: поэтому
/// проверяем, что играющие видны сразу и подписаны, а пустая лента всё равно
/// предлагает действие.
class _FakeAmigoProvider extends AmigoProvider {
  _FakeAmigoProvider(this._amigos)
      : super(AmigoService(ApiService()), StorageService());

  final List<Amigo> _amigos;

  @override
  List<Amigo> get amigos => _amigos;

  @override
  List<Amigo> get playing =>
      _amigos.where((a) => a.status?.isPlaying == true).toList();

  // Сеть в тесте не нужна: данные подставлены выше.
  @override
  Future<void> loadSummary() async {}
}

void main() {
  Widget wrap(List<Amigo> amigos) {
    return ChangeNotifierProvider<AmigoProvider>.value(
      value: _FakeAmigoProvider(amigos),
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
          body: const AmigosCard(),
        ),
      ),
    );
  }

  const playingAmigo = Amigo(
    id: 1,
    name: 'Асхат Ким',
    status: AmigoStatus(
      kind: 'playing',
      title: 'играет',
      subtitle: 'Американо · Padel Sai',
      tournamentId: 1439,
    ),
  );

  const quietAmigo = Amigo(id: 2, name: 'Юлия Жукова', level: 2.75, rating: 2610);

  testWidgets('пустая лента всё равно предлагает добавить', (tester) async {
    await tester.pumpWidget(wrap(const []));
    await tester.pump();

    expect(find.text('В амигос'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Добавьте тех, с кем играете'), findsOneWidget);
  });

  testWidgets('под аватаром только имя, без фамилии', (tester) async {
    await tester.pumpWidget(wrap(const [playingAmigo, quietAmigo]));
    await tester.pump();

    expect(find.text('Асхат'), findsOneWidget);
    expect(find.text('Юлия'), findsOneWidget);
    expect(find.text('Асхат Ким'), findsNothing);
  });

  testWidgets('играющие вынесены в бейдж вместо общего числа', (tester) async {
    await tester.pumpWidget(wrap(const [playingAmigo, quietAmigo]));
    await tester.pump();

    expect(find.text('СЕЙЧАС ИГРАЮТ 1'), findsOneWidget);
    // Общее число прячем: оно менее ценно, чем «кто на корте».
    expect(find.text('2'), findsNothing);
  });

  testWidgets('когда никто не играет — показываем сколько всего', (tester) async {
    await tester.pumpWidget(wrap(const [quietAmigo, quietAmigo]));
    await tester.pump();

    expect(find.text('2'), findsOneWidget);
    expect(find.textContaining('СЕЙЧАС ИГРАЮТ'), findsNothing);
  });

  testWidgets('лента листается вбок, а не переносится', (tester) async {
    final many = List.generate(
      12,
      (i) => Amigo(id: i + 10, name: 'Игрок $i'),
    );

    await tester.pumpWidget(wrap(many));
    await tester.pump();

    final list = tester.widget<ListView>(find.byType(ListView));
    expect(list.scrollDirection, Axis.horizontal);
  });
}
