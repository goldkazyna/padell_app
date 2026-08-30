import '../models/league.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Лиги в админке приложения: создать, вести состав, добавлять этапы.
///
/// Правила те же, что в веб-CRM: сервер зовёт общий LeagueService, поэтому
/// лигу можно завести с телефона и довести с компьютера.
class AdminLeagueService {
  final ApiService _api;
  final StorageService _storage;

  AdminLeagueService(this._api, this._storage);

  Future<List<League>> list() async {
    final token = await _storage.getToken();
    final response = await _api.get('/admin/leagues', token);
    final raw = (response['leagues'] as List<dynamic>?) ?? const [];

    return raw.map((item) => League.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<League> details(int id) async {
    final token = await _storage.getToken();
    final response = await _api.get('/admin/leagues/$id', token);

    return League.fromJson(response['league'] as Map<String, dynamic>);
  }

  Future<League> create({
    required String name,
    required int stagesPlanned,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    double? minLevel,
    double? maxLevel,
    int? maxPlayers,
    int? price,
    bool isRated = true,
  }) async {
    final token = await _storage.getToken();
    final response = await _api.post('/admin/leagues', {
      'name': name,
      'stages_planned': stagesPlanned,
      if (description != null && description.isNotEmpty) 'description': description,
      if (startDate != null) 'start_date': startDate.toIso8601String(),
      if (endDate != null) 'end_date': endDate.toIso8601String(),
      if (minLevel != null) 'min_level': minLevel,
      if (maxLevel != null) 'max_level': maxLevel,
      if (maxPlayers != null) 'max_players': maxPlayers,
      if (price != null) 'price': price,
      'is_rated': isRated,
    }, token);

    return League.fromJson(response['league'] as Map<String, dynamic>);
  }

  Future<void> update(int id, Map<String, dynamic> body) async {
    final token = await _storage.getToken();
    await _api.put('/admin/leagues/$id', body, token);
  }

  /// Создать этап. Возвращает id созданного турнира — можно сразу открыть.
  Future<int> addStage(
    int leagueId, {
    required DateTime startDate,
    required int maxParticipants,
    String? name,
    int? courtsCount,
    int? price,
    bool? isPaired,
  }) async {
    final token = await _storage.getToken();
    final response = await _api.post('/admin/leagues/$leagueId/stages', {
      'start_date': startDate.toIso8601String(),
      'max_participants': maxParticipants,
      if (name != null && name.isNotEmpty) 'name': name,
      if (courtsCount != null) 'courts_count': courtsCount,
      if (price != null) 'price': price,
      // Не передаём вовсе — сервер возьмёт парность лиги.
      if (isPaired != null) 'is_paired': isPaired,
    }, token);

    return (response['tournament_id'] as num).toInt();
  }

  /// Удалить этап. Сервер откажет, если этап уже завершён.
  Future<void> removeStage(int leagueId, int stageId) async {
    final token = await _storage.getToken();
    await _api.delete('/admin/leagues/$leagueId/stages/$stageId', null, token);
  }

  Future<List<Map<String, dynamic>>> searchPlayers(int leagueId, String query) async {
    final token = await _storage.getToken();
    final encoded = Uri.encodeQueryComponent(query);
    final response = await _api.get('/admin/leagues/$leagueId/players/search?q=$encoded', token);

    return ((response['players'] as List<dynamic>?) ?? const [])
        .map((p) => p as Map<String, dynamic>)
        .toList();
  }

  Future<void> addPlayer(int leagueId, int userId) async {
    final token = await _storage.getToken();
    await _api.post('/admin/leagues/$leagueId/players', {'user_id': userId}, token);
  }

  Future<void> removePlayer(int leagueId, int userId) async {
    final token = await _storage.getToken();
    await _api.delete('/admin/leagues/$leagueId/players/$userId', null, token);
  }
}
