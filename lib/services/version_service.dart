import 'dart:io' if (dart.library.js_interop) 'platform_stub.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'api_service.dart';

class VersionInfo {
  final String minVersion;
  final String latestVersion;
  final bool forceUpdate;
  final String storeUrl;

  VersionInfo({
    required this.minVersion,
    required this.latestVersion,
    required this.forceUpdate,
    required this.storeUrl,
  });

  factory VersionInfo.fromJson(Map<String, dynamic> json) {
    return VersionInfo(
      minVersion: json['min_version'] as String? ?? '0.0.0',
      latestVersion: json['latest_version'] as String? ?? '0.0.0',
      forceUpdate: json['force_update'] as bool? ?? false,
      storeUrl: json['store_url'] as String? ?? '',
    );
  }
}

class VersionService {
  final ApiService _api;

  VersionService(this._api);

  Future<VersionInfo?> checkVersion() async {
    if (kIsWeb) return null;

    try {
      final platform = Platform.isIOS ? 'ios' : 'android';
      final response = await _api.get('/app/version?platform=$platform', null);
      if (response['success'] == true) {
        return VersionInfo.fromJson(response);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Сравнение версий: возвращает true если current < required
  static bool isVersionLower(String current, String required) {
    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final requiredParts = required.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      final c = i < currentParts.length ? currentParts[i] : 0;
      final r = i < requiredParts.length ? requiredParts[i] : 0;
      if (c < r) return true;
      if (c > r) return false;
    }
    return false;
  }
}
