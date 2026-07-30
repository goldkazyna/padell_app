class GamePlayer {
  final int id;
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
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String format;
  final String formatName;
  final Map<String, dynamic>? formatMeta;
  final double minLevel;
  final double maxLevel;
  final String status;
  final String statusName;
  final bool isPrivate;
  final bool scoreLocked;
  final List<GamePlayer> players;
  final int confirmedCount;
  final List<int> availablePositions;
  final List<GameRound> rounds;
  final List<GameRankingRow> americanoRanking;
  final bool isParticipant;
  final String? myStatus;
  final int? myPosition;
  final int? myRatingChange;

  Game({
    required this.id,
    required this.creatorId,
    required this.isCreator,
    this.club,
    this.startsAt,
    this.endsAt,
    required this.format,
    required this.formatName,
    this.formatMeta,
    required this.minLevel,
    required this.maxLevel,
    required this.status,
    required this.statusName,
    this.isPrivate = false,
    this.scoreLocked = false,
    this.players = const [],
    this.confirmedCount = 0,
    this.availablePositions = const [],
    this.rounds = const [],
    this.americanoRanking = const [],
    this.isParticipant = false,
    this.myStatus,
    this.myPosition,
    this.myRatingChange,
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

    return Game(
      id: json['id'] as int,
      creatorId: json['creator_id'] as int? ?? 0,
      isCreator: json['is_creator'] as bool? ?? false,
      club: json['club'] != null
          ? GameClub.fromJson(json['club'] as Map<String, dynamic>)
          : null,
      startsAt: DateTime.tryParse(json['starts_at'] as String? ?? ''),
      endsAt: DateTime.tryParse(json['ends_at'] as String? ?? ''),
      format: json['format'] as String? ?? '',
      formatName: json['format_name'] as String? ?? '',
      formatMeta: json['format_meta'] as Map<String, dynamic>?,
      minLevel: (json['min_level'] as num?)?.toDouble() ?? 0.0,
      maxLevel: (json['max_level'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? '',
      statusName: json['status_name'] as String? ?? '',
      isPrivate: json['is_private'] as bool? ?? false,
      scoreLocked: json['score_locked'] as bool? ?? false,
      players: parsedPlayers,
      confirmedCount: json['confirmed_count'] as int? ?? 0,
      availablePositions: parsedPositions,
      rounds: parsedRounds,
      americanoRanking: parsedRanking,
      isParticipant: json['is_participant'] as bool? ?? false,
      myStatus: json['my_status'] as String?,
      myPosition: json['my_position'] as int?,
      myRatingChange: json['my_rating_change'] as int?,
    );
  }

  // === Computed getters ===

  bool get isOpen => status == 'open';
  bool get isFull => availablePositions.isEmpty;
  bool get isInProgress => status == 'in_progress';
  bool get isFinished => status == 'finished';
  bool get isCancelled => status == 'cancelled';

  bool get isRated => format == 'rated';
  bool get isFriendly => format == 'friendly';

  bool get isSets => format == 'sets';
  bool get isPoints => format == 'points';
  bool get isAmericano => format == 'americano';

  bool get isPendingConfirmation => isInProgress && scoreLocked;

  String get levelText => '${minLevel.toString()} – ${maxLevel.toString()}';

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
    return GameInvitationItem(
      invitationId: json['invitation_id'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
      inviterId: json['inviter_id'] as int? ?? 0,
      inviterName: json['inviter_name'] as String? ?? '',
      game: Game.fromJson(json['game'] as Map<String, dynamic>),
    );
  }
}
