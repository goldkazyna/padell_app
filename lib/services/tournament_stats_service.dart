import 'api_service.dart';
import 'storage_service.dart';

class TournamentStatsPlayer {
  final int id;
  final String name;
  final String? avatar;
  final int position;
  final int wins;
  final int losses;
  final int totalPoints;
  final int pointsFor;
  final int pointsAgainst;
  final int winPercent;

  TournamentStatsPlayer({
    required this.id,
    required this.name,
    this.avatar,
    required this.position,
    required this.wins,
    required this.losses,
    required this.totalPoints,
    required this.pointsFor,
    required this.pointsAgainst,
    required this.winPercent,
  });

  factory TournamentStatsPlayer.fromJson(Map<String, dynamic> json) {
    return TournamentStatsPlayer(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      position: json['position'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      totalPoints: json['total_points'] as int? ?? 0,
      pointsFor: json['points_for'] as int? ?? 0,
      pointsAgainst: json['points_against'] as int? ?? 0,
      winPercent: json['win_percent'] as int? ?? 0,
    );
  }
}

class TournamentStatsTeam {
  final int id;
  final int position;
  final String player1Name;
  final int player1Id;
  final bool player1Verified;
  final String player2Name;
  final int player2Id;
  final bool player2Verified;
  final int wins;
  final int losses;
  final int pointsFor;
  final int pointsAgainst;

  TournamentStatsTeam({
    required this.id,
    required this.position,
    required this.player1Name,
    required this.player1Id,
    required this.player1Verified,
    required this.player2Name,
    required this.player2Id,
    required this.player2Verified,
    required this.wins,
    required this.losses,
    required this.pointsFor,
    required this.pointsAgainst,
  });

  factory TournamentStatsTeam.fromJson(Map<String, dynamic> json) {
    final p1 = json['player1'] as Map<String, dynamic>?;
    final p2 = json['player2'] as Map<String, dynamic>?;
    return TournamentStatsTeam(
      id: json['id'] as int? ?? 0,
      position: json['position'] as int? ?? 0,
      player1Name: p1?['name'] as String? ?? '',
      player1Id: p1?['id'] as int? ?? 0,
      player1Verified: p1?['level_verified'] as bool? ?? false,
      player2Name: p2?['name'] as String? ?? '',
      player2Id: p2?['id'] as int? ?? 0,
      player2Verified: p2?['level_verified'] as bool? ?? false,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      pointsFor: json['points_for'] as int? ?? 0,
      pointsAgainst: json['points_against'] as int? ?? 0,
    );
  }
}

class TournamentStatsMatch {
  final String stage;
  final int? round;
  final List<TournamentStatsPlayerRef> team1;
  final List<TournamentStatsPlayerRef> team2;
  final int team1Score;
  final int team2Score;

  TournamentStatsMatch({
    required this.stage,
    this.round,
    required this.team1,
    required this.team2,
    required this.team1Score,
    required this.team2Score,
  });

  factory TournamentStatsMatch.fromJson(Map<String, dynamic> json) {
    List<TournamentStatsPlayerRef> parsePlayers(dynamic raw) {
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map((p) => TournamentStatsPlayerRef.fromJson(p))
          .toList();
    }

    return TournamentStatsMatch(
      stage: json['stage'] as String? ?? '',
      round: json['round'] as int?,
      team1: parsePlayers(json['team1_players']),
      team2: parsePlayers(json['team2_players']),
      team1Score: json['team1_score'] as int? ?? 0,
      team2Score: json['team2_score'] as int? ?? 0,
    );
  }
}

class TournamentStatsPlayerRef {
  final int id;
  final String name;

  TournamentStatsPlayerRef({required this.id, required this.name});

  factory TournamentStatsPlayerRef.fromJson(Map<String, dynamic> json) {
    return TournamentStatsPlayerRef(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}

class TournamentStatsPlayoffMatch {
  final String stage;
  final String stageName;
  final int matchNumber;
  final String status;
  final int team1Score;
  final int team2Score;
  final List<TournamentStatsPlayerRef> team1Players;
  final List<TournamentStatsPlayerRef> team2Players;

  TournamentStatsPlayoffMatch({
    required this.stage,
    required this.stageName,
    required this.matchNumber,
    required this.status,
    required this.team1Score,
    required this.team2Score,
    required this.team1Players,
    required this.team2Players,
  });

  factory TournamentStatsPlayoffMatch.fromJson(Map<String, dynamic> json) {
    List<TournamentStatsPlayerRef> parse(dynamic raw) {
      if (raw is! List) return [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map((p) => TournamentStatsPlayerRef.fromJson(p))
          .toList();
    }

    return TournamentStatsPlayoffMatch(
      stage: json['stage'] as String? ?? '',
      stageName: json['stage_name'] as String? ?? '',
      matchNumber: json['match_number'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      team1Score: json['team1_score'] as int? ?? 0,
      team2Score: json['team2_score'] as int? ?? 0,
      team1Players: parse(json['team1_players']),
      team2Players: parse(json['team2_players']),
    );
  }
}

class TournamentStatsInfo {
  final int id;
  final String name;
  final String date;
  final String time;
  final String clubName;
  final String format;
  final String formatName;
  final int participantsCount;

  TournamentStatsInfo({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.clubName,
    required this.format,
    required this.formatName,
    required this.participantsCount,
  });

  factory TournamentStatsInfo.fromJson(Map<String, dynamic> json) {
    return TournamentStatsInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      clubName: json['club_name'] as String? ?? '',
      format: json['format'] as String? ?? '',
      formatName: json['format_name'] as String? ?? '',
      participantsCount: json['participants_count'] as int? ?? 0,
    );
  }
}

class TournamentStats {
  final TournamentStatsInfo info;
  final List<TournamentStatsPlayer> leaderboard;
  final List<TournamentStatsTeam> teamStandings;
  final List<TournamentStatsPlayoffMatch> playoff;
  final List<TournamentStatsMatch> matches;

  TournamentStats({
    required this.info,
    required this.leaderboard,
    required this.teamStandings,
    required this.playoff,
    required this.matches,
  });
}

class TournamentStatsService {
  final ApiService _api;
  final StorageService _storage;

  TournamentStatsService(this._api, this._storage);

  Future<TournamentStats?> getStats(int tournamentId) async {
    final token = await _storage.getToken();
    if (token == null) return null;

    final response = await _api.get('/tournaments/$tournamentId/stats', token);
    if (response['success'] != true) return null;

    final infoJson = response['tournament'] as Map<String, dynamic>;
    final leaderboardList = response['leaderboard'] as List<dynamic>? ?? [];
    final teamList = response['team_standings'] as List<dynamic>? ?? [];
    final playoffList = response['playoff'] as List<dynamic>? ?? [];
    final matchesList = response['matches'] as List<dynamic>? ?? [];

    return TournamentStats(
      info: TournamentStatsInfo.fromJson(infoJson),
      leaderboard: leaderboardList
          .map((j) => TournamentStatsPlayer.fromJson(j as Map<String, dynamic>))
          .toList(),
      teamStandings: teamList
          .map((j) => TournamentStatsTeam.fromJson(j as Map<String, dynamic>))
          .toList(),
      playoff: playoffList
          .map((j) => TournamentStatsPlayoffMatch.fromJson(j as Map<String, dynamic>))
          .toList(),
      matches: matchesList
          .map((j) => TournamentStatsMatch.fromJson(j as Map<String, dynamic>))
          .toList(),
    );
  }
}
