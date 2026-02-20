import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/tournament_service.dart';
import 'services/home_service.dart';
import 'services/rating_service.dart';
import 'services/profile_service.dart';
import 'services/push_notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/tournament_provider.dart';
import 'providers/home_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final storageService = StorageService();
  final apiService = ApiService();
  final authService = AuthService(apiService, storageService);
  final tournamentService = TournamentService(apiService);
  final homeService = HomeService(apiService, storageService);
  final ratingService = RatingService(apiService, storageService);
  final profileService = ProfileService(apiService, storageService);
  final pushService = PushNotificationService(apiService, storageService, navigatorKey);
  pushService.initialize();

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
        Provider<ProfileService>.value(value: profileService),
        Provider<PushNotificationService>.value(value: pushService),
      ],
      child: const PadelApp(),
    ),
  );
}
