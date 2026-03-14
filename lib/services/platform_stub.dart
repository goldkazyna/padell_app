// Stub for web platform where dart:io is not available
class Platform {
  static bool get isIOS => false;
  static bool get isAndroid => false;
  static String get operatingSystem => 'web';
}
