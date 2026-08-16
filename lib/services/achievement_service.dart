import '../models/achievement.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Значки: свои с прогрессом, чужие только полученные.
class AchievementService {
  final ApiService _api;
  final StorageService _storage;

  AchievementService(this._api, this._storage);

  /// Свои значки. Сервер пересчитывает их на этом запросе.
  Future<List<Achievement>> mine() => _load('/achievements');

  /// Чужие — только полученные, без пересчёта на сервере.
  Future<List<Achievement>> ofPlayer(int userId) =>
      _load('/achievements/player/$userId');

  Future<List<Achievement>> _load(String endpoint) async {
    final token = await _storage.getToken();
    final response = await _api.get(endpoint, token);
    final list = (response['achievements'] as List?) ?? const [];
    return list
        .map((j) => Achievement.fromJson(j as Map<String, dynamic>))
        .toList();
  }
}
