import 'tournament.dart';

class TournamentInvitation {
  final int id;
  final String? invitedByName;
  final Tournament tournament;

  TournamentInvitation({
    required this.id,
    this.invitedByName,
    required this.tournament,
  });

  int get tournamentId => tournament.id;

  factory TournamentInvitation.fromJson(Map<String, dynamic> json) {
    return TournamentInvitation(
      id: json['id'] as int,
      invitedByName: json['invited_by_name'] as String?,
      tournament:
          Tournament.fromJson(json['tournament'] as Map<String, dynamic>),
    );
  }
}
