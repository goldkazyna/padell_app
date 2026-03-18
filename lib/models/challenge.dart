import 'package:flutter/material.dart';

class ChallengeSet {
  final int teamA;
  final int teamB;

  ChallengeSet({required this.teamA, required this.teamB});

  factory ChallengeSet.fromJson(Map<String, dynamic> json) {
    return ChallengeSet(
      teamA: json['team_a'] as int? ?? 0,
      teamB: json['team_b'] as int? ?? 0,
    );
  }
}

class ChallengePlayer {
  final int id;
  final int position;
  final String status;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? avatar;
  final int rating;
  final double level;
  final int? ratingBefore;
  final int? ratingAfter;
  final int? ratingChange;
  final bool isMe;

  ChallengePlayer({
    required this.id,
    required this.position,
    required this.status,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.avatar,
    required this.rating,
    required this.level,
    this.ratingBefore,
    this.ratingAfter,
    this.ratingChange,
    this.isMe = false,
  });

  factory ChallengePlayer.fromJson(Map<String, dynamic> json) {
    double parsedLevel = 0.0;
    final rawLevel = json['level'];
    if (rawLevel is num) {
      parsedLevel = rawLevel.toDouble();
    } else if (rawLevel is String) {
      parsedLevel = double.tryParse(rawLevel) ?? 0.0;
    }

    return ChallengePlayer(
      id: json['id'] as int? ?? 0,
      position: json['position'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      level: parsedLevel,
      ratingBefore: json['rating_before'] as int?,
      ratingAfter: json['rating_after'] as int?,
      ratingChange: json['rating_change'] as int?,
      isMe: json['is_me'] as bool? ?? false,
    );
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  String get levelCategory {
    if (level < 2.0) return 'L1';
    if (level < 3.0) return 'L2';
    if (level < 4.0) return 'L3';
    return 'L4';
  }

  String get levelText {
    final levelStr = level == level.truncateToDouble()
        ? '${level.toInt()}.0'
        : level.toString();
    return '$levelCategory · $levelStr';
  }

  bool get isConfirmed => status == 'confirmed';
  bool get isPending => status == 'pending';
  bool get isInvited => status == 'invited';
}

class ChallengeClub {
  final int id;
  final String name;

  ChallengeClub({required this.id, required this.name});

  factory ChallengeClub.fromJson(Map<String, dynamic> json) {
    return ChallengeClub(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class Challenge {
  final int id;
  final int creatorId;
  final bool isCreator;
  final ChallengeClub? club;
  final DateTime scheduledAt;
  final String type;
  final String typeName;
  final double minLevel;
  final double maxLevel;
  final String status;
  final String statusName;
  final List<ChallengeSet>? score;
  final List<ChallengePlayer> players;
  final int confirmedCount;
  final List<int> availablePositions;
  final bool isParticipant;
  final String? myStatus;
  final int? myPosition;
  final int? myRatingChange;

  Challenge({
    required this.id,
    required this.creatorId,
    required this.isCreator,
    this.club,
    required this.scheduledAt,
    required this.type,
    required this.typeName,
    required this.minLevel,
    required this.maxLevel,
    required this.status,
    required this.statusName,
    this.score,
    this.players = const [],
    this.confirmedCount = 0,
    this.availablePositions = const [],
    this.isParticipant = false,
    this.myStatus,
    this.myPosition,
    this.myRatingChange,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    List<ChallengePlayer> parsedPlayers = [];
    try {
      final playersList = json['players'] as List<dynamic>?;
      if (playersList != null) {
        parsedPlayers = playersList
            .map((p) => ChallengePlayer.fromJson(p as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Если парсинг игроков сломался — просто пустой список
    }

    List<ChallengeSet>? parsedScore;
    try {
      final scoreList = json['score'] as List<dynamic>?;
      if (scoreList != null) {
        parsedScore = scoreList
            .map((s) => ChallengeSet.fromJson(s as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Если парсинг счёта сломался — null
    }

    List<int> parsedPositions = [];
    try {
      final positionsList = json['available_positions'] as List<dynamic>?;
      if (positionsList != null) {
        parsedPositions = positionsList.map((p) => p as int).toList();
      }
    } catch (_) {
      // Если парсинг позиций сломался — пустой список
    }

    return Challenge(
      id: json['id'] as int,
      creatorId: json['creator_id'] as int? ?? 0,
      isCreator: json['is_creator'] as bool? ?? false,
      club: json['club'] != null
          ? ChallengeClub.fromJson(json['club'] as Map<String, dynamic>)
          : null,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      type: json['type'] as String,
      typeName: json['type_name'] as String? ?? '',
      minLevel: (json['min_level'] as num?)?.toDouble() ?? 0.0,
      maxLevel: (json['max_level'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      statusName: json['status_name'] as String? ?? '',
      score: parsedScore,
      players: parsedPlayers,
      confirmedCount: json['confirmed_count'] as int? ?? 0,
      availablePositions: parsedPositions,
      isParticipant: json['is_participant'] as bool? ?? false,
      myStatus: json['my_status'] as String?,
      myPosition: json['my_position'] as int?,
      myRatingChange: json['my_rating_change'] as int?,
    );
  }

  // === Computed getters ===

  bool get isRated => type == 'rated';
  bool get isFriendly => type == 'friendly';
  bool get isOpen => status == 'open';
  bool get isReady => status == 'ready';
  bool get isCompleted => status == 'completed';
  bool get isFull => availablePositions.isEmpty;

  List<ChallengePlayer> get teamAPlayers =>
      players.where((p) => p.position <= 2).toList();

  List<ChallengePlayer> get teamBPlayers =>
      players.where((p) => p.position > 2).toList();

  Color get typeColor {
    switch (type) {
      case 'rated':
        return const Color(0xFF22C55E);
      case 'friendly':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String get levelText => '${minLevel.toString()} – ${maxLevel.toString()}';

  String get dateFormatted {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    return '${scheduledAt.day} ${months[scheduledAt.month - 1]}';
  }

  String get timeFormatted {
    final hour = scheduledAt.hour.toString().padLeft(2, '0');
    final minute = scheduledAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get dayOfWeek {
    const days = [
      'Понедельник', 'Вторник', 'Среда', 'Четверг',
      'Пятница', 'Суббота', 'Воскресенье',
    ];
    return days[scheduledAt.weekday - 1];
  }
}
