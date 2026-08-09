import '../models/admin_club_edit.dart';
import '../models/admin_club_moderator.dart';
import '../models/admin_club_user.dart';
import '../models/admin_invitation.dart';
import '../models/admin_matches.dart';
import '../models/admin_participant.dart';
import '../models/admin_participants_response.dart';
import '../models/admin_tournament_detail.dart';
import '../models/registration_log_entry.dart';
import '../models/admin_tournament_summary.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Сервис для админских функций мобилы.
class AdminService {
  final ApiService _api;
  final StorageService _storage;

  AdminService(this._api, this._storage);

  // ---------------------------------------------------------------------------
  // Управление клубом
  // ---------------------------------------------------------------------------

  Future<AdminClubEdit> getClub(int clubId) async {
    final token = await _storage.getToken();
    final response = await _api.get('/admin/clubs/$clubId', token);
    return AdminClubEdit.fromJson(response['club'] as Map<String, dynamic>);
  }

  Future<AdminClubEdit> updateClub(int clubId, Map<String, dynamic> body) async {
    final token = await _storage.getToken();
    final response = await _api.put('/admin/clubs/$clubId', body, token);
    return AdminClubEdit.fromJson(response['club'] as Map<String, dynamic>);
  }

  /// Поиск клубов для выбора площадки турнира. Возвращает список
  /// {id, name, city}. Пустой запрос — вернёт первые клубы.
  Future<List<Map<String, dynamic>>> searchClubs(String query) async {
    final token = await _storage.getToken();
    final q = Uri.encodeQueryComponent(query.trim());
    final response = await _api.get('/clubs?search=$q', token);
    final list = (response['clubs'] as List? ?? []).cast<Map<String, dynamic>>();
    return list
        .map((c) => {
              'id': c['id'],
              'name': c['name'],
              'city': c['city'],
            })
        .toList();
  }

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

  // ---------------------------------------------------------------------------
  // Управление модераторами клуба (feature 'moderators')
  // ---------------------------------------------------------------------------

  Future<List<AdminClubModerator>> getClubModerators(int clubId) async {
    final token = await _storage.getToken();
    final response = await _api.get('/admin/clubs/$clubId/moderators', token);
    final list = (response['moderators'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(AdminClubModerator.fromJson)
        .toList();
  }

  Future<List<ModeratorCandidate>> searchModeratorCandidates(
      int clubId, String phone) async {
    final token = await _storage.getToken();
    final response = await _api.get(
      '/admin/clubs/$clubId/moderators/search?phone=${Uri.encodeQueryComponent(phone)}',
      token,
    );
    final list = (response['users'] as List?) ?? const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(ModeratorCandidate.fromJson)
        .toList();
  }

  Future<AdminClubModerator> addModerator(
    int clubId, {
    required int userId,
    required bool tournamentsFullAccess,
    required bool canViewActivityLog,
  }) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/clubs/$clubId/moderators',
      {
        'user_id': userId,
        'tournaments_full_access': tournamentsFullAccess,
        'can_view_activity_log': canViewActivityLog,
      },
      token,
    );
    return AdminClubModerator.fromJson(
        response['moderator'] as Map<String, dynamic>);
  }

  Future<AdminClubModerator> updateModeratorPermissions(
    int clubId,
    int userId, {
    required bool tournamentsFullAccess,
    required bool canViewActivityLog,
  }) async {
    final token = await _storage.getToken();
    final response = await _api.put(
      '/admin/clubs/$clubId/moderators/$userId/permissions',
      {
        'tournaments_full_access': tournamentsFullAccess,
        'can_view_activity_log': canViewActivityLog,
      },
      token,
    );
    return AdminClubModerator.fromJson(
        response['moderator'] as Map<String, dynamic>);
  }

  Future<void> removeModerator(int clubId, int userId) async {
    final token = await _storage.getToken();
    await _api.delete('/admin/clubs/$clubId/moderators/$userId', null, token);
  }

