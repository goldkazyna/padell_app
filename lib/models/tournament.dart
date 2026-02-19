import 'package:flutter/material.dart';

class Club {
  final int id;
  final String name;
  final String? phone;
  final String? address;

  Club({required this.id, required this.name, this.phone, this.address});

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
    );
  }

  String get fullAddress => address != null ? '$name · $address' : name;
}

class TournamentParticipant {
  final int id;
  final String name;
  final double level;
  final int rating;
  final String status;

  TournamentParticipant({
    required this.id,
    required this.name,
    required this.level,
    required this.rating,
    required this.status,
  });

  factory TournamentParticipant.fromJson(Map<String, dynamic> json) {
    // level может приходить как String или num
    double parsedLevel = 0.0;
    final rawLevel = json['level'];
    if (rawLevel is num) {
      parsedLevel = rawLevel.toDouble();
    } else if (rawLevel is String) {
      parsedLevel = double.tryParse(rawLevel) ?? 0.0;
    }

    return TournamentParticipant(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      level: parsedLevel,
      rating: json['rating'] as int? ?? 0,
      status: json['status'] as String? ?? 'registered',
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
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
}

class PartnerSearchResult {
  final int id;
  final String name;
  final double level;
  final int rating;
  final String? phone;

  PartnerSearchResult({
    required this.id,
    required this.name,
    required this.level,
    required this.rating,
    this.phone,
  });

  factory PartnerSearchResult.fromJson(Map<String, dynamic> json) {
    double parsedLevel = 0.0;
    final rawLevel = json['level'];
    if (rawLevel is num) {
      parsedLevel = rawLevel.toDouble();
    } else if (rawLevel is String) {
      parsedLevel = double.tryParse(rawLevel) ?? 0.0;
    }

    return PartnerSearchResult(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      level: parsedLevel,
      rating: json['rating'] as int? ?? 0,
      phone: json['phone'] as String?,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
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
}

class TournamentTeamPlayer {
  final int id;
  final String name;
  final double level;
  final int rating;

  TournamentTeamPlayer({
    required this.id,
    required this.name,
    required this.level,
    required this.rating,
  });

  factory TournamentTeamPlayer.fromJson(Map<String, dynamic> json) {
    double parsedLevel = 0.0;
    final rawLevel = json['level'];
    if (rawLevel is num) {
      parsedLevel = rawLevel.toDouble();
    } else if (rawLevel is String) {
      parsedLevel = double.tryParse(rawLevel) ?? 0.0;
    }

    return TournamentTeamPlayer(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      level: parsedLevel,
      rating: json['rating'] as int? ?? 0,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get levelText {
    final levelStr = level == level.truncateToDouble()
        ? '${level.toInt()}.0'
        : level.toString();
    String cat;
    if (level < 2.0) { cat = 'L1'; }
    else if (level < 3.0) { cat = 'L2'; }
    else if (level < 4.0) { cat = 'L3'; }
    else { cat = 'L4'; }
    return '$cat · $levelStr';
  }
}

class TournamentTeam {
  final int id;
  final TournamentTeamPlayer player1;
  final TournamentTeamPlayer? player2;
  final String status; // pending / approved

  TournamentTeam({
    required this.id,
    required this.player1,
    this.player2,
    required this.status,
  });

  factory TournamentTeam.fromJson(Map<String, dynamic> json) {
    return TournamentTeam(
      id: json['id'] as int? ?? 0,
      player1: TournamentTeamPlayer.fromJson(json['player1'] as Map<String, dynamic>),
      player2: json['player2'] != null
          ? TournamentTeamPlayer.fromJson(json['player2'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String? ?? 'pending',
    );
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
}

class TournamentResult {
  final int ratingChange;
  final int ratingAfter;
  final int place;
  final int points;

  TournamentResult({
    required this.ratingChange,
    required this.ratingAfter,
    required this.place,
    required this.points,
  });

  factory TournamentResult.fromJson(Map<String, dynamic> json) {
    return TournamentResult(
      ratingChange: json['rating_change'] as int? ?? 0,
      ratingAfter: json['rating_after'] as int? ?? 0,
      place: json['place'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
    );
  }
}

class Tournament {
  final int id;
  final String name;
  final String? description;
  final Club club;
  final String date;
  final String time;
  final DateTime datetime;
  final String type;
  final String typeName;
  final String status;
  final String statusName;
  final double minLevel;
  final double maxLevel;
  final double price;
  final int maxParticipants;
  final int participantsCount;
  final int spotsLeft;
  final bool isRegistered;
  final String? registrationStatus;
  final bool canRegister;
  final String? blockReason;
  final TournamentResult? myResult;
  final List<TournamentParticipant> participants;
  final List<TournamentTeam> teams;

  Tournament({
    required this.id,
    required this.name,
    this.description,
    required this.club,
    required this.date,
    required this.time,
    required this.datetime,
    required this.type,
    required this.typeName,
    required this.status,
    required this.statusName,
    required this.minLevel,
    required this.maxLevel,
    required this.price,
    required this.maxParticipants,
    required this.participantsCount,
    this.spotsLeft = 0,
    this.isRegistered = false,
    this.registrationStatus,
    this.canRegister = true,
    this.blockReason,
    this.myResult,
    this.participants = const [],
    this.teams = const [],
  });

  bool get isTeamTournament => type == 'team';

  factory Tournament.fromJson(Map<String, dynamic> json) {
    List<TournamentParticipant> parsedParticipants = [];
    try {
      final participantsList = json['participants'] as List<dynamic>?;
      if (participantsList != null) {
        parsedParticipants = participantsList
            .map((p) => TournamentParticipant.fromJson(p as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Если парсинг участников сломался — просто пустой список
    }

    List<TournamentTeam> parsedTeams = [];
    try {
      final teamsList = json['teams'] as List<dynamic>?;
      if (teamsList != null) {
        parsedTeams = teamsList
            .map((t) => TournamentTeam.fromJson(t as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Если парсинг команд сломался — просто пустой список
    }

    return Tournament(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      club: Club.fromJson(json['club'] as Map<String, dynamic>),
      date: json['date'] as String,
      time: json['time'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      type: json['type'] as String,
      typeName: json['type_name'] as String,
      status: json['status'] as String,
      statusName: json['status_name'] as String,
      minLevel: (json['min_level'] as num).toDouble(),
      maxLevel: (json['max_level'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      maxParticipants: json['max_participants'] as int? ?? 0,
      participantsCount: json['participants_count'] as int? ?? 0,
      spotsLeft: json['spots_left'] as int? ??
          (((json['max_participants'] as int?) ?? 0) - ((json['participants_count'] as int?) ?? 0)),
      isRegistered: json['is_registered'] as bool? ?? false,
      registrationStatus: json['registration_status'] as String?,
      canRegister: json['can_register'] as bool? ?? true,
      blockReason: json['block_reason'] as String?,
      myResult: json['my_result'] != null
          ? TournamentResult.fromJson(json['my_result'] as Map<String, dynamic>)
          : null,
      participants: parsedParticipants,
      teams: parsedTeams,
    );
  }

  bool get isFull => spotsLeft <= 0;

  String get participantsText => '$participantsCount/$maxParticipants';

  String get priceText => '${price.toInt()} ₸';

  String get levelText => '${minLevel.toString()} – ${maxLevel.toString()}';

  String get minLevelCategory {
    if (minLevel < 2.0) return 'L1';
    if (minLevel < 3.0) return 'L2';
    if (minLevel < 4.0) return 'L3';
    return 'L4';
  }

  String get maxLevelCategory {
    if (maxLevel <= 2.0) return 'L1';
    if (maxLevel <= 3.0) return 'L2';
    if (maxLevel <= 4.0) return 'L3';
    return 'L4';
  }

  String get levelCategoryText => '$minLevelCategory – $maxLevelCategory';

  Color get typeColor {
    switch (type) {
      case 'americano':
        return const Color(0xFF3B82F6);
      case 'mexicano':
        return const Color(0xFFF59E0B);
      case 'team':
        return const Color(0xFFA855F7);
      case 'classic':
        return const Color(0xFF06B6D4);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  String get dayOfMonth {
    return datetime.day.toString();
  }

  String get monthShort {
    const months = ['ЯНВ', 'ФЕВ', 'МАР', 'АПР', 'МАЙ', 'ИЮН',
                    'ИЮЛ', 'АВГ', 'СЕН', 'ОКТ', 'НОЯ', 'ДЕК'];
    return months[datetime.month - 1];
  }

  String get dateFormatted {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    return '${datetime.day} ${months[datetime.month - 1]}';
  }

  String get dayOfWeek {
    const days = [
      'Понедельник', 'Вторник', 'Среда', 'Четверг',
      'Пятница', 'Суббота', 'Воскресенье',
    ];
    return days[datetime.weekday - 1];
  }
}
