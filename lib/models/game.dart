class GamePlayer {
  final int id; // user id
  final int playerId; // GamePlayer row id — для approve/reject/remove
  final int position;
  final String status;
  final String source;
  final bool outOfRange;
  final String fullName;
  final String? avatar;
  final int rating;
  final double level;
  final bool isMe;
  final bool scoreConfirmed;

  GamePlayer({
    required this.id,
    this.playerId = 0,
    required this.position,
    required this.status,
    required this.source,
    this.outOfRange = false,
    required this.fullName,
    this.avatar,
    required this.rating,
    required this.level,
    this.isMe = false,
    this.scoreConfirmed = false,
  });

  factory GamePlayer.fromJson(Map<String, dynamic> json) {
    double parsedLevel = 0.0;
    final rawLevel = json['level'];
    if (rawLevel is num) {
      parsedLevel = rawLevel.toDouble();
    } else if (rawLevel is String) {
      parsedLevel = double.tryParse(rawLevel) ?? 0.0;
    }

    return GamePlayer(
      id: json['id'] as int? ?? 0,
      playerId: json['player_id'] as int? ?? 0,
      position: json['position'] as int? ?? 0,
      status: json['status'] as String? ?? 'pending',
      source: json['source'] as String? ?? '',
      outOfRange: json['out_of_range'] as bool? ?? false,
      fullName: json['full_name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      level: parsedLevel,
      isMe: json['is_me'] as bool? ?? false,
      scoreConfirmed: json['score_confirmed'] as bool? ?? false,
    );
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  bool get isAccepted => status == 'accepted';
  bool get isInvited => status == 'invited';
  bool get isCandidate => status == 'candidate';
}

class GameRound {
  final int id;
  final int roundNo;
  final List<int> pairA;
  final List<int> pairB;
  final int? scoreA;
  final int? scoreB;
  final int? tiebreakA;
  final int? tiebreakB;
  final bool isPlayed;

  GameRound({
    required this.id,
    required this.roundNo,
    this.pairA = const [],
    this.pairB = const [],
    this.scoreA,
    this.scoreB,
    this.tiebreakA,
    this.tiebreakB,
    this.isPlayed = false,
  });

  factory GameRound.fromJson(Map<String, dynamic> json) {
    List<int> parsedPairA = [];
    try {
      final list = json['pair_a'] as List<dynamic>?;
      if (list != null) {
        parsedPairA = list.map((p) => p as int).toList();
      }
    } catch (_) {
      // Если парсинг пары A сломался — пустой список
    }

    List<int> parsedPairB = [];
    try {
      final list = json['pair_b'] as List<dynamic>?;
      if (list != null) {
        parsedPairB = list.map((p) => p as int).toList();
      }
    } catch (_) {
      // Если парсинг пары B сломался — пустой список
    }

    return GameRound(
      id: json['id'] as int? ?? 0,
      roundNo: json['round_no'] as int? ?? 0,
      pairA: parsedPairA,
      pairB: parsedPairB,
      scoreA: json['score_a'] as int?,
      scoreB: json['score_b'] as int?,
      tiebreakA: json['tiebreak_a'] as int?,
      tiebreakB: json['tiebreak_b'] as int?,
      isPlayed: json['is_played'] as bool? ?? false,
    );
  }
}

class GameRankingRow {
  final int userId;
  final int points;
  final int wins;
  final int diff;
  final int place;

  GameRankingRow({
    required this.userId,
    required this.points,
    required this.wins,
    required this.diff,
    required this.place,
  });

  factory GameRankingRow.fromJson(Map<String, dynamic> json) {
    return GameRankingRow(
      userId: json['user_id'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      diff: json['diff'] as int? ?? 0,
      place: json['place'] as int? ?? 0,
    );
  }
}

class GameClub {
  final int id;
  final String name;

  GameClub({required this.id, required this.name});

  factory GameClub.fromJson(Map<String, dynamic> json) {
    return GameClub(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class Game {
  final int id;
  final int creatorId;
  final bool isCreator;
  final GameClub? club;
  final int? courtId;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String type;
  final String typeName;
  final String format;
  final String formatName;
  final Map<String, dynamic>? formatMeta;
  final String visibility;
  final double? ratingMin;
  final double? ratingMax;
  final int capacity;
  final int? price;
  final String? description;
  final String status;
  final String statusName;
  final bool scoreLocked;
  final List<GamePlayer> players;
  final int acceptedCount;
  final List<int> availablePositions;
  final List<GameRound> rounds;
  final List<GameRankingRow> americanoRanking;
  final bool isParticipant;
  final String? myStatus;
  final int? myPosition;
  final String? shareToken;
  final bool shareActive;
  final bool myScoreConfirmed;

  Game({
    required this.id,
    required this.creatorId,
    required this.isCreator,
    this.club,
    this.courtId,
    this.startsAt,
    this.endsAt,
    required this.type,
    required this.typeName,
    required this.format,
    required this.formatName,
    this.formatMeta,
    required this.visibility,
    this.ratingMin,
    this.ratingMax,
    this.capacity = 0,
    this.price,
    this.description,
    required this.status,
    required this.statusName,
    this.scoreLocked = false,
    this.players = const [],
    this.acceptedCount = 0,
    this.availablePositions = const [],
    this.rounds = const [],
    this.americanoRanking = const [],
    this.isParticipant = false,
    this.myStatus,
    this.myPosition,
    this.shareToken,
    this.shareActive = false,
    this.myScoreConfirmed = false,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    List<GamePlayer> parsedPlayers = [];
    try {
      final playersList = json['players'] as List<dynamic>?;
      if (playersList != null) {
        parsedPlayers = playersList
            .map((p) => GamePlayer.fromJson(p as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Если парсинг игроков сломался — просто пустой список
    }

    List<GameRound> parsedRounds = [];
    try {
      final roundsList = json['rounds'] as List<dynamic>?;
      if (roundsList != null) {
        parsedRounds = roundsList
            .map((r) => GameRound.fromJson(r as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Если парсинг раундов сломался — пустой список
    }

    List<GameRankingRow> parsedRanking = [];
    try {
      final rankingList = json['americano_ranking'] as List<dynamic>?;
      if (rankingList != null) {
        parsedRanking = rankingList
            .map((r) => GameRankingRow.fromJson(r as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Если парсинг рейтинга сломался — пустой список
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

    double? parsedRatingMin;
    final rawRatingMin = json['rating_min'];
    if (rawRatingMin != null) {
      parsedRatingMin = double.tryParse(rawRatingMin.toString());
    }

    double? parsedRatingMax;
    final rawRatingMax = json['rating_max'];
    if (rawRatingMax != null) {
      parsedRatingMax = double.tryParse(rawRatingMax.toString());
    }

    return Game(
      id: json['id'] as int,
      creatorId: json['creator_id'] as int? ?? 0,
      isCreator: json['is_creator'] as bool? ?? false,
      club: json['club'] != null
          ? GameClub.fromJson(json['club'] as Map<String, dynamic>)
          : null,
      courtId: json['court_id'] as int?,
      startsAt: DateTime.tryParse(json['starts_at'] as String? ?? ''),
      endsAt: DateTime.tryParse(json['ends_at'] as String? ?? ''),
      type: json['type'] as String? ?? '',
      typeName: json['type_name'] as String? ?? '',
      format: json['format'] as String? ?? '',
      formatName: json['format_name'] as String? ?? '',
      formatMeta: json['format_meta'] as Map<String, dynamic>?,
      visibility: json['visibility'] as String? ?? '',
      ratingMin: parsedRatingMin,
      ratingMax: parsedRatingMax,
      capacity: json['capacity'] as int? ?? 0,
      price: json['price'] as int?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? '',
      statusName: json['status_name'] as String? ?? '',
      scoreLocked: json['score_locked'] as bool? ?? false,
      players: parsedPlayers,
      acceptedCount: json['accepted_count'] as int? ?? 0,
      availablePositions: parsedPositions,
      rounds: parsedRounds,
      americanoRanking: parsedRanking,
      isParticipant: json['is_participant'] as bool? ?? false,
      myStatus: json['my_status'] as String?,
      myPosition: json['my_position'] as int?,
      shareToken: json['share_token'] as String?,
      shareActive: json['share_active'] as bool? ?? false,
      myScoreConfirmed: json['my_score_confirmed'] as bool? ?? false,
    );
  }

  // === Computed getters ===

  bool get isOpen => status == 'open';
  bool get isFull => availablePositions.isEmpty;
  bool get isInProgress => status == 'in_progress';
  bool get isFinished => status == 'finished';
  bool get isCancelled => status == 'cancelled';

  bool get isRated => type == 'rated';
  bool get isFriendly => type == 'friendly';

  bool get isSets => format == 'sets';
  bool get isPoints => format == 'points';
  bool get isAmericano => format == 'americano';

  bool get isPrivate => visibility == 'private';

  bool get isPendingConfirmation => isInProgress && scoreLocked;

  String get levelText =>
      '${ratingMin?.toString() ?? ''} – ${ratingMax?.toString() ?? ''}';

  String get dateFormatted {
    const months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря',
    ];
    final date = startsAt;
    if (date == null) return '';
    return '${date.day} ${months[date.month - 1]}';
  }

  String get timeFormatted {
    final date = startsAt;
    if (date == null) return '';
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get dayOfWeek {
    const days = [
      'Понедельник', 'Вторник', 'Среда', 'Четверг',
      'Пятница', 'Суббота', 'Воскресенье',
    ];
    final date = startsAt;
    if (date == null) return '';
    return days[date.weekday - 1];
  }
}

class GameInvitationItem {
  final int invitationId;
  final String status;
  final DateTime? expiresAt;
  final int inviterId;
  final String inviterName;
  final Game game;

  GameInvitationItem({
    required this.invitationId,
    required this.status,
    this.expiresAt,
    required this.inviterId,
    required this.inviterName,
    required this.game,
  });

  factory GameInvitationItem.fromJson(Map<String, dynamic> json) {
    final inviter = json['inviter'] as Map<String, dynamic>?;

    return GameInvitationItem(
      invitationId: json['invitation_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
      inviterId: inviter?['id'] as int? ?? 0,
      inviterName: inviter?['name'] as String? ?? '',
      game: Game.fromJson(json['game'] as Map<String, dynamic>),
    );
  }
}
