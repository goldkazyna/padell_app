import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

enum AuthStatus {
  initial,
  checking,
  authenticated,
  unauthenticated,
  onboarding,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;

  static const String telegramBotUsername = 'padel_kz_bot';

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _error;
  bool _isLoading = false;
  Timer? _telegramPollTimer;
  String? _telegramToken;
  bool _isTelegramWaiting = false;

  AuthProvider(this._authService, this._storageService);

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isTelegramWaiting => _isTelegramWaiting;
  String? get telegramToken => _telegramToken;

  Future<void> initialize() async {
    _status = AuthStatus.checking;
    notifyListeners();

    final hasToken = await _authService.hasToken();
    if (!hasToken) {
      final hasSeenOnboarding = await _storageService.hasSeenOnboarding();
      _status = hasSeenOnboarding ? AuthStatus.unauthenticated : AuthStatus.onboarding;
      notifyListeners();
      return;
    }

    final result = await _authService.getCurrentUser();
    if (result.success && result.user != null) {
      _user = result.user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    await _storageService.setOnboardingSeen();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> sendCode(String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _authService.sendCode(phone);

    _isLoading = false;
    _error = result.success ? null : result.message;
    notifyListeners();

    return result.success;
  }

  Future<bool> verifyCode(String phone, String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _authService.verifyCode(phone, code);

      _isLoading = false;

      if (result.success && result.user != null) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        _error = null;
      } else {
        _error = result.message;
      }
      notifyListeners();

      return result.success;
    } catch (e) {
      _isLoading = false;
      _error = 'Ошибка сети: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.logout();

    _user = null;
    _status = AuthStatus.unauthenticated;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final result = await _authService.getCurrentUser();
    if (result.success && result.user != null) {
      _user = result.user;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // --- Telegram Auth ---

  Future<String> startTelegramAuth() async {
    _isTelegramWaiting = true;
    _error = null;
    notifyListeners();

    final initData = await _authService.initTelegramAuth();
    _telegramToken = initData['token']!;
    final botUrl = initData['bot_url']!;

    _telegramPollTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _checkTelegramAuth(),
    );

    return botUrl;
  }

  Future<void> _checkTelegramAuth() async {
    if (_telegramToken == null) return;

    try {
      final result = await _authService.checkTelegramAuth(_telegramToken!);
      if (result.success && result.user != null) {
        _user = result.user;
        _status = AuthStatus.authenticated;
        _isTelegramWaiting = false;
        _stopTelegramPolling();
        notifyListeners();
      }
    } catch (_) {
      // Игнорируем ошибки сети при поллинге
    }
  }

  void cancelTelegramAuth() {
    _isTelegramWaiting = false;
    _stopTelegramPolling();
    notifyListeners();
  }

  void _stopTelegramPolling() {
    _telegramPollTimer?.cancel();
    _telegramPollTimer = null;
    _telegramToken = null;
  }

  @override
  void dispose() {
    _stopTelegramPolling();
    super.dispose();
  }
}
