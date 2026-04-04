import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LocaleProvider extends ChangeNotifier {
  final StorageService _storage;
  Locale _locale = const Locale('ru');

  LocaleProvider(this._storage) {
    _loadSavedLocale();
  }

  Locale get locale => _locale;

  bool get isRussian => _locale.languageCode == 'ru';
  bool get isEnglish => _locale.languageCode == 'en';

  Future<void> _loadSavedLocale() async {
    final saved = await _storage.getLocale();
    if (saved != null) {
      _locale = Locale(saved);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _storage.saveLocale(locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    final newLocale = isRussian ? const Locale('en') : const Locale('ru');
    await setLocale(newLocale);
  }
}
