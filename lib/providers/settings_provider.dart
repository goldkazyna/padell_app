import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;
  bool _preciseRating = false;

  SettingsProvider(this._storage) {
    _load();
  }

  bool get preciseRating => _preciseRating;

  Future<void> _load() async {
    _preciseRating = await _storage.getPreciseRating();
    notifyListeners();
  }

  Future<void> setPreciseRating(bool value) async {
    if (_preciseRating == value) return;
    _preciseRating = value;
    await _storage.savePreciseRating(value);
    notifyListeners();
  }
}
