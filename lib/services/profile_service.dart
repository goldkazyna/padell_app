import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/match.dart';
import '../models/tournament.dart';
import 'api_service.dart';
import 'storage_service.dart';

class RatingTrendPoint {
  final int? tournamentId;
  final String name;
  final String? clubName;
  final String? date;
  final int rating;
  final int? delta;
  final bool isManual;

  const RatingTrendPoint({
    this.tournamentId,
    required this.name,
    this.clubName,
    this.date,
    required this.rating,
    this.delta,
    this.isManual = false,
  });

  factory RatingTrendPoint.fromJson(Map<String, dynamic> json) {
    return RatingTrendPoint(
      tournamentId: (json['tournament_id'] as num?)?.toInt(),
      name: json['name'] as String? ?? 'Турнир',
      clubName: json['club_name'] as String?,
      date: json['date'] as String?,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      delta: (json['delta'] as num?)?.toInt(),
      isManual: json['is_manual'] as bool? ?? (json['tournament_id'] == null),
    );
  }
}

class ProfileStatistics {
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int winrate;
  final int tournamentsCount;
  final List<int> ratingTrend;
  final List<RatingTrendPoint> ratingTrendDetails;

  const ProfileStatistics({
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.winrate,
    required this.tournamentsCount,
    this.ratingTrend = const [],
    this.ratingTrendDetails = const [],
  });

  factory ProfileStatistics.fromJson(Map<String, dynamic> json) {
    final trendRaw = (json['rating_trend'] as List?) ?? const <dynamic>[];
    final detailsRaw =
        (json['rating_trend_details'] as List?) ?? const <dynamic>[];

    final List<int> trend = [];
    for (final e in trendRaw) {
      if (e is num) trend.add(e.toInt());
    }

    final List<RatingTrendPoint> details = [];
    for (final raw in detailsRaw) {
      if (raw is Map<String, dynamic>) {
        try {
          details.add(RatingTrendPoint.fromJson(raw));
        } catch (_) {
          // плохая запись — пропускаем, не валим весь профиль
        }
      }
    }

    return ProfileStatistics(
      matchesPlayed: json['matches_played'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      winrate: json['winrate'] as int? ?? 0,
      tournamentsCount: json['tournaments_count'] as int? ?? 0,
      ratingTrend: trend,
      ratingTrendDetails: details,
    );
  }
}

class ProfileData {
  final User user;
  final ProfileStatistics statistics;

  ProfileData({required this.user, required this.statistics});
}

class ProfileResult {
  final bool success;
  final String? message;
  final ProfileData? data;

  ProfileResult({required this.success, this.message, this.data});
}

/// Партнёр по матчам: с кем и с каким результатом играли вместе.
class PartnerStat {
  final int userId;
  final String name;
  final String? avatar;
  final int games;
  final int wins;
  final int losses;
  final int draws;
  final int winrate;

  const PartnerStat({
    required this.userId,
    required this.name,
    required this.games,
    required this.wins,
    this.avatar,
    this.losses = 0,
    this.draws = 0,
    this.winrate = 0,
  });

  factory PartnerStat.fromJson(Map<String, dynamic> json) => PartnerStat(
        userId: (json['user_id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? 'Игрок',
        avatar: json['avatar'] as String?,
        games: (json['games'] as num?)?.toInt() ?? 0,
        wins: (json['wins'] as num?)?.toInt() ?? 0,
        losses: (json['losses'] as num?)?.toInt() ?? 0,
        draws: (json['draws'] as num?)?.toInt() ?? 0,
        winrate: (json['winrate'] as num?)?.toInt() ?? 0,
      );
}

/// Ответ ручки «с кем играю».
class PlayerPartners {
  final PartnerStat? best;
  final List<PartnerStat> top;
  final int partnersCount;

  const PlayerPartners({this.best, this.top = const [], this.partnersCount = 0});

  factory PlayerPartners.fromJson(Map<String, dynamic> json) => PlayerPartners(
        best: json['best'] is Map<String, dynamic>
            ? PartnerStat.fromJson(json['best'] as Map<String, dynamic>)
            : null,
        top: ((json['top'] as List<dynamic>?) ?? const [])
            .map((p) => PartnerStat.fromJson(p as Map<String, dynamic>))
            .toList(),
        partnersCount: (json['partners_count'] as num?)?.toInt() ?? 0,
      );
}

class ProfileService {
  final ApiService _api;
  final StorageService _storage;

  ProfileService(this._api, this._storage);

  Future<ProfileResult> getProfile() async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        return ProfileResult(success: false, message: 'Не авторизован');
      }

      final response = await _api.get('/profile', token);

      if (response['success'] != true) {
        return ProfileResult(
          success: false,
          message: response['message'] as String? ?? 'Ошибка загрузки',
        );
      }

      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      final statsData = response['statistics'] as Map<String, dynamic>? ?? {};
      final statistics = ProfileStatistics.fromJson(statsData);

      return ProfileResult(
        success: true,
        data: ProfileData(user: user, statistics: statistics),
      );
    } on ApiException catch (e) {
      return ProfileResult(success: false, message: e.message);
    } catch (e) {
      return ProfileResult(success: false, message: 'Ошибка загрузки профиля');
    }
  }

