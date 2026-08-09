/// Модели для админского таба «Матчи»
/// (`GET /api/mobile/admin/tournaments/{id}/matches`).

class AdminMatchPlayer {
  final int id;
  final String name;
  final String initials;
  final String? avatarUrl;

  const AdminMatchPlayer({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarUrl,
  });

  factory AdminMatchPlayer.fromJson(Map<String, dynamic> json) {
    return AdminMatchPlayer(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      initials: json['initials'] as String? ?? '?',
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class AdminMatchTeam {
  final List<AdminMatchPlayer> players;
  final int? score;

  const AdminMatchTeam({required this.players, required this.score});

  factory AdminMatchTeam.fromJson(Map<String, dynamic> json) {
    return AdminMatchTeam(
      players: ((json['players'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminMatchPlayer.fromJson)
          .toList(),
      score: (json['score'] as num?)?.toInt(),
    );
  }

  String get title => players.map((p) => p.name).join(' / ');
}

class AdminMatch {
  final int id;
  final int? courtNumber;

  /// Эскалера: номер короткого матча внутри корта (1-3). У остальных
  /// форматов на корте один матч, поэтому поле приходит пустым.
  final int? matchNumber;
  final AdminMatchTeam team1;
  final AdminMatchTeam team2;
  final String status; // pending / completed
  final int? winner; // 1 / 2 / null

  const AdminMatch({
    required this.id,
    required this.courtNumber,
    this.matchNumber,
    required this.team1,
    required this.team2,
    required this.status,
    required this.winner,
  });

  bool get isCompleted => status == 'completed';

  factory AdminMatch.fromJson(Map<String, dynamic> json) {
    return AdminMatch(
      id: (json['id'] as num).toInt(),
      courtNumber: (json['court_number'] as num?)?.toInt(),
      matchNumber: (json['match_number'] as num?)?.toInt(),
      team1: AdminMatchTeam.fromJson(
          (json['team1'] as Map<String, dynamic>?) ?? const {}),
      team2: AdminMatchTeam.fromJson(
          (json['team2'] as Map<String, dynamic>?) ?? const {}),
      status: json['status'] as String? ?? 'pending',
      winner: (json['winner'] as num?)?.toInt(),
    );
  }
}

class AdminMatchRound {
  final int id;
  final int roundNumber;
  final String status;
  final List<AdminMatch> matches;

  /// Отдыхающие игроки в этом раунде (для Americano Flex).
  /// Для других типов турниров — пустой список.
  final List<AdminMatchPlayer> byes;

  const AdminMatchRound({
    required this.id,
    required this.roundNumber,
    required this.status,
    required this.matches,
    this.byes = const [],
  });

  factory AdminMatchRound.fromJson(Map<String, dynamic> json) {
    return AdminMatchRound(
      id: (json['id'] as num).toInt(),
      roundNumber: (json['round_number'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      matches: ((json['matches'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminMatch.fromJson)
          .toList(),
      byes: ((json['byes'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminMatchPlayer.fromJson)
          .toList(),
    );
  }
}

/// Игрок пары в таблице лидеров (парные форматы: показываем обоих с аватарами).
class AdminLeaderboardPlayer {
  final int id;
  final String name;
  final String? avatarUrl;
  final bool verified;

  const AdminLeaderboardPlayer({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.verified = false,
  });

  factory AdminLeaderboardPlayer.fromJson(Map<String, dynamic> json) {
    return AdminLeaderboardPlayer(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar'] as String?,
      verified: json['verified'] as bool? ?? false,
    );
  }
}

class AdminLeaderboardRow {
  final int position;
  final int id;
  final String name;
  final String? avatarUrl;
  final bool verified;

  /// Парные форматы: оба игрока пары (для отображения на двух строках).
  /// null/пусто — обычная одиночная строка.
  final List<AdminLeaderboardPlayer>? players;
  final int totalPoints;
  final int wins;
  final int losses;
  final int draws;
  final int pointDiff;
  final int ballPercent;
  final int winPercent;
  final int pointsFor;
  final int pointsAgainst;
  final int rating;

  /// Americano Flex: сколько матчей сыграл игрок (без bye).
  final int? matchesPlayed;

  /// Americano Flex: среднее очков за матч.
  final double? avgPoints;

  /// Americano Flex: сколько раундов отдыхал суммарно.
  final int? byeCount;

  /// Americano Flex: рейтинг на старте турнира.
  final int? ratingBefore;

  /// Americano Flex: финальный рейтинг (после завершения турнира).
  final int? ratingAfter;

  const AdminLeaderboardRow({
    required this.position,
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.verified = false,
    this.players,
    required this.totalPoints,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.pointDiff,
    required this.ballPercent,
    required this.winPercent,
    required this.pointsFor,
    required this.pointsAgainst,
    required this.rating,
    this.matchesPlayed,
    this.avgPoints,
    this.byeCount,
    this.ratingBefore,
    this.ratingAfter,
  });

  factory AdminLeaderboardRow.fromJson(Map<String, dynamic> json) {
    return AdminLeaderboardRow(
      position: (json['position'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      avatarUrl: json['avatar'] as String?,
      verified: json['verified'] as bool? ?? false,
      players: (json['players'] as List?)
          ?.map((e) =>
              AdminLeaderboardPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPoints: (json['total_points'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      draws: (json['draws'] as num?)?.toInt() ?? 0,
      pointDiff: (json['point_diff'] as num?)?.toInt() ?? 0,
      ballPercent: (json['ball_percent'] as num?)?.toInt() ?? 0,
      winPercent: (json['win_percent'] as num?)?.toInt() ?? 0,
      pointsFor: (json['points_for'] as num?)?.toInt() ?? 0,
      pointsAgainst: (json['points_against'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      matchesPlayed: (json['matches_played'] as num?)?.toInt(),
      avgPoints: (json['avg_points'] as num?)?.toDouble(),
      byeCount: (json['bye_count'] as num?)?.toInt(),
      ratingBefore: (json['rating_before'] as num?)?.toInt(),
      ratingAfter: (json['rating_after'] as num?)?.toInt(),
    );
  }
}

class AdminMatchGroup {
  final int id;
  final String name;
  final List<AdminMatchRound> rounds;
  final List<AdminLeaderboardRow> leaderboard;

  const AdminMatchGroup({
    required this.id,
    required this.name,
    required this.rounds,
    required this.leaderboard,
  });

  factory AdminMatchGroup.fromJson(Map<String, dynamic> json) {
    return AdminMatchGroup(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      rounds: ((json['rounds'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminMatchRound.fromJson)
          .toList(),
      leaderboard: ((json['leaderboard'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminLeaderboardRow.fromJson)
          .toList(),
    );
  }
}

class AdminPlayoffMatch {
  final int id;
  final String stage;
  final int? courtNumber;
  final AdminMatchTeam team1;
  final AdminMatchTeam team2;
  final String status;
  final int? winner;

  const AdminPlayoffMatch({
    required this.id,
    required this.stage,
    required this.courtNumber,
    required this.team1,
    required this.team2,
    required this.status,
    required this.winner,
  });

  bool get isCompleted => status == 'completed';

  factory AdminPlayoffMatch.fromJson(Map<String, dynamic> json) {
    return AdminPlayoffMatch(
      id: (json['id'] as num).toInt(),
      stage: json['stage'] as String? ?? '',
      courtNumber: (json['court_number'] as num?)?.toInt(),
      team1: AdminMatchTeam.fromJson(
          (json['team1'] as Map<String, dynamic>?) ?? const {}),
      team2: AdminMatchTeam.fromJson(
          (json['team2'] as Map<String, dynamic>?) ?? const {}),
      status: json['status'] as String? ?? 'pending',
      winner: (json['winner'] as num?)?.toInt(),
    );
  }
}

class AdminPlayoff {
  final bool hasPlayoff;
  final bool isGenerated;
  final List<AdminPlayoffMatch> matches;

  const AdminPlayoff({
    required this.hasPlayoff,
    required this.isGenerated,
    required this.matches,
  });

  factory AdminPlayoff.fromJson(Map<String, dynamic> json) {
    return AdminPlayoff(
      hasPlayoff: json['has_playoff'] as bool? ?? false,
      isGenerated: json['is_generated'] as bool? ?? false,
      matches: ((json['matches'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminPlayoffMatch.fromJson)
          .toList(),
    );
  }
}

class AdminMatchesSummary {
  final int matchesTotal;
  final int matchesPlayed;
  final bool allGroupMatchesPlayed;
  final bool canFinish;
  final bool canGeneratePlayoff;
  final bool canGenerateNextRound;
  final bool canFinishEarly;

  const AdminMatchesSummary({
    required this.matchesTotal,
    required this.matchesPlayed,
    required this.allGroupMatchesPlayed,
    required this.canFinish,
    required this.canGeneratePlayoff,
    required this.canGenerateNextRound,
    this.canFinishEarly = false,
  });

  factory AdminMatchesSummary.fromJson(Map<String, dynamic> json) {
    return AdminMatchesSummary(
      matchesTotal: (json['matches_total'] as num?)?.toInt() ?? 0,
      matchesPlayed: (json['matches_played'] as num?)?.toInt() ?? 0,
      allGroupMatchesPlayed: json['all_group_matches_played'] as bool? ?? false,
      canFinish: json['can_finish'] as bool? ?? false,
      canGeneratePlayoff: json['can_generate_playoff'] as bool? ?? false,
      canGenerateNextRound:
          json['can_generate_next_round'] as bool? ?? false,
      canFinishEarly: json['can_finish_early'] as bool? ?? false,
    );
  }
}

class AdminMatchesResponse {
  final String type;
  final bool unsupported;
  final String? unsupportedMessage;
  final List<AdminMatchGroup> groups;
  final AdminPlayoff? playoff;
  final AdminMatchesSummary? summary;

  /// Только для типа bali_koc: true означает, что пары ещё не созданы и
  /// в UI вместо лидерборда/раундов нужно показать кнопку «Создать пары».
  final bool pairsRequired;

  /// Сколько участников зарегистрировано (для bali_koc, когда pairs_required=true).
  final int participantsCount;

  /// Сколько пар нужно создать (для bali_koc, когда pairs_required=true).
  final int expectedPairsCount;

  /// Только для эскалеры: по чему считается место — 'raw_points' (сумма
  /// забитых) или 'points' (баллы за позиции). От этого зависит подпись
  /// колонки очков в таблице.
  final String? standingsMode;

  const AdminMatchesResponse({
    required this.type,
    required this.unsupported,
    required this.unsupportedMessage,
    required this.groups,
    required this.playoff,
    required this.summary,
    this.pairsRequired = false,
    this.participantsCount = 0,
    this.expectedPairsCount = 0,
    this.standingsMode,
  });

  factory AdminMatchesResponse.fromJson(Map<String, dynamic> json) {
    final unsupported = json['unsupported'] as bool? ?? false;
    return AdminMatchesResponse(
      type: json['type'] as String? ?? '',
      unsupported: unsupported,
      unsupportedMessage: json['message'] as String?,
      standingsMode: json['standings_mode'] as String?,
      groups: !unsupported
          ? ((json['groups'] as List?) ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(AdminMatchGroup.fromJson)
              .toList()
          : const [],
      playoff: !unsupported && json['playoff'] is Map<String, dynamic>
          ? AdminPlayoff.fromJson(json['playoff'] as Map<String, dynamic>)
          : null,
      summary: !unsupported && json['summary'] is Map<String, dynamic>
          ? AdminMatchesSummary.fromJson(
              json['summary'] as Map<String, dynamic>)
          : null,
      pairsRequired: json['pairs_required'] as bool? ?? false,
      participantsCount: (json['participants_count'] as num?)?.toInt() ?? 0,
      expectedPairsCount: (json['expected_pairs_count'] as num?)?.toInt() ?? 0,
    );
  }
}
