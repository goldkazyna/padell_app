import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/providers/amigo_provider.dart';
import 'package:padel_app/models/user.dart';
import 'package:padel_app/providers/profile_provider.dart';
import 'package:padel_app/providers/settings_provider.dart';
import 'package:padel_app/services/amigo_service.dart';
import 'package:padel_app/services/api_service.dart';
import 'package:padel_app/services/profile_service.dart';
import 'package:padel_app/services/storage_service.dart';
import 'package:padel_app/theme/app_theme.dart';
import 'package:padel_app/widgets/chat_icon_button.dart';
import 'package:padel_app/widgets/profile/messages_bell.dart';
import 'package:padel_app/widgets/profile/profile_hero.dart';
import 'package:provider/provider.dart';

/// Кнопки в шапке профиля.
///
/// Когда в шапку добавили чат, он встал на место карандаша «редактировать
/// профиль», и менять имя стало негде, кроме меню внизу. Теперь обе кнопки
/// стоят рядом.
class _Profile extends ProfileProvider {
  _Profile(this._user) : super(ProfileService(ApiService(), StorageService()));

  final User? _user;

  @override
  User? get user => _user;
}

User _player({String? whatsapp, String? telegram}) => User.fromJson({
      'id': 19,
      'name': 'Денис Дудников',
      'phone': '77774333822',
      'rating': 2689,
      'level': '2.50',
      if (whatsapp != null) 'whatsapp': whatsapp,
      if (telegram != null) 'telegram_username': telegram,
    });

class _Amigo extends AmigoProvider {
  _Amigo() : super(AmigoService(ApiService()), StorageService());

  @override
  int get unread => 0;

  @override
  Future<void> loadUnread() async {}
}

void main() {
  Future<void> pumpHero(WidgetTester tester, User? user) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>.value(value: _Profile(user)),
        ChangeNotifierProvider<AmigoProvider>.value(value: _Amigo()),
        ChangeNotifierProvider<SettingsProvider>.value(
          value: SettingsProvider(StorageService()),
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
          body: const SingleChildScrollView(
            child: ProfileHero(trailing: MessagesBell()),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  /// Жёлтая точка у карандаша — контейнер 9×9 внутри шапки.
  Finder dot() => find.byWidgetPredicate((w) =>
      w is Container &&
      w.constraints?.maxWidth == 9 &&
      w.constraints?.maxHeight == 9);

  testWidgets('в шапке и сообщения, и карандаш', (tester) async {
    await pumpHero(tester, _player(telegram: 'denis'));

    expect(find.byType(ChatIconButton), findsOneWidget, reason: 'сообщения');
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget, reason: 'карандаш');
  });

  testWidgets('без мессенджеров у карандаша горит точка', (tester) async {
    await pumpHero(tester, _player());

    expect(dot(), findsOneWidget);
  });

  testWidgets('хватает одного заполненного — точка гаснет', (tester) async {
    await pumpHero(tester, _player(whatsapp: '77774333822'));
    expect(dot(), findsNothing);

    await pumpHero(tester, _player(telegram: 'denis'));
    expect(dot(), findsNothing);
  });
}
