import 'api_service.dart';
import 'storage_service.dart';

class RatingPlayer {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String? avatar;
  final int rating;
  final double level;
  final int position;
  final bool isMe;

  RatingPlayer({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.rating,
    required this.level,
    required this.position,
    this.isMe = false,
  });

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
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
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      level: level,
      position: json['position'] as int? ?? 0,
      isMe: json['is_me'] as bool? ?? false,
    );
  }
}

class MyRatingCard {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String? avatar;
  final int rating;
  final double level;
  final String levelName;
  final int place;
  final int? filteredPlace;
  final int totalPlayers;

  MyRatingCard({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.rating,
    required this.level,
    required this.levelName,
    required this.place,
    this.filteredPlace,
    required this.totalPlayers,
  });

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
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
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      level: level,
      levelName: json['level_name'] as String? ?? '',
      place: json['place'] as int? ?? 0,
      filteredPlace: json['filtered_place'] as int?,
      totalPlayers: json['total_players'] as int? ?? 0,
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
}