  /// Создать турнир (Этап 4). Возвращает id нового турнира.
  ///
  /// [moderationHours] — таймер модерации (часов). Передаётся в теле запроса
  /// только когда не null; пусто = без таймера.
  /// [moderationMinutes] — таймер модерации (минут, для отладки). Если задан,
  /// на бэкенде важнее часов. Передаётся только когда не null.
  Future<int> createTournament(
    int clubId,
    Map<String, dynamic> body, {
    int? moderationHours,
    int? moderationMinutes,
  }) async {
    final token = await _storage.getToken();
    final payload = <String, dynamic>{
      ...body,
      'moderation_hours': ?moderationHours,
      'moderation_minutes': ?moderationMinutes,
    };
    final response = await _api.post(
      '/admin/clubs/$clubId/tournaments',
      payload,
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

  // ===== Личные (приватные) турниры обычного игрока с грантом =====

  Future<int> createPersonalTournament(
    Map<String, dynamic> body, {
    int? moderationHours,
    int? moderationMinutes,
  }) async {
    final token = await _storage.getToken();
    final payload = <String, dynamic>{
      ...body,
      'moderation_hours': ?moderationHours,
      'moderation_minutes': ?moderationMinutes,
    };
    final response = await _api.post('/personal/tournaments', payload, token);
    return (response['tournament_id'] as num).toInt();
  }

  Future<List<AdminTournamentSummary>> getPersonalTournaments() async {
    final token = await _storage.getToken();
    final response = await _api.get('/personal/tournaments', token);
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

  /// Дублировать турнир: создаётся копия-черновик с теми же настройками,
  /// но без участников. Возвращает детали нового турнира.
  Future<AdminTournamentDetail> duplicateTournament(int id) async {
    final token = await _storage.getToken();
    final response =
        await _api.post('/admin/tournaments/$id/duplicate', {}, token);
    return AdminTournamentDetail.fromJson(
      response['tournament'] as Map<String, dynamic>,
    );
  }

  // ===== Ручной сбор пар (групповой турнир, pairing_mode=admin) =====

  Future<Map<String, dynamic>> getPairing(int tournamentId) async {
    final token = await _storage.getToken();
    final resp =
        await _api.get('/admin/tournaments/$tournamentId/pairing', token);
    return (resp['pairing'] as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> createPair(
      int tournamentId, int player1Id, int player2Id) async {
    final token = await _storage.getToken();
    final resp = await _api.post(
      '/admin/tournaments/$tournamentId/pairing/teams',
      {'player1_id': player1Id, 'player2_id': player2Id},
      token,
    );
    return (resp['pairing'] as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> deletePair(int tournamentId, int teamId) async {
    final token = await _storage.getToken();
    final resp = await _api.delete(
      '/admin/tournaments/$tournamentId/pairing/teams/$teamId',
      null,
      token,
    );
    return (resp['pairing'] as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> autoPair(int tournamentId) async {
    final token = await _storage.getToken();
    final resp = await _api.post(
      '/admin/tournaments/$tournamentId/pairing/auto',
      {},
      token,
    );
    return (resp['pairing'] as Map).cast<String, dynamic>();
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
    bool? verifiedOnly,
    int? moderationHours,
    int? moderationMinutes,
    String? status,
    String? pairingMode,
    bool? hasPlayoff,
    bool? hasLowerBracket,
    bool? hasBronzeMatch,
    int? courtsCount,
    // Доп. поля (как при создании) — до старта менять безопасно.
    int? durationHours,
    bool? isRated,
    int? reserveCount,
    int? waitlistSize,
    int? groupsCount,
    int? roundsCount,
    int? teamsAdvance,
    String? playoffType,
    String? playoffFormat,
    bool? isPaired,
    List<String?>? courts,
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
      if (verifiedOnly != null) 'verified_only': verifiedOnly,
      // Таймер модерации (часы/минуты). Меняет только будущие заявки —
      // у уже поданных дедлайн зафиксирован при подаче.
      'moderation_hours': moderationHours,
      'moderation_minutes': moderationMinutes,
      // Перевод черновик ⇄ открыта регистрация.
      if (status != null) 'status': status,
      // Кто собирает пары (командный турнир): self / admin.
      if (pairingMode != null) 'pairing_mode': pairingMode,
      // Плей-офф (шлём только когда переданы).
      if (hasPlayoff != null) 'has_playoff': hasPlayoff,
      if (hasLowerBracket != null) 'has_lower_bracket': hasLowerBracket,
      if (hasBronzeMatch != null) 'has_bronze_match': hasBronzeMatch,
      if (courtsCount != null) 'courts_count': courtsCount,
      // Доп. поля формата/записей (шлём только когда переданы).
      if (durationHours != null) 'duration_hours': durationHours,
      if (isRated != null) 'is_rated': isRated,
      if (reserveCount != null) 'reserve_count': reserveCount,
      if (waitlistSize != null) 'waitlist_size': waitlistSize,
      if (groupsCount != null) 'groups_count': groupsCount,
      if (roundsCount != null) 'rounds_count': roundsCount,
      if (teamsAdvance != null) 'teams_advance': teamsAdvance,
      if (playoffType != null) 'playoff_type': playoffType,
      if (playoffFormat != null) 'playoff_format': playoffFormat,
      if (isPaired != null) 'is_paired': isPaired,
      if (courts != null) 'courts': courts,
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

  /// Старт JPI solo с ручным посевом: order — id игроков в порядке слотов
  /// (корт1 слот1..4, корт2 слот1..4, ...).
  Future<AdminTournamentDetail> startTournamentWithOrder(
    int id,
    List<int> order,
  ) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$id/start',
      {'order': order},
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

  /// Остановить (отменить) турнир — статус меняется на «cancelled».
  Future<AdminTournamentDetail> cancelTournament(int id) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$id/cancel',
      const {},
      token,
    );
    return AdminTournamentDetail.fromJson(
      response['tournament'] as Map<String, dynamic>,
    );
  }

  /// Отправить push-уведомление о турнире всем подходящим пользователям
  /// (как колокольчик в веб-админке). Возвращает текст результата.
  Future<String> sendTournamentPush(int id) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$id/send-push',
      const {},
      token,
    );
    return response['message'] as String? ?? 'Уведомление отправлено';
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

  /// Журнал записей турнира: {registered: [...], unregistered: [...]}
  /// с временем события. Возвращаем как список (entry = игрок + время).
  Future<Map<String, List<RegistrationLogEntry>>> getRegistrationJournal(
      int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.get(
      '/admin/tournaments/$tournamentId/registration-journal',
      token,
    );
    List<RegistrationLogEntry> parse(String key) {
      final list = (response[key] as List?) ?? const [];
      return list
          .map((e) =>
              RegistrationLogEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return {
      'registered': parse('registered'),
      'unregistered': parse('unregistered'),
    };
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

  /// Переместить участника в лист ожидания. Если [promoteUserId] задан —
  /// этот игрок из листа ожидания займёт освободившееся место (на модерацию).
  Future<void> moveToWaitlist(int tournamentId, int userId,
      {int? promoteUserId}) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/participants/$userId/to-waitlist',
      {if (promoteUserId != null) 'promote_user_id': promoteUserId},
      token,
    );
  }

  /// Поднять игрока из листа ожидания на модерацию. Если турнир полный —
  /// [demoteUserId] (кого отправить в лист ожидания вместо него) обязателен.
  Future<void> moveToModeration(int tournamentId, int userId,
      {int? demoteUserId}) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/participants/$userId/to-moderation',
      {if (demoteUserId != null) 'demote_user_id': demoteUserId},
      token,
    );
  }

  /// Универсальное перемещение участника между статусами:
  /// 'registered' (основной список) / 'pending' (модерация) / 'waiting' (лист ожидания).
  Future<void> moveParticipant(int tournamentId, int userId, String to) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/participants/$userId/move',
      {'to': to},
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

  Future<void> invitePlayer(int tournamentId, int userId) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/invite',
      {'user_id': userId},
      token,
    );
  }

  Future<List<AdminInvitation>> getTournamentInvitations(int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.get(
      '/admin/tournaments/$tournamentId/invitations',
      token,
    );
    final list = (response['invitations'] as List?) ?? const [];
    return list
        .map((j) => AdminInvitation.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> cancelInvitation(int tournamentId, int invitationId) async {
    final token = await _storage.getToken();
    await _api.delete(
      '/admin/tournaments/$tournamentId/invitations/$invitationId',
      null,
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

  // === Мексикано ===

  Future<void> saveMexicanoScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
    required bool isUpdate,
  }) async {
    final token = await _storage.getToken();
    final endpoint =
        '/admin/tournaments/$tournamentId/mexicano/matches/$matchId/score';
    final body = {'team1_score': team1Score, 'team2_score': team2Score};
    if (isUpdate) {
      await _api.put(endpoint, body, token);
    } else {
      await _api.post(endpoint, body, token);
    }
  }

  Future<void> saveMexicanoPlayoffScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
  }) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/mexicano/playoff/$matchId/score',
      {'team1_score': team1Score, 'team2_score': team2Score},
      token,
    );
  }

  /// Досрочно завершить Мексикано / перейти в плей-офф. Возвращает свежий /matches.
  Future<AdminMatchesResponse> mexicanoFinishEarly(int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$tournamentId/mexicano/finish-early',
      const {},
      token,
    );
    return AdminMatchesResponse.fromJson(response);
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

  /// Сохранить счёт короткого матча «Эскалеры». POST и PUT одинаковы —
  /// у формата сохранение и правка это одна операция.
  Future<void> saveEscaleraScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
  }) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/escalera/matches/$matchId/score',
      {
        'team1_score': team1Score,
        'team2_score': team2Score,
      },
      token,
    );
  }

  /// Сохранить счёт матча Round Robin. POST/PUT одинаковы — RoundRobinService
  /// сам откатит старые статы если матч уже completed.
  Future<void> saveRoundRobinScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
  }) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/round_robin/matches/$matchId/score',
      {
        'team1_score': team1Score,
        'team2_score': team2Score,
      },
      token,
    );
  }

  /// Сохранить счёт матча Americano Flex. POST/PUT одинаковы — service
  /// идемпотентно переписывает счёт.
  Future<void> saveAmericanoFlexScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
  }) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/americano_flex/matches/$matchId/score',
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

  /// Получить участников + уже созданные пары для фикс-парного Короля корта.
  Future<Map<String, dynamic>> getKocPairs(int tournamentId) async {
    final token = await _storage.getToken();
    final response = await _api.get(
      '/admin/tournaments/$tournamentId/kingofcourt/pairs',
      token,
    );
    return response;
  }

  /// Сохранить пары Короля корта. pairs — массив [[player1_id, player2_id], ...].
  Future<void> saveKocPairs(
    int tournamentId,
    List<List<int>> pairs,
  ) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/kingofcourt/pairs',
      {'pairs': pairs},
      token,
    );
  }

  /// Сохранить счёт матча Just Padel It. POST/PUT одинаковы — сервис
  /// идемпотентно переписывает счёт и статы.
  Future<void> saveJpiScore(
    int tournamentId,
    int matchId, {
    required int team1Score,
    required int team2Score,
  }) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/justpadelit/matches/$matchId/score',
      {'team1_score': team1Score, 'team2_score': team2Score},
      token,
    );
  }

  /// Участники + уже созданные пары JPI.
  Future<Map<String, dynamic>> getJpiPairs(int tournamentId) async {
    final token = await _storage.getToken();
    return _api.get('/admin/tournaments/$tournamentId/justpadelit/pairs', token);
  }

  /// Сохранить пары JPI. pairs — [[player1_id, player2_id], ...].
  Future<void> saveJpiPairs(int tournamentId, List<List<int>> pairs) async {
    final token = await _storage.getToken();
    await _api.post(
      '/admin/tournaments/$tournamentId/justpadelit/pairs',
      {'pairs': pairs},
      token,
    );
  }

  /// Авто-посев (по рейтингу) + число кортов для экрана посева solo JPI.
  Future<Map<String, dynamic>> getJpiSeeding(int tournamentId) async {
    final token = await _storage.getToken();
    return _api.get('/admin/tournaments/$tournamentId/justpadelit/seeding', token);
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
