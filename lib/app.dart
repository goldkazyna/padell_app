import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'utils/profile_incomplete_guard.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/main_tab_notifier.dart';
import 'widgets/main_nav_pill.dart';
import 'services/push_notification_service.dart';
import 'services/api_service.dart';
import 'services/version_service.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tournaments_screen.dart';
import 'screens/rating_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/challenges_screen.dart';
import 'screens/club_select_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/quiz_screen.dart';

/// Global navigator key for navigation from push notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PadelApp extends StatelessWidget {
  const PadelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return MaterialApp(
      title: 'Padel',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      locale: localeProvider.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          switch (auth.status) {
            case AuthStatus.initial:
            case AuthStatus.checking:
              return const SplashScreen();
            case AuthStatus.onboarding:
              return const OnboardingScreen();
            case AuthStatus.unauthenticated:
              return const LoginScreen();
            case AuthStatus.authenticated:
              // Новый пользователь — показываем опросник для определения уровня
              if (auth.user != null && !auth.user!.quizCompleted) {
                return const QuizScreen();
              }
              return const MainScreen();
          }
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _updateDialogShown = false;
  DateTime? _lastVersionCheck;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateBadge();
    _checkForUpdate();
    _currentIndex = mainTabNotifier.value;
    mainTabNotifier.addListener(_handleTabFromNotifier);
  }

  void _handleTabFromNotifier() {
    if (!mounted) return;
    if (mainTabNotifier.value != _currentIndex) {
      setState(() => _currentIndex = mainTabNotifier.value);
    }
  }

  Future<void> _checkForUpdate() async {
    // Throttle: не дёргаем сервер чаще раза в 30 секунд
    final now = DateTime.now();
    if (_lastVersionCheck != null &&
        now.difference(_lastVersionCheck!) < const Duration(seconds: 30)) {
      return;
    }
    _lastVersionCheck = now;

    try {
      final versionService = VersionService(ApiService());
      final info = await versionService.checkVersion();
      if (info == null || !mounted) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final needsUpdate = VersionService.isVersionLower(currentVersion, info.latestVersion);
      final forceUpdate = VersionService.isVersionLower(currentVersion, info.minVersion);

      if (needsUpdate && mounted && !_updateDialogShown) {
        _updateDialogShown = true;
        _showUpdateDialog(info, forceUpdate || info.forceUpdate);
      }
    } catch (_) {}
  }

  void _showUpdateDialog(VersionInfo info, bool force) {
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (ctx) => PopScope(
        canPop: !force,
        child: Dialog(
          backgroundColor: AppTheme.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.system_update, color: AppTheme.accent, size: 48),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.updateAvailable,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  force
                      ? AppLocalizations.of(context)!.updateRequired
                      : AppLocalizations.of(context)!.newVersionAvailable,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final url = Uri.parse(info.storeUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url, mode: LaunchMode.externalApplication);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(AppLocalizations.of(context)!.updateButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                if (!force) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: Text(
                      AppLocalizations.of(context)!.later,
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    mainTabNotifier.removeListener(_handleTabFromNotifier);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateBadge();
      _updateDialogShown = false;
      _checkForUpdate();
    }
  }

  void _updateBadge() {
    try {
      context.read<PushNotificationService>().updateBadge();
    } catch (_) {}
  }

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _showProfileIncompleteDialog() {
    showProfileIncompleteDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateToTab: _navigateToTab),
      const TournamentsScreen(),
      const ClubSelectScreen(showBack: false),
      const RatingScreen(),
      const ProfileScreen(),
    ];

    return Consumer<HomeProvider>(
      builder: (_, home, __) {
        final incomplete = home.user?.isProfileIncomplete ?? false;

        final bottomInset = MediaQuery.of(context).padding.bottom;

        return Scaffold(
          backgroundColor: AppTheme.background,
          // Контент — на всю высоту; меню НЕ резервирует полосу снизу, а висит
          // оверлеем поверх ленты (как в инстаграме).
          body: Stack(
            children: [
              Positioned.fill(
                child: screens[_currentIndex],
              ),
              // Плавающая «таблетка» — только она и есть меню; вокруг ничего.
              Positioned(
                left: 16,
                right: 16,
                bottom: bottomInset > 0 ? bottomInset : 12,
                child: MainNavPill(
                  current: _currentIndex,
                  profileIncomplete: incomplete,
                  onSelect: (idx) {
                    setState(() => _currentIndex = idx);
                    mainTabNotifier.value = idx;
                    // Проверка версии при переключении вкладки (throttle внутри).
                    _checkForUpdate();
                  },
                  onLockedTap: _showProfileIncompleteDialog,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
