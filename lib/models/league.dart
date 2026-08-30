/// Лига — серия турниров с общей таблицей.
///
/// Этапы лиги — обычные турниры, поэтому открываются существующим экраном
/// турнира. Здесь только сама лига и её сводный зачёт.
class League {
  final int id;
  final String name;
  final String? description;
  final String status;
  final String statusName;

  final String? clubName;
  final String? clubCity;
  final String? clubLogo;

  final DateTime? startDate;
  final DateTime? endDate;

  final double? minLevel;
  final double? maxLevel;
  final int? price;

  final int stagesTotal;
  final int stagesDone;
  final int players;
  final int? maxPlayers;
  final bool isRegistered;

  /// Формат этапов лиги — подставляется в форму нового этапа.
  /// Приходит только в админском ответе.
  final bool isPaired;
  final int courtsCount;

  /// Название формата для карточки: у лиги оно одно на все этапы,
  /// поэтому показываем его там же, где у турнира стоит тип.
  final String? formatName;

  /// Ближайший несыгранный этап — по нему видно, когда следующая игра.
  final LeagueStage? nextStage;

  /// Моё место в сводной таблице; null, если ещё не играл.
  final int? myPlace;
  final int? myPoints;
  final int? myStages;
  final int? totalPlayers;

  final List<LeagueStage> stages;
  final List<LeagueStandingRow> standings;

  /// Состав лиги — приходит только в админском ответе.
  final List<LeagueMember> roster;

  const League({
    required this.id,
    required this.name,
    required this.status,
    required this.statusName,
    required this.stagesTotal,
    required this.stagesDone,
    required this.players,
    required this.isRegistered,
    this.description,
    this.clubName,
    this.clubCity,
    this.clubLogo,
    this.startDate,
    this.endDate,
    this.minLevel,
    this.maxLevel,
    this.price,
    this.maxPlayers,
    this.nextStage,
    this.myPlace,
    this.myPoints,
    this.myStages,
    this.totalPlayers,
    this.isPaired = false,
    this.courtsCount = 2,
    this.formatName,
    this.stages = const [],
    this.standings = const [],
    this.roster = const [],
  });

