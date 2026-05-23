import '../models/admin_club_user.dart';
import '../models/admin_matches.dart';
import '../models/admin_participant.dart';
import '../models/admin_participants_response.dart';
import '../models/admin_tournament_detail.dart';
import '../models/admin_tournament_summary.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Сервис для админских функций мобилы.
class AdminService {
  final ApiService _api;
  final StorageService _storage;

  AdminService(this._api, this._storage);

  // ---------------------------------------------------------------------------
  // Управление игроками клуба (feature 'users')
  // ---------------------------------------------------------------------------

  Future<AdminClubUsersPage> getClubUsers(
    int clubId, {
    String? search,
    String? level,
    String? exactLevel,
    String? verified, // 'verified' | 'unverified' | null
    int page = 1,
  }) async {
    final token = await _storage.getToken();
    final params = <String, String>{'page': '$page'};
    if ((search ?? '').isNotEmpty) params['search'] = search!;
    if ((level ?? '').isNotEmpty) params['level'] = level!;
    if ((exactLevel ?? '').isNotEmpty) params['exact_level'] = exactLevel!;
    if ((verified ?? '').isNotEmpty) params['verified'] = verified!;
    final qs = params.entries
        .map((e) =>
            '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final response =
        await _api.get('/admin/clubs/$clubId/users?$qs', token);
    return AdminClubUsersPage.fromJson(response);
  }

  Future<AdminClubUser> updateClubUser(
    int clubId,
    int userId, {
    required String name,
    required double? level,
  }) async {
    final token = await _storage.getToken();
    final response = await _api.put(
      '/admin/clubs/$clubId/users/$userId',
      {
        'name': name,
        'level': level,
      },
      token,
    );
    return AdminClubUser.fromJson(
      response['user'] as Map<String, dynamic>,
    );
  }

  /// Создать турнир (Этап 4). Возвращает id нового турнира.
  Future<int> createTournament(
      int clubId, Map<String, dynamic> body) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/clubs/$clubId/tournaments',
      body,
      token,
    );
    return (response['tournament_id'] as num).toInt();
  }

  /// Список турниров клуба со всеми статусами для админа.
  Future<List<AdminTournamentSummary>> getClubTournaments(int clubId) async {
    final token = await _storage.getToken();
    final response = await _api.get(
      '/admin/clubs/$clubId/tournaments',
      token,
    );
    final list = (response['tournaments'] as List?) ?? const [];
    return list
        .map((j) => AdminTournamentSummary.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Полные детали турнира для админа.
  Future<AdminTournamentDetail> getTournamentDetail(int id) async {
    final token = await _storage.getToken();
    final response = await _api.get('/admin/tournaments/$id', token);
    return AdminTournamentDetail.fromJson(
      response['tournament'] as Map<String, dynamic>,
    );
  }

  /// Обновить редактируемые поля турнира.
  Future<AdminTournamentDetail> updateTournament(
    int id, {
    required String name,
    String? description,
    required DateTime startDate,
    required double minLevel,
    required double maxLevel,
    required int maxParticipants,
    double? price,
  }) async {
    final token = await _storage.getToken();
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'min_level': minLevel,
      'max_level': maxLevel,
      'max_participants': maxParticipants,
      'price': price,
    };
    final response = await _api.put('/admin/tournaments/$id', body, token);
    return AdminTournamentDetail.fromJson(
      response['tournament'] as Map<String, dynamic>,
    );
  }

  /// Запустить турнир (`status: open` → `in_progress`).
  Future<AdminTournamentDetail> startTournament(int id) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$id/start',
      const {},
      token,
    );
    return AdminTournamentDetail.fromJson(
      response['tournament'] as Map<String, dynamic>,
    );
  }

  /// Перезапустить турнир (`in_progress` → `open`, сетка удаляется).
  Future<AdminTournamentDetail> restartTournament(int id) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$id/restart',
      const {},
      token,
    );
    return AdminTournamentDetail.fromJson(
      response['tournament'] as Map<String, dynamic>,
    );
  }

  /// Удалить турнир (только черновик).
  Future<void> deleteTournament(int id) async {
    final token = await _storage.getToken();
    await _api.delete('/admin/tournaments/$id', null, token);
  }

  // ---------------------------------------------------------------------------
  // Этап 3b — участники
  // ---------------------------------------------------------------------------

  Future<AdminParticipantsResponse> getParticipants(int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.get(
      '/admin/tournaments/$tournamentId/participants',
      token,
    );
    return AdminParticipantsResponse.fromJson(response);
  }

  Future<void> approveParticipant(int tournamentId, int userId) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/participants/$userId/approve',
      const {},
      token,
    );
  }

  Future<void> rejectParticipant(int tournamentId, int userId) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/participants/$userId/reject',
      const {},
      token,
    );
  }

  Future<void> removeParticipant(int tournamentId, int userId) async {
    final token = await _storage.getToken();
    await _api.delete(
      '/admin/tournaments/$tournamentId/participants/$userId',
      null,
      token,
    );
  }

  Future<void> addParticipant(int tournamentId, int userId) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/participants',
      {'user_id': userId},
      token,
    );
  }

  Future<void> replaceParticipant(
      int tournamentId, int oldUserId, int newUserId) async {
    final token = await _storage.getToken();
    await _api.put(
      '/admin/tournaments/$tournamentId/participants/$oldUserId',
      {'new_user_id': newUserId},
      token,
    );
  }

  Future<List<AdminParticipant>> searchPlayers(
      int tournamentId, String query) async {
    final token = await _storage.getToken();
    final encoded = Uri.encodeQueryComponent(query);
    final response = await _api.get(
      '/admin/tournaments/$tournamentId/players/search?q=$encoded',
      token,
    );
    final list = (response['players'] as List?) ?? const [];
    return list
        .map((j) => AdminParticipant.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> approveTeam(int tournamentId, int teamId) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/teams/$teamId/approve',
      const {},
      token,
    );
  }

  Future<void> rejectTeam(int tournamentId, int teamId) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/teams/$teamId/reject',
      const {},
      token,
    );
  }

  Future<void> removeTeam(int tournamentId, int teamId) async {
    final token = await _storage.getToken();
    await _api.delete(
      '/admin/tournaments/$tournamentId/teams/$teamId',
      null,
      token,
    );
  }

  // ---------------------------------------------------------------------------
  // Этап 3c-1 — матчи Американо
  // ---------------------------------------------------------------------------

  Future<AdminMatchesResponse> getMatches(int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.get(
      '/admin/tournaments/$tournamentId/matches',
      token,
    );
    return AdminMatchesResponse.fromJson(response);
  }

  Future<void> saveAmericanoScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
    required bool isUpdate,
  }) async {
    final token = await _storage.getToken();
    final endpoint =
        '/admin/tournaments/$tournamentId/americano/matches/$matchId/score';
    final body = {
      'team1_score': team1Score,
      'team2_score': team2Score,
    };
    if (isUpdate) {
      await _api.put(endpoint, body, token);
    } else {
      await _api.post(endpoint, body, token);
    }
  }

  Future<void> saveAmericanoPlayoffScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
    required bool isUpdate,
  }) async {
    final token = await _storage.getToken();
    final endpoint =
        '/admin/tournaments/$tournamentId/americano/playoff/$matchId/score';
    final body = {
      'team1_score': team1Score,
      'team2_score': team2Score,
    };
    if (isUpdate) {
      await _api.put(endpoint, body, token);
    } else {
      await _api.post(endpoint, body, token);
    }
  }

  // ---------------------------------------------------------------------------
  // Этап 3d — генерация плей-офф и завершение турнира
  // ---------------------------------------------------------------------------

  /// Сохранить счёт матча KOC (POST и PUT работают одинаково — KingOfCourtService
  /// сам откатит старые stat если матч уже completed).
  Future<void> saveKocScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
  }) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/kingofcourt/matches/$matchId/score',
      {
        'team1_score': team1Score,
        'team2_score': team2Score,
      },
      token,
    );
  }

  /// Сохранить счёт матча Bali KOC. POST/PUT одинаковы — сервис сам откатит
  /// прежние статы если матч уже completed. Счёт — в геймах.
  Future<void> saveBaliKocScore(
    int tournamentId,
    int matchId, {
    required int pair1Games,
    required int pair2Games,
  }) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/bali_koc/matches/$matchId/score',
      {
        'pair1_games': pair1Games,
        'pair2_games': pair2Games,
      },
      token,
    );
  }

  /// Получить список зарегистрированных участников + уже созданные пары Bali.
  /// Возвращает raw Map, чтобы UI экрана сам распарсил (особая структура).
  Future<Map<String, dynamic>> getBaliKocPairs(int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.get(
      '/admin/tournaments/$tournamentId/bali_koc/pairs',
      token,
    );
    return response;
  }

  /// Сохранить пары Bali. pairs — массив [[player1_id, player2_id], ...].
  Future<void> saveBaliKocPairs(
    int tournamentId,
    List<List<int>> pairs,
  ) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/bali_koc/pairs',
      {'pairs': pairs},
      token,
    );
  }

  /// Сгенерировать следующий раунд (KOC). Возвращает свежий /matches.
  Future<AdminMatchesResponse> generateNextRound(int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$tournamentId/next-round',
      const {},
      token,
    );
    return AdminMatchesResponse.fromJson(response);
  }

  /// Сгенерировать плей-офф (Американо). Возвращает свежий /matches.
  Future<AdminMatchesResponse> generatePlayoff(int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$tournamentId/playoff/generate',
      const {},
      token,
    );
    return AdminMatchesResponse.fromJson(response);
  }

  // === Team (Групповой + Плей-офф) ===

  /// Сохранить счёт группового матча команды. POST для нового, PUT для апдейта.
  Future<void> saveTeamGroupScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
    required bool isUpdate,
  }) async {
    final token = await _storage.getToken();
    final endpoint =
        '/admin/tournaments/$tournamentId/team/group-match/$matchId/score';
    final body = {'team1_score': team1Score, 'team2_score': team2Score};
    if (isUpdate) {
      await _api.put(endpoint, body, token);
    } else {
      await _api.post(endpoint, body, token);
    }
  }

  /// Сохранить счёт плей-офф матча команды.
  Future<void> saveTeamPlayoffScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
    required bool isUpdate,
  }) async {
    final token = await _storage.getToken();
    final endpoint =
        '/admin/tournaments/$tournamentId/team/playoff-match/$matchId/score';
    final body = {'team1_score': team1Score, 'team2_score': team2Score};
    if (isUpdate) {
      await _api.put(endpoint, body, token);
    } else {
      await _api.post(endpoint, body, token);
    }
  }

  /// Сгенерировать плей-офф для team-турнира.
  Future<AdminMatchesResponse> generateTeamPlayoff(int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$tournamentId/team/generate-playoff',
      const {},
      token,
    );
    return AdminMatchesResponse.fromJson(response);
  }

  /// Завершить турнир (с применением ELO).
  Future<AdminTournamentDetail> finishTournament(int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$tournamentId/finish',
      const {},
      token,
    );
    return AdminTournamentDetail.fromJson(
      response['tournament'] as Map<String, dynamic>,
    );
  }
}
