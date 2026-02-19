import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'services/auth_service.dart';
import 'services/tournament_service.dart';
import 'services/home_service.dart';
import 'services/rating_service.dart';
import 'services/profile_service.dart';
import 'providers/auth_provider.dart';
import 'providers/tournament_provider.dart';
import 'providers/home_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/profile_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final apiService = ApiService();
  final authService = AuthService(apiService, storageService);
  final tournamentService = TournamentService(apiService);
  final homeService = HomeService(apiService, storageService);
  final ratingService = RatingService(apiService, storageService);
  final profileService = ProfileService(apiService, storageService);

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
      ],
      child: const PadelApp(),
    ),
  );
}
