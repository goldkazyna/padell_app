import 'dart:developer' as developer;
import '../models/tournament.dart';
import 'api_service.dart';

class TournamentService {
  final ApiService _api;

  TournamentService(this._api);

  Future<List<Tournament>> getOpenTournaments(String token) async {
    final response = await _api.get('/tournaments', token);
    final list = response['tournaments'] as List<dynamic>;
    return list
        .map((json) => Tournament.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Tournament>> getMyTournaments(String token) async {
    final response = await _api.get('/tournaments/my', token);
    final list = response['tournaments'] as List<dynamic>;
    return list
        .map((json) => Tournament.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Tournament>> getArchiveTournaments(String token) async {
    final response = await _api.get('/tournaments/archive', token);
    final list = response['tournaments'] as List<dynamic>;
    return list
        .map((json) => Tournament.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Tournament> getTournamentDetails(int id, String token) async {
    final response = await _api.get('/tournaments/$id', token);
    final tournamentJson = response['tournament'] as Map<String, dynamic>;
    developer.log('Tournament detail keys: ${tournamentJson.keys.toList()}', name: 'TournamentService');
    developer.log('Participants raw: ${tournamentJson['participants']}', name: 'TournamentService');
    return Tournament.fromJson(tournamentJson);
  }

  Future<String> register(int tournamentId, String token) async {
    final response = await _api.post('/tournaments/$tournamentId/register', {}, token);
    return response['message'] as String;
  }

  Future<String> cancel(int tournamentId, String token) async {
    final response = await _api.post('/tournaments/$tournamentId/cancel', {}, token);
    return response['message'] as String;
  }

  // === Team registration ===

  Future<List<PartnerSearchResult>> searchPartner(int tournamentId, String phone, String token) async {
    developer.log('searchPartner: tournamentId=$tournamentId, phone=$phone', name: 'TournamentService');
    final response = await _api.post(
      '/tournaments/$tournamentId/search-partner',
      {'phone': phone},
      token,
    );
    developer.log('searchPartner response: $response', name: 'TournamentService');
    developer.log('searchPartner keys: ${response.keys.toList()}', name: 'TournamentService');
    final list = response['partners'] as List<dynamic>? ?? [];
    developer.log('searchPartner players count: ${list.length}', name: 'TournamentService');
    return list
        .map((json) => PartnerSearchResult.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<String> registerTeam(int tournamentId, int partnerId, String token) async {
    final response = await _api.post(
      '/tournaments/$tournamentId/register-team',
      {'partner_id': partnerId},
      token,
    );
    return response['message'] as String;
  }

  Future<String> cancelTeam(int tournamentId, String token) async {
    final response = await _api.post('/tournaments/$tournamentId/cancel-team', {}, token);
    return response['message'] as String;
  }
}
