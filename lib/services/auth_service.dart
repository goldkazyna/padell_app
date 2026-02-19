import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthResult {
  final bool success;
  final String? message;
  final User? user;
  final String? token;

  AuthResult({
    required this.success,
    this.message,
    this.user,
    this.token,
  });
}

class AuthService {
  final ApiService _api;
  final StorageService _storage;

  AuthService(this._api, this._storage);

  Future<AuthResult> sendCode(String phone) async {
    try {
      final response = await _api.post('/auth/send-code', {'phone': phone});
      return AuthResult(
        success: response['success'] as bool,
        message: response['message'] as String?,
      );
    } on ApiException catch (e) {
      return AuthResult(success: false, message: e.message);
    }
  }

  Future<AuthResult> verifyCode(String phone, String code) async {
    try {
      final response = await _api.post('/auth/verify-code', {
        'phone': phone,
        'code': code,
      });

      if (response['success'] == true) {
        final token = response['token'] as String;
        final userData = response['user'] as Map<String, dynamic>;

        if (!userData.containsKey('level_name')) {
          userData['level_name'] = '';
        }

        final user = User.fromJson(userData);
        await _storage.saveToken(token);

        return AuthResult(
          success: true,
          token: token,
          user: user,
        );
      }

      return AuthResult(
        success: false,
        message: response['message'] as String? ?? 'Неверный код',
      );
    } on ApiException catch (e) {
      return AuthResult(success: false, message: e.message);
    }
  }

  Future<AuthResult> getCurrentUser() async {
    final token = await _storage.getToken();
    if (token == null) {
      return AuthResult(success: false, message: 'Не авторизован');
    }

    try {
      final response = await _api.get('/auth/user', token);

      if (response['success'] == true) {
        final user = User.fromJson(response['user'] as Map<String, dynamic>);
        return AuthResult(success: true, user: user, token: token);
      }

      await _storage.deleteToken();
      return AuthResult(success: false, message: 'Сессия истекла');
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        await _storage.deleteToken();
      }
      return AuthResult(success: false, message: e.message);
    }
  }

  Future<void> logout() async {
    final token = await _storage.getToken();
    if (token != null) {
      try {
        await _api.post('/auth/logout', {}, token);
      } catch (_) {
        // Ignore errors on logout
      }
    }
    await _storage.deleteToken();
  }

  Future<Map<String, String>> initTelegramAuth() async {
    final response = await _api.post('/auth/telegram/init', {});
    return {
      'token': response['token'] as String,
      'bot_url': response['bot_url'] as String,
    };
  }

  Future<AuthResult> checkTelegramAuth(String token) async {
    try {
      final response = await _api.get('/auth/telegram/check?token=$token');

      if (response['success'] == true) {
        final jwtToken = response['token'] as String;
        final userData = response['user'] as Map<String, dynamic>;

        if (!userData.containsKey('level_name')) {
          userData['level_name'] = '';
        }
        if (!userData.containsKey('name') || userData['name'] == null) {
          final firstName = userData['first_name'] ?? '';
          final lastName = userData['last_name'] ?? '';
          userData['name'] = '$firstName $lastName'.trim();
        }

        final user = User.fromJson(userData);
        await _storage.saveToken(jwtToken);

        return AuthResult(success: true, token: jwtToken, user: user);
      }

      return AuthResult(success: false);
    } on ApiException {
      return AuthResult(success: false);
    }
  }

  Future<bool> hasToken() => _storage.hasToken();
}
