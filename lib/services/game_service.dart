import '../models/game.dart';
import 'api_service.dart';

class GameService {
  final ApiService _api;

  GameService(this._api);

  String _buildQuery(Map<String, dynamic> query) {
    final parts = <String>[];
    query.forEach((key, value) {
      if (value == null) return;
      final stringValue = value.toString();
      if (stringValue.isEmpty) return;
      parts.add('$key=${Uri.encodeQueryComponent(stringValue)}');
    });
    return parts.isEmpty ? '' : '?${parts.join('&')}';
  }

  ({List<Game> items, int total, int lastPage, int currentPage})
      _parseGamesPage(Map<String, dynamic> response) {
    final list = response['data'] as List<dynamic>? ?? [];
    final items =
        list.map((json) => Game.fromJson(json as Map<String, dynamic>)).toList();

    final meta = response['meta'] as Map<String, dynamic>? ?? {};

    return (
      items: items,
      total: meta['total'] as int? ?? 0,
      lastPage: meta['last_page'] as int? ?? 1,
      currentPage: meta['current_page'] as int? ?? 1,
    );
  }

  Future<List<GameClub>> getClubs(String token) async {
    final response = await _api.get('/games/clubs', token);
    final list = response['data'] as List<dynamic>;
    return list
        .map((json) => GameClub.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<({List<Game> items, int total, int lastPage, int currentPage})>
      getFeed(Map<String, dynamic> query, String token) async {
    final response = await _api.get('/games${_buildQuery(query)}', token);
    return _parseGamesPage(response);
  }

  Future<({List<Game> items, int total, int lastPage, int currentPage})>
      getMyGames(Map<String, dynamic> query, String token) async {
    final response = await _api.get('/games/my${_buildQuery(query)}', token);
    return _parseGamesPage(response);
  }

  Future<List<GameInvitationItem>> getInvitations(
    String? status,
    String token,
  ) async {
    final endpoint = status != null
        ? '/games/invitations?status=$status'
        : '/games/invitations';
    final response = await _api.get(endpoint, token);
    final list = response['data'] as List<dynamic>;
    return list
        .map((json) => GameInvitationItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Game> getDetails(int id, String token) async {
    final response = await _api.get('/games/$id', token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> create(Map<String, dynamic> data, String token) async {
    final response = await _api.post('/games', data, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> update(int id, Map<String, dynamic> data, String token) async {
    final response = await _api.put('/games/$id', data, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> searchPartner(
    int gameId,
    String phone,
    String token,
  ) async {
    final response =
        await _api.post('/games/$gameId/search-player', {'phone': phone}, token);
    final list = response['partners'] as List<dynamic>? ??
        (response['data'] as Map<String, dynamic>?)?['partners'] as List<dynamic>? ??
        [];
    return list.map((p) => p as Map<String, dynamic>).toList();
  }

  Future<Game> invite(int id, int userId, String token) async {
    final response =
        await _api.post('/games/$id/invite', {'user_id': userId}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> apply(int id, String token) async {
    final response = await _api.post('/games/$id/apply', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> approveApplication(int id, int playerId, String token) async {
    final response = await _api.post(
      '/games/$id/applications/$playerId/approve',
      {},
      token,
    );
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> rejectApplication(int id, int playerId, String token) async {
    final response = await _api.post(
      '/games/$id/applications/$playerId/reject',
      {},
      token,
    );
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> accept(int id, String token) async {
    final response = await _api.post('/games/$id/accept', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> decline(int id, String token) async {
    final response = await _api.post('/games/$id/decline', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> leave(int id, String token) async {
    final response = await _api.post('/games/$id/leave', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> removePlayer(int id, int playerId, String token) async {
    final response =
        await _api.post('/games/$id/players/$playerId/remove', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> start(int id, String token) async {
    final response = await _api.post('/games/$id/start', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> startCancel(int id, String token) async {
    final response = await _api.post('/games/$id/start-cancel', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> finish(int id, String token) async {
    final response = await _api.post('/games/$id/finish', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> confirmScore(int id, String token) async {
    final response = await _api.post('/games/$id/confirm-score', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> regenerateSchedule(int id, String token) async {
    final response =
        await _api.post('/games/$id/schedule/regenerate', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> addRound(int id, Map<String, dynamic> body, String token) async {
    final response = await _api.post('/games/$id/rounds', body, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> updateRound(
    int id,
    int roundId,
    Map<String, dynamic> body,
    String token,
  ) async {
    final response =
        await _api.put('/games/$id/rounds/$roundId', body, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> deleteRound(int id, int roundId, String token) async {
    final response =
        await _api.delete('/games/$id/rounds/$roundId', null, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> shareRotate(int id, String token) async {
    final response = await _api.post('/games/$id/share/rotate', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> shareRevoke(int id, String token) async {
    final response = await _api.post('/games/$id/share/revoke', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> transferInitiate(int id, int toUserId, String token) async {
    final response = await _api.post(
      '/games/$id/transfer',
      {'to_user_id': toUserId},
      token,
    );
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> transferCancel(int id, String token) async {
    final response = await _api.post('/games/$id/transfer/cancel', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> transferAccept(int id, String token) async {
    final response = await _api.post('/games/$id/transfer/accept', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> transferDecline(int id, String token) async {
    final response = await _api.post('/games/$id/transfer/decline', {}, token);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<Game> resolveByShare(String tokenParam, String authToken) async {
    final response = await _api.get('/games/by-share/$tokenParam', authToken);
    return Game.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getLogs(int id, String token) async {
    final response = await _api.get('/games/$id/logs', token);
    final list = response['data'] as List<dynamic>;
    return list.map((log) => log as Map<String, dynamic>).toList();
  }
}