  factory League.fromJson(Map<String, dynamic> json) {
    final club = json['club'] as Map<String, dynamic>?;

    return League(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? '',
      statusName: json['status_name'] as String? ?? '',
      clubName: club?['name'] as String?,
      clubCity: club?['city'] as String?,
      clubLogo: club?['logo'] as String?,
      startDate: _date(json['start_date']),
      endDate: _date(json['end_date']),
      minLevel: _double(json['min_level']),
      maxLevel: _double(json['max_level']),
      price: (json['price'] as num?)?.toInt(),
      stagesTotal: (json['stages_total'] as num?)?.toInt() ?? 0,
      stagesDone: (json['stages_done'] as num?)?.toInt() ?? 0,
      players: (json['players'] as num?)?.toInt() ?? 0,
      maxPlayers: (json['max_players'] as num?)?.toInt(),
      isRegistered: json['is_registered'] == true,
      nextStage: json['next_stage'] != null
          ? LeagueStage.fromJson(json['next_stage'] as Map<String, dynamic>)
          : null,
      myPlace: (json['my_place'] as num?)?.toInt(),
      myPoints: (json['my_points'] as num?)?.toInt(),
      myStages: (json['my_stages'] as num?)?.toInt(),
      totalPlayers: (json['total_players'] as num?)?.toInt(),
      isPaired: json['is_paired'] == true,
      courtsCount: (json['courts_count'] as num?)?.toInt() ?? 2,
      formatName: json['format_name'] as String?,
      stages: ((json['stages'] as List<dynamic>?) ?? const [])
          .map((s) => LeagueStage.fromJson(s as Map<String, dynamic>))
          .toList(),
      standings: ((json['standings'] as List<dynamic>?) ?? const [])
          .map((s) => LeagueStandingRow.fromJson(s as Map<String, dynamic>))
          .toList(),
      roster: ((json['roster'] as List<dynamic>?) ?? const [])
          .map((p) => LeagueMember.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Доля сыгранных этапов — для полоски прогресса.
  double get progress => stagesTotal > 0 ? stagesDone / stagesTotal : 0;

  bool get isFull => maxPlayers != null && players >= maxPlayers!;

  bool get canRegister =>
      !isRegistered && !isFull && (status == 'open' || status == 'in_progress');

  static DateTime? _date(dynamic value) =>
      value is String ? DateTime.tryParse(value)?.toLocal() : null;

  static double? _double(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Этап лиги — обычный турнир.
class LeagueStage {
  final int id;
  final int stage;
  final String name;
  final String status;
  final String statusName;
  final DateTime? startDate;
  final int participants;
  final int? maxParticipants;

  /// Моё место и очки на этапе — приходят только у сыгранного.
  /// Медальку за этап показывает лига: в истории турниров этапов больше нет.
  final int? myPlace;
  final int? myPoints;

  const LeagueStage({
    required this.id,
    required this.stage,
    required this.name,
    this.status = '',
    this.statusName = '',
    this.startDate,
    this.participants = 0,
    this.maxParticipants,
    this.myPlace,
    this.myPoints,
  });

  factory LeagueStage.fromJson(Map<String, dynamic> json) => LeagueStage(
        id: json['id'] as int? ?? 0,
        stage: (json['stage'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        status: json['status'] as String? ?? '',
        statusName: json['status_name'] as String? ?? '',
        startDate: League._date(json['start_date']),
        participants: (json['participants'] as num?)?.toInt() ?? 0,
        maxParticipants: (json['max_participants'] as num?)?.toInt(),
        myPlace: (json['my_place'] as num?)?.toInt(),
        myPoints: (json['my_points'] as num?)?.toInt(),
      );

  bool get isFinished => status == 'completed';
}

/// Участник состава лиги (админский ответ).
class LeagueMember {
  final int userId;
  final String name;
  final String? avatar;
  final double? level;
  final int rating;

  /// registered — в составе, left — выбыл (очки за сыгранное остаются).
  final String status;

  const LeagueMember({
    required this.userId,
    required this.name,
    required this.status,
    this.avatar,
    this.level,
    this.rating = 0,
  });

  factory LeagueMember.fromJson(Map<String, dynamic> json) => LeagueMember(
        userId: (json['user_id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? 'Игрок',
        avatar: json['avatar'] as String?,
        level: League._double(json['level']),
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        status: json['status'] as String? ?? 'registered',
      );

  bool get isActive => status == 'registered';
}

/// Строка сводной таблицы лиги.
class LeagueStandingRow {
  final int position;
  final int userId;
  final String name;
  final String? avatar;
  final double? level;
  final int rating;

  /// Сколько этапов лиги сыграл: замена, вышедшая один раз, тоже в таблице.
  final int stages;

  final int wins;
  final int losses;
  final int draws;
  final int pointsFor;
  final int pointsAgainst;
  final int diff;
  final double average;
  final bool isMe;

  /// Подтверждённый уровень — галочка рядом с именем, как в таблице этапа.
  final bool verified;

  const LeagueStandingRow({
    required this.position,
    required this.userId,
    required this.name,
    required this.stages,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.pointsFor,
    required this.pointsAgainst,
    required this.diff,
    required this.average,
    required this.isMe,
    this.verified = false,
    this.avatar,
    this.level,
    this.rating = 0,
  });

  factory LeagueStandingRow.fromJson(Map<String, dynamic> json) => LeagueStandingRow(
        position: (json['position'] as num?)?.toInt() ?? 0,
        userId: (json['user_id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
        avatar: json['avatar'] as String?,
        level: League._double(json['level']),
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        stages: (json['stages'] as num?)?.toInt() ?? 0,
        wins: (json['wins'] as num?)?.toInt() ?? 0,
        losses: (json['losses'] as num?)?.toInt() ?? 0,
        draws: (json['draws'] as num?)?.toInt() ?? 0,
        pointsFor: (json['points_for'] as num?)?.toInt() ?? 0,
        pointsAgainst: (json['points_against'] as num?)?.toInt() ?? 0,
        diff: (json['diff'] as num?)?.toInt() ?? 0,
        average: League._double(json['average']) ?? 0,
        isMe: json['is_me'] == true,
        verified: json['verified'] == true,
      );
}

/// Плашка «Этап 3 из 8» внутри турнира.
class TournamentLeagueRef {
  final int id;
  final String name;
  final int stage;
  final int stagesTotal;

  const TournamentLeagueRef({
    required this.id,
    required this.name,
    required this.stage,
    required this.stagesTotal,
  });

  factory TournamentLeagueRef.fromJson(Map<String, dynamic> json) => TournamentLeagueRef(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        stage: (json['stage'] as num?)?.toInt() ?? 0,
        stagesTotal: (json['stages_total'] as num?)?.toInt() ?? 0,
      );
}
