import '../models/league.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Лиги игрока: список, карточка со сводной таблицей, запись.
class LeagueService {
  final ApiService _api;
  final StorageService _storage;

  LeagueService(this._api, this._storage);

  Future<List<League>> list() async {
    final token = await _storage.getToken();
    final response = await _api.get('/leagues', token);

    return _parseList(response);
  }

  /// Мои лиги — для профиля: с местом, очками и числом сыгранных этапов.
  Future<List<League>> mine() async {
    final token = await _storage.getToken();
    final response = await _api.get('/leagues/my', token);

    return _parseList(response);
  }

  Future<League> details(int id) async {
    final token = await _storage.getToken();
    final response = await _api.get('/leagues/$id', token);

    return League.fromJson(response['league'] as Map<String, dynamic>);
  }

  Future<void> register(int id) async {
    final token = await _storage.getToken();
    await _api.post('/leagues/$id/register', {}, token);
  }

  Future<void> cancel(int id) async {
    final token = await _storage.getToken();
    await _api.post('/leagues/$id/cancel', {}, token);
  }

  List<League> _parseList(Map<String, dynamic> response) {
    final raw = (response['leagues'] as List<dynamic>?) ?? const [];

    return raw
        .map((item) => League.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