  /// С кем игрок играет: лучший партнёр и топ остальных.
  ///
  /// Отдельным запросом, а не внутри профиля: на сервере расчёт поднимает
  /// всю историю матчей, и профиль из-за него открывался бы дольше.
  Future<PlayerPartners?> getPartners() async {
    final token = await _storage.getToken();
    if (token == null) return null;

    final response = await _api.get('/profile/partners', token);
    if (response['success'] != true) return null;

    return PlayerPartners.fromJson(response);
  }

  Future<List<Tournament>> getTournamentHistory() async {
    try {
      final token = await _storage.getToken();
      if (token == null) return [];

      final response = await _api.get('/tournaments/archive', token);
      final list = response['tournaments'] as List<dynamic>? ?? [];
      for (final t in list) {
        final m = t as Map<String, dynamic>;
        debugPrint('=== ARCHIVE TOURNAMENT: ${m['name']} ===');
        debugPrint('my_result: ${m['my_result']}');
      }
      return list
          .map((t) => Tournament.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getTournamentHistory error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getTournamentResults(int tournamentId, {int? playerId}) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return null;

      var endpoint = '/tournaments/$tournamentId/results';
      if (playerId != null) endpoint += '?player_id=$playerId';
      final response = await _api.get(endpoint, token);
      debugPrint('=== TOURNAMENT RESULTS RAW ===');
      debugPrint('summary: ${response['summary']}');
      debugPrint('matches count: ${(response['matches'] as List?)?.length}');
      debugPrint('tournament: ${response['tournament']}');
      debugPrint('=== END ===');
      if (response['success'] != true) return null;
      return response;
    } catch (e) {
      debugPrint('getTournamentResults error: $e');
      return null;
    }
  }

  /// AI-разбор выступления в турнире. Возвращает объект `analysis`
  /// (headline/summary/factors/best_match/worst_match/tips). Бросает
  /// ApiException с сообщением бэкенда при недоступности/ошибке.
  Future<Map<String, dynamic>> getTournamentAiAnalysis(
    int tournamentId, {
    int? playerId,
    String lang = 'ru',
  }) async {
    final token = await _storage.getToken();
    if (token == null) {
      throw ApiException('Не авторизован');
    }
    var endpoint = '/tournaments/$tournamentId/ai-analysis?lang=$lang';
    if (playerId != null) endpoint += '&player_id=$playerId';
    debugPrint('AI analysis request: $endpoint');
    final response = await _api.get(endpoint, token).timeout(
      const Duration(seconds: 120),
      onTimeout: () => throw ApiException(
          'Разбор не пришёл вовремя. Попробуйте ещё раз.'),
    );
    debugPrint('AI analysis response success=${response['success']}');
    if (response['success'] != true) {
      throw ApiException(
          (response['message'] as String?) ?? 'Не удалось получить разбор');
    }
    // Полный ответ: analysis (AI) + matches (поматчевая разбивка).
    return response;
  }

  Future<MatchHistoryResult> getMatchHistory({int page = 1}) async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        return MatchHistoryResult(success: false, message: 'Не авторизован');
      }

      final response = await _api.get(
        '/matches/history?page=$page&per_page=20',
        token,
      );

      if (response['success'] != true) {
        return MatchHistoryResult(
          success: false,
          message: response['message'] as String? ?? 'Ошибка загрузки',
        );
      }

      final matchesList = response['matches'] as List<dynamic>? ?? [];
      final matches = matchesList
          .map((m) => Match.fromJson(m as Map<String, dynamic>))
          .toList();

      final pagination = response['pagination'] as Map<String, dynamic>? ?? {};
      final lastPage = pagination['last_page'] as int? ?? 1;

      return MatchHistoryResult(
        success: true,
        matches: matches,
        currentPage: page,
        lastPage: lastPage,
      );
    } on ApiException catch (e) {
      return MatchHistoryResult(success: false, message: e.message);
    } catch (e) {
      return MatchHistoryResult(
        success: false,
        message: 'Ошибка загрузки истории матчей',
      );
    }
  }
}

class MatchHistoryResult {
  final bool success;
  final String? message;
  final List<Match> matches;
  final int currentPage;
  final int lastPage;

  MatchHistoryResult({
    required this.success,
    this.message,
    this.matches = const [],
    this.currentPage = 1,
    this.lastPage = 1,
  });
}
