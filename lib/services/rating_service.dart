import 'api_service.dart';
import 'storage_service.dart';

class RatingPlayer {
  final int id;
  final String name;
  final String? avatar;
  final int rating;
  final double level;
  final int position;
  final bool isMe;
  final bool levelVerified;

  RatingPlayer({
    required this.id,
    required this.name,
    this.avatar,
    required this.rating,
    required this.level,
    required this.position,
    this.isMe = false,
    this.levelVerified = false,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory RatingPlayer.fromJson(Map<String, dynamic> json) {
    final levelValue = json['level'];
    double level = 0;
    if (levelValue is num) {
      level = levelValue.toDouble();
    } else if (levelValue is String) {
      level = double.tryParse(levelValue) ?? 0;
    }

    return RatingPlayer(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      level: level,
      position: json['position'] as int? ?? 0,
      isMe: json['is_me'] as bool? ?? false,
      levelVerified: json['level_verified'] as bool? ?? false,
    );
  }
}

class MyRatingCard {
  final int id;
  final String name;
  final String? avatar;
  final int rating;
  final double level;
  final String levelName;
  final int place;
  final int? filteredPlace;
  final int totalPlayers;
  final bool levelVerified;

  MyRatingCard({
    required this.id,
    required this.name,
    this.avatar,
    required this.rating,
    required this.level,
    required this.levelName,
    required this.place,
    this.filteredPlace,
    required this.totalPlayers,
    this.levelVerified = false,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory MyRatingCard.fromJson(Map<String, dynamic> json) {
    final levelValue = json['level'];
    double level = 0;
    if (levelValue is num) {
      level = levelValue.toDouble();
    } else if (levelValue is String) {
      level = double.tryParse(levelValue) ?? 0;
    }

    return MyRatingCard(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      level: level,
      levelName: json['level_name'] as String? ?? '',
      place: json['place'] as int? ?? 0,
      filteredPlace: json['filtered_place'] as int?,
      totalPlayers: json['total_players'] as int? ?? 0,
      levelVerified: json['level_verified'] as bool? ?? false,
    );
  }
}

class RatingData {
  final MyRatingCard myCard;
  final List<RatingPlayer> players;
  final List<RatingPlayer> neighbors;
  final int page;
  final int totalPages;
  final int total;
  final String levelFilter;
  final String? search;

  RatingData({
    required this.myCard,
    required this.players,
    required this.neighbors,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.levelFilter,
    this.search,
  });
}

class RatingResult {
  final bool success;
  final String? message;
  final RatingData? data;

  RatingResult({required this.success, this.message, this.data});
}

class RatingService {
  final ApiService _api;
  final StorageService _storage;

  RatingService(this._api, this._storage);

  Future<RatingResult> getRating({
    String level = 'all',
    String? search,
    int page = 1,
  }) async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        return RatingResult(success: false, message: 'Не авторизован');
      }

      var endpoint = '/rating?level=$level&page=$page';
      if (search != null && search.isNotEmpty) {
        endpoint += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await _api.get(endpoint, token);

      if (response['success'] != true) {
        return RatingResult(
          success: false,
          message: response['message'] as String? ?? 'Ошибка загрузки',
        );
      }

      final myCardData = response['my_card'] as Map<String, dynamic>;
      final myCard = MyRatingCard.fromJson(myCardData);

      final playersList = response['players'] as List<dynamic>? ?? [];
      final players = playersList
          .map((p) => RatingPlayer.fromJson(p as Map<String, dynamic>))
          .toList();

      final neighborsList = response['neighbors'] as List<dynamic>? ?? [];
      final neighbors = neighborsList
          .map((p) => RatingPlayer.fromJson(p as Map<String, dynamic>))
          .toList();

      final filters = response['filters'] as Map<String, dynamic>? ?? {};

      return RatingResult(
        success: true,
        data: RatingData(
          myCard: myCard,
          players: players,
          neighbors: neighbors,
          page: response['page'] as int? ?? 1,
          totalPages: response['total_pages'] as int? ?? 1,
          total: response['total'] as int? ?? 0,
          levelFilter: filters['level'] as String? ?? 'all',
          search: filters['search'] as String?,
        ),
      );
    } on ApiException catch (e) {
      return RatingResult(success: false, message: e.message);
    } catch (e) {
      return RatingResult(success: false, message: 'Ошибка загрузки рейтинга');
    }
  }

  /// Лёгкий запрос для модалки «Кто верифицировал».
  /// Возвращает [VerificationInfo] с флагом verified и историей записей.
  Future<VerificationInfo?> getVerification(int userId) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return null;

      final response =
          await _api.get('/rating/player/$userId/verification', token);
      if (response['success'] != true) return null;

      final List<dynamic> rawHistory =
          (response['level_verifications'] as List?) ??
              [
                if (response['level_verification'] is Map<String, dynamic>)
                  response['level_verification']
              ];

      final blockers = (response['verification_blockers'] as List?)
              ?.whereType<String>()
              .toList() ??
          const <String>[];

      return VerificationInfo(
        verified: response['level_verified'] as bool? ?? false,
        history: rawHistory
            .whereType<Map<String, dynamic>>()
            .map(LevelVerification.fromJson)
            .toList(),
        blockers: blockers,
      );
    } catch (_) {
      return null;
    }
  }

