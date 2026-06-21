import '../models/tournament.dart';
import '../models/tournament_invitation.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Приглашения игрока на турниры (сторона игрока).
class InvitationService {
  final ApiService _api;
  final StorageService _storage;

  InvitationService(this._api, this._storage);

  Future<List<TournamentInvitation>> getInvitations() async {
    final token = await _storage.getToken();
    final r = await _api.get('/tournaments/invitations', token);
    final list = (r['invitations'] as List?) ?? const [];
    return list
        .map((j) => TournamentInvitation.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<int> getCount() async {
    final token = await _storage.getToken();
    final r = await _api.get('/tournaments/invitations/count', token);
    return (r['count'] as num?)?.toInt() ?? 0;
  }

  /// Возвращает {tournament_id, waitlisted}.
  Future<Map<String, dynamic>> accept(int id) async {
    final token = await _storage.getToken();
    return _api.post('/tournaments/invitations/$id/accept', {}, token);
  }

  Future<void> decline(int id) async {
    final token = await _storage.getToken();
    await _api.post('/tournaments/invitations/$id/decline', {}, token);
  }

  /// Турниры, на которые можно позвать игрока (открытые, по его уровню).
  Future<List<Tournament>> getInvitableTournaments(int playerId) async {
    final token = await _storage.getToken();
    final r = await _api.get('/tournaments/invitable?user_id=$playerId', token);
    final list = (r['tournaments'] as List?) ?? const [];
    return list
        .map((j) => Tournament.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Позвать игрока на турнир. Бросает ApiException с текстом при ошибке.
  Future<void> invitePlayer(int tournamentId, int playerId) async {
    final token = await _storage.getToken();
    await _api.post(
        '/tournaments/$tournamentId/invite-player', {'user_id': playerId}, token);
  }
}
