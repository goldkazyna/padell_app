import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _onboardingKey = 'onboarding_seen';
  static const _localeKey = 'app_locale';

  final FlutterSecureStorage? _storage;
  final Map<String, String> _webStorage = {};

  StorageService()
      : _storage = kIsWeb
            ? null
            : const FlutterSecureStorage(
                aOptions: AndroidOptions(encryptedSharedPreferences: true),
              );

  Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      _webStorage[key] = value;
    } else {
      await _storage!.write(key: key, value: value);
    }
  }

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      return _webStorage[key];
    }
    return _storage!.read(key: key);
  }

  Future<void> _delete(String key) async {
    if (kIsWeb) {
      _webStorage.remove(key);
    } else {
      await _storage!.delete(key: key);
    }
  }

  Future<void> saveToken(String token) async {
    await _write(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return _read(_tokenKey);
  }

  Future<void> deleteToken() async {
    await _delete(_tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> hasSeenOnboarding() async {
    final value = await _read(_onboardingKey);
    return value == 'true';
  }

  Future<void> setOnboardingSeen() async {
    await _write(_onboardingKey, 'true');
  }

  Future<void> saveLocale(String locale) async {
    await _write(_localeKey, locale);
  }

  Future<String?> getLocale() async {
    return _read(_localeKey);
  }
}