  Future<PlayerProfile?> getPlayer(int userId) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return null;

      final response = await _api.get('/rating/player/$userId', token);
      if (response['success'] != true) return null;

      final p = response['player'] as Map<String, dynamic>;
      final historyList = response['history'] as List<dynamic>? ?? [];

      final levelValue = p['level'];
      double level = 0;
      if (levelValue is num) level = levelValue.toDouble();
      else if (levelValue is String) level = double.tryParse(levelValue) ?? 0;

      final trendList = p['rating_trend'] as List<dynamic>? ?? [];

      final lvJson = p['level_verification'];
      final levelVerification = lvJson is Map<String, dynamic>
          ? LevelVerification.fromJson(lvJson)
          : null;

      return PlayerProfile(
        id: p['id'] as int,
        name: p['name'] as String? ?? '',
        avatar: p['avatar'] as String?,
        rating: p['rating'] as int? ?? 0,
        level: level,
        place: p['place'] as int? ?? 0,
        matchesPlayed: p['matches_played'] as int? ?? 0,
        wins: p['wins'] as int? ?? 0,
        losses: p['losses'] as int? ?? 0,
        winrate: p['winrate'] as int? ?? 0,
        tournamentsCount: p['tournaments_count'] as int? ?? 0,
        levelVerified: p['level_verified'] as bool? ?? false,
        levelVerification: levelVerification,
        ratingTrend: trendList.map((v) => (v as num).toInt()).toList(),
        history: historyList.map((h) => RatingHistoryItem.fromJson(h as Map<String, dynamic>)).toList(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<TournamentsResult> getTournaments({
    String period = 'month',
    String? search,
    int page = 1,
  }) async {
    try {
      final token = await _storage.getToken();
      if (token == null) return TournamentsResult(success: false, message: 'Не авторизован');

      var endpoint = '/rating/tournaments?period=$period&page=$page';
      if (search != null && search.isNotEmpty) endpoint += '&search=${Uri.encodeComponent(search)}';
      final response = await _api.get(endpoint, token);
      if (response['success'] != true) return TournamentsResult(success: false, message: response['message'] as String? ?? 'Ошибка');

      final playersList = response['players'] as List<dynamic>? ?? [];
      final players = playersList.map((p) {
        final player = RatingPlayer.fromJson(p as Map<String, dynamic>);
        return TournamentsPlayer(
          player: player,
          tournamentsCount: p['tournaments_count'] as int? ?? 0,
          totalChange: p['total_change'] as int? ?? 0,
        );
      }).toList();

      return TournamentsResult(
        success: true,
        players: players,
        myTournaments: response['my_tournaments'] as int? ?? 0,
        myChange: response['my_change'] as int? ?? 0,
        myPlace: response['my_place'] as int? ?? 0,
        period: response['period'] as String? ?? period,
        page: response['page'] as int? ?? 1,
        totalPages: response['total_pages'] as int? ?? 1,
        total: response['total'] as int? ?? 0,
      );
    } on ApiException catch (e) {
      return TournamentsResult(success: false, message: e.message);
    } catch (e) {
      return TournamentsResult(success: false, message: 'Ошибка загрузки');
    }
  }

  Future<GrowthResult> getGrowth({
    String period = 'month',
    String? search,
    int page = 1,
  }) async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        return GrowthResult(success: false, message: 'Не авторизован');
      }

      var endpoint = '/rating/growth?period=$period&page=$page';
      if (search != null && search.isNotEmpty) endpoint += '&search=${Uri.encodeComponent(search)}';
      final response = await _api.get(endpoint, token);

      if (response['success'] != true) {
        return GrowthResult(success: false, message: response['message'] as String? ?? 'Ошибка');
      }

      final playersList = response['players'] as List<dynamic>? ?? [];
      final players = playersList.map((p) {
        final player = RatingPlayer.fromJson(p as Map<String, dynamic>);
        return GrowthPlayer(
          player: player,
          growth: p['growth'] as int? ?? 0,
        );
      }).toList();

      return GrowthResult(
        success: true,
        players: players,
        myGrowth: response['my_growth'] as int? ?? 0,
        myPlace: response['my_place'] as int? ?? 0,
        period: response['period'] as String? ?? period,
        page: response['page'] as int? ?? 1,
        totalPages: response['total_pages'] as int? ?? 1,
        total: response['total'] as int? ?? 0,
      );
    } on ApiException catch (e) {
      return GrowthResult(success: false, message: e.message);
    } catch (e) {
      return GrowthResult(success: false, message: 'Ошибка загрузки');
    }
  }
}

