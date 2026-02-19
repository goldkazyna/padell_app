class MatchPlayer {
  final int id;
  final String name;
  final String? avatar;

  const MatchPlayer({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory MatchPlayer.fromJson(Map<String, dynamic> json) {
    return MatchPlayer(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
    );
  }
}

class Match {
  final int id;
  final String tournamentName;
  final String date;
  final String format;
  final String result;
  final String score;
  final MatchPlayer? partner;
  final List<MatchPlayer> opponents;

  const Match({
    required this.id,
    required this.tournamentName,
    required this.date,
    required this.format,
    required this.result,
    required this.score,
    this.partner,
    required this.opponents,
  });

  bool get isWin => result == 'win';

  String get formatName {
    switch (format) {
      case 'americano':
        return 'Американо';
      case 'mexicano':
        return 'Мексикано';
      case 'group':
        return 'Групповой';
      case 'playoff':
        return 'Плей-офф';
      default:
        return format;
    }
  }

  factory Match.fromJson(Map<String, dynamic> json) {
    final opponentsList = json['opponents'] as List<dynamic>? ?? [];

    return Match(
      id: json['id'] as int,
      tournamentName: json['tournament_name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      format: json['format'] as String? ?? '',
      result: json['result'] as String? ?? '',
      score: json['score'] as String? ?? '',
      partner: json['partner'] != null
          ? MatchPlayer.fromJson(json['partner'] as Map<String, dynamic>)
          : null,
      opponents: opponentsList
          .map((o) => MatchPlayer.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}
