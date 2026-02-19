import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/match.dart';
import '../models/tournament.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ProfileStatistics {
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int winrate;
  final int tournamentsCount;

  const ProfileStatistics({
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.winrate,
    required this.tournamentsCount,
  });

  factory ProfileStatistics.fromJson(Map<String, dynamic> json) {
    return ProfileStatistics(
      matchesPlayed: json['matches_played'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      winrate: json['winrate'] as int? ?? 0,
      tournamentsCount: json['tournaments_count'] as int? ?? 0,
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

  Future<Map<String, dynamic>?> getTournamentResults(int tournamentId) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return null;

      final response = await _api.get('/tournaments/$tournamentId/results', token);
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