class PlayerProfile {
  final int id;
  final String name;
  final String? avatar;
  final int rating;
  final double level;
  final int place;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final int winrate;
  final int tournamentsCount;
  final bool levelVerified;
  final LevelVerification? levelVerification;
  final List<int> ratingTrend;
  final List<RatingHistoryItem> history;

  PlayerProfile({
    required this.id,
    required this.name,
    this.avatar,
    required this.rating,
    required this.level,
    required this.place,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.winrate,
    required this.tournamentsCount,
    this.levelVerified = false,
    this.levelVerification,
    this.ratingTrend = const [],
    required this.history,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get levelCategory {
    if (level >= 4.0) return '4';
    if (level >= 3.0) return '3';
    if (level >= 2.0) return '2';
    return '1';
  }
}

/// Обёртка для модалки верификации: знает и про флаг verified,
/// и про всю историю записей (если они есть), и про причины почему
/// не верифицирован (если не верифицирован).
class VerificationInfo {
  final bool verified;
  final List<LevelVerification> history;
  final List<String> blockers; // 'no_avatar', 'no_tournaments'

  const VerificationInfo({
    required this.verified,
    required this.history,
    this.blockers = const [],
  });

  LevelVerification? get latest => history.isEmpty ? null : history.first;
}

class LevelVerification {
  final int? verifiedById;
  final String verifiedByName;
  final String? verifiedByAvatar;
  final int? clubId;
  final String? clubName;
  final DateTime? verifiedAt;
  final double? levelSetTo;

  LevelVerification({
    required this.verifiedById,
    required this.verifiedByName,
    required this.verifiedByAvatar,
    required this.clubId,
    required this.clubName,
    required this.verifiedAt,
    required this.levelSetTo,
  });

  factory LevelVerification.fromJson(Map<String, dynamic> json) {
    final by = json['verified_by'] as Map<String, dynamic>?;
    final club = json['club'] as Map<String, dynamic>?;
    return LevelVerification(
      verifiedById: by != null ? (by['id'] as num?)?.toInt() : null,
      verifiedByName: by != null ? (by['name'] as String? ?? '') : '',
      verifiedByAvatar: by != null ? by['avatar_url'] as String? : null,
      clubId: club != null ? (club['id'] as num?)?.toInt() : null,
      clubName: club != null ? club['name'] as String? : null,
      verifiedAt: DateTime.tryParse(json['verified_at'] as String? ?? ''),
      levelSetTo: (json['level_set_to'] as num?)?.toDouble(),
    );
  }
}

class RatingHistoryItem {
  final int? tournamentId;
  final String tournamentName;
  final String? tournamentType;
  final String date;
  final int change;
  final int ratingAfter;
  final int? place;

  RatingHistoryItem({
    this.tournamentId,
    required this.tournamentName,
    this.tournamentType,
    required this.date,
    required this.change,
    required this.ratingAfter,
    this.place,
  });

  factory RatingHistoryItem.fromJson(Map<String, dynamic> json) {
    return RatingHistoryItem(
      tournamentId: json['tournament_id'] as int?,
      tournamentName: json['tournament_name'] as String? ?? 'Турнир',
      tournamentType: json['tournament_type'] as String?,
      date: json['date'] as String? ?? '',
      change: json['change'] as int? ?? 0,
      ratingAfter: json['rating_after'] as int? ?? 0,
      place: json['place'] as int?,
    );
  }
}

class TournamentsPlayer {
  final RatingPlayer player;
  final int tournamentsCount;
  final int totalChange;

  TournamentsPlayer({required this.player, required this.tournamentsCount, required this.totalChange});
}

class TournamentsResult {
  final bool success;
  final String? message;
  final List<TournamentsPlayer> players;
  final int myTournaments;
  final int myChange;
  final int myPlace;
  final String period;
  final int page;
  final int totalPages;
  final int total;

  TournamentsResult({
    required this.success,
    this.message,
    this.players = const [],
    this.myTournaments = 0,
    this.myChange = 0,
    this.myPlace = 0,
    this.period = 'month',
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
  });
}

class GrowthPlayer {
  final RatingPlayer player;
  final int growth;

  GrowthPlayer({required this.player, required this.growth});
}

class GrowthResult {
  final bool success;
  final String? message;
  final List<GrowthPlayer> players;
  final int myGrowth;
  final int myPlace;
  final String period;
  final int page;
  final int totalPages;
  final int total;

  GrowthResult({
    required this.success,
    this.message,
    this.players = const [],
    this.myGrowth = 0,
    this.myPlace = 0,
    this.period = 'month',
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
  });
}
