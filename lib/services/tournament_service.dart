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

  Future<List<Tournament>> getArchiveTournaments(String token, {String? dateFrom, String? dateTo, int? clubId}) async {
    final params = <String>[];
    if (dateFrom != null) params.add('date_from=$dateFrom');
    if (dateTo != null) params.add('date_to=$dateTo');
    if (clubId != null) params.add('club_id=$clubId');
    final qs = params.isEmpty ? '' : '?${params.join('&')}';
    final response = await _api.get('/tournaments/completed$qs', token);
    final list = response['tournaments'] as List<dynamic>;
    return list
        .map((json) => Tournament.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Tournament>> getCancelledTournaments(String token) async {
    final response = await _api.get('/tournaments/cancelled', token);
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

  /// Записаться на одиночный турнир.
  /// [friendUserId] — опциональный id друга.
  /// [confirmWaitlist] — true чтобы согласиться встать в лист ожидания,
  /// если основной состав полный.
  Future<RegisterResult> register(int tournamentId, String token,
      {int? friendUserId, bool confirmWaitlist = false}) async {
    final body = <String, dynamic>{
      if (friendUserId != null) 'friend_user_id': friendUserId,
      if (confirmWaitlist) 'confirm_waitlist': true,
    };
    final response = await _api.post(
      '/tournaments/$tournamentId/register',
      body,
      token,
    );
    return RegisterResult.fromJson(response);
  }

  Future<String> cancel(int tournamentId, String token) async {
    final response = await _api.post('/tournaments/$tournamentId/cancel', {}, token);
    return response['message'] as String;
  }

  // === Оплата участия ===

  /// Создать оплату участия: бэкенд отдаёт ссылку на checkout Plexy.
  /// [friendUserId] — платим сразу за двоих.
  Future<TournamentPaymentStart> startPayment(int tournamentId, String token,
      {int? friendUserId}) async {
    final response = await _api.post(
      '/tournaments/$tournamentId/pay',
      {if (friendUserId != null) 'friend_user_id': friendUserId},
      token,
    );
    return TournamentPaymentStart.fromJson(response);
  }

  /// Оплачено ли: спрашиваем свой бэк, а тот — шлюз. Ждать вебхук нельзя,
  /// человек стоит перед экраном.
  Future<bool> isPaymentPaid(int tournamentId, int paymentId, String token) async {
    final response = await _api.get(
      '/tournaments/$tournamentId/payment-status?payment_id=$paymentId',
      token,
    );
    return response['paid'] == true;
  }

  // === Team registration ===

  Future<List<PartnerSearchResult>> searchPartner(int tournamentId, String query, String token) async {
    developer.log('searchPartner: tournamentId=$tournamentId, query=$query', name: 'TournamentService');
    final response = await _api.post(
      '/tournaments/$tournamentId/search-partner',
      {'query': query},
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

  Future<RegisterResult> registerTeam(int tournamentId, int partnerId, String token,
      {bool confirmWaitlist = false}) async {
    final response = await _api.post(
      '/tournaments/$tournamentId/register-team',
      {
        'partner_id': partnerId,
        if (confirmWaitlist) 'confirm_waitlist': true,
      },
      token,
    );
    return RegisterResult.fromJson(response);
  }

  Future<String> cancelTeam(int tournamentId, String token) async {
    final response = await _api.post('/tournaments/$tournamentId/cancel-team', {}, token);
    return response['message'] as String;
  }

  // === Subscribe to slot availability ===

  Future<String> subscribe(int tournamentId, String token) async {
    final response = await _api.post('/tournaments/$tournamentId/subscribe', {}, token);
    return response['message'] as String;
  }

  Future<String> unsubscribe(int tournamentId, String token) async {
    final response = await _api.post('/tournaments/$tournamentId/unsubscribe', {}, token);
    return response['message'] as String;
  }
}

/// Ответ на «начать оплату»: ссылка на checkout и id платежа для опроса.
class TournamentPaymentStart {
  final bool success;
  final String message;
  final int? paymentId;
  final String? paymentUrl;
  final double amount;
  final int playersCount;

  const TournamentPaymentStart({
    required this.success,
    this.message = '',
    this.paymentId,
    this.paymentUrl,
    this.amount = 0,
    this.playersCount = 1,
  });

  factory TournamentPaymentStart.fromJson(Map<String, dynamic> json) =>
      TournamentPaymentStart(
        success: json['success'] == true,
        message: (json['message'] as String?) ?? '',
        paymentId: json['payment_id'] is int ? json['payment_id'] as int : null,
        paymentUrl: json['payment_url'] as String?,
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        playersCount: json['players_count'] is int ? json['players_count'] as int : 1,
      );
}

class RegisterResult {
  final bool success;
  final bool requiresWaitlistConfirmation;
  final String message;
  final String? registrationStatus;
  final int? waitlistPosition;
  final int? waitlistSize;

  const RegisterResult({
    required this.success,
    required this.requiresWaitlistConfirmation,
    required this.message,
    this.registrationStatus,
    this.waitlistPosition,
    this.waitlistSize,
  });

  bool get isWaitlisted => registrationStatus == 'waiting';

  factory RegisterResult.fromJson(Map<String, dynamic> json) => RegisterResult(
        success: json['success'] == true,
        requiresWaitlistConfirmation:
            json['requires_waitlist_confirmation'] == true,
        message: (json['message'] as String?) ?? '',
        registrationStatus: json['registration_status'] as String?,
        waitlistPosition: json['waitlist_position'] is int
            ? json['waitlist_position'] as int
            : null,
        waitlistSize:
            json['waitlist_size'] is int ? json['waitlist_size'] as int : null,
      );
}
