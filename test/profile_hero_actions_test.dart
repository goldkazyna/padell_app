import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:padel_app/l10n/app_localizations.dart';
import 'package:padel_app/providers/amigo_provider.dart';
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
  _Profile() : super(ProfileService(ApiService(), StorageService()));
}

class _Amigo extends AmigoProvider {
  _Amigo() : super(AmigoService(ApiService()), StorageService());

  @override
  int get unread => 0;

  @override
  Future<void> loadUnread() async {}
}

void main() {
  testWidgets('в шапке и сообщения, и карандаш', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileProvider>.value(value: _Profile()),
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

    expect(find.byType(ChatIconButton), findsOneWidget, reason: 'сообщения');
    expect(find.byIcon(Icons.edit_outlined), findsOneWidget, reason: 'карандаш');
  });
}
