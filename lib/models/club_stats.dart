/// Статистика клуба за период — игрок лидерборда.
class ClubStatsPlayer {
  final int userId;
  final String name;
  final String? avatar;
  final double? level;
  final int? rating;
  final bool levelVerified;
  final int tournaments;
  final int ratingEarned;
  final int wins;
  final int losses;
  final int winrate;

  ClubStatsPlayer({
    required this.userId,
    required this.name,
    this.avatar,
    this.level,
    this.rating,
    this.levelVerified = false,
    required this.tournaments,
    required this.ratingEarned,
    required this.wins,
    required this.losses,
    required this.winrate,
  });

  int get matches => wins + losses;

  factory ClubStatsPlayer.fromJson(Map<String, dynamic> json) {
    final user = (json['user'] as Map<String, dynamic>?) ?? const {};
    final rawLevel = user['level'];
    return ClubStatsPlayer(
      userId: (user['id'] as num?)?.toInt() ?? 0,
      name: (user['name'] as String?) ?? '',
      avatar: user['avatar'] as String?,
      level: rawLevel == null ? null : double.tryParse(rawLevel.toString()),
      rating: (user['rating'] as num?)?.toInt(),
      levelVerified: user['level_verified'] as bool? ?? false,
      tournaments: (json['tournaments'] as num?)?.toInt() ?? 0,
      ratingEarned: (json['rating_earned'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      losses: (json['losses'] as num?)?.toInt() ?? 0,
      winrate: (json['winrate'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Ответ статистики клуба: период + список игроков.
class ClubStatsResult {
  final String from;
  final String to;
  final List<ClubStatsPlayer> players;

  ClubStatsResult({
    required this.from,
    required this.to,
    required this.players,
  });

  factory ClubStatsResult.fromJson(Map<String, dynamic> json) {
    final list = (json['players'] as List?) ?? const [];
    return ClubStatsResult(
      from: (json['from'] as String?) ?? '',
      to: (json['to'] as String?) ?? '',
      players: list
          .map((e) => ClubStatsPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
