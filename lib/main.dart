import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'services/deep_link_service.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/tournament_service.dart';
import 'services/home_service.dart';
import 'services/rating_service.dart';
import 'services/profile_service.dart';
import 'services/push_notification_service.dart';
import 'services/challenge_service.dart';
import 'providers/auth_provider.dart';
import 'providers/tournament_provider.dart';
import 'providers/home_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/challenge_provider.dart';
import 'services/court_service.dart';
import 'services/club_service.dart';
import 'services/admin_service.dart';
import 'services/invitation_service.dart';
import 'services/moderation_service.dart';
import 'services/support_service.dart';
import 'providers/court_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppTheme.background,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppTheme.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  debugPrint('[APP] ===== APP START =====');
  debugPrint('[APP] kIsWeb: $kIsWeb');

  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
      debugPrint('[APP] Firebase initialized OK');
    } catch (e) {
      debugPrint('[APP] Firebase init error: $e');
    }
  } else {
    debugPrint('[APP] Skipping Firebase on web');
  }

  final storageService = StorageService();
  final apiService = ApiService();
  final authService = AuthService(apiService, storageService);
  final tournamentService = TournamentService(apiService);
  final homeService = HomeService(apiService, storageService);
  final ratingService = RatingService(apiService, storageService);
  final profileService = ProfileService(apiService, storageService);
  final challengeService = ChallengeService(apiService);
  final courtService = CourtService(apiService, storageService);
  final clubService = ClubService(apiService, storageService);
  final adminService = AdminService(apiService, storageService);
  final invitationService = InvitationService(apiService, storageService);
  final moderationService = ModerationService(apiService, storageService);
  final supportService = SupportService(apiService, storageService);
  final pushService = PushNotificationService(apiService, storageService, navigatorKey);
  if (!kIsWeb) {
    try {
      pushService.initialize();
    } catch (e) {
      debugPrint('Push init error: $e');
    }

    try {
      DeepLinkService.instance.attachNavigator(navigatorKey);
      DeepLinkService.instance.init();
    } catch (e) {
      debugPrint('DeepLink init error: $e');
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => TournamentProvider(tournamentService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(homeService),
        ),
        ChangeNotifierProvider(
          create: (_) => RatingProvider(ratingService),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(profileService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChallengeProvider(challengeService, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => CourtProvider(courtService),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService),
        ),
        Provider<ProfileService>.value(value: profileService),
        Provider<RatingService>.value(value: ratingService),
        Provider<PushNotificationService>.value(value: pushService),
        Provider<ClubService>.value(value: clubService),
        Provider<AdminService>.value(value: adminService),
        Provider<InvitationService>.value(value: invitationService),
        Provider<ModerationService>.value(value: moderationService),
        Provider<SupportService>.value(value: supportService),
      ],
      child: const PadelApp(),
    ),
  );
}
