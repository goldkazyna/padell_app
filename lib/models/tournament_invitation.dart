class TournamentInvitation {
  final int id;
  final String? invitedByName;
  final int tournamentId;
  final String tournamentName;
  final String tournamentType;
  final String? startDate;
  final String? clubName;

  TournamentInvitation({
    required this.id,
    this.invitedByName,
    required this.tournamentId,
    required this.tournamentName,
    required this.tournamentType,
    this.startDate,
    this.clubName,
  });

  factory TournamentInvitation.fromJson(Map<String, dynamic> json) {
    final t = (json['tournament'] as Map<String, dynamic>?) ?? const {};
    return TournamentInvitation(
      id: json['id'] as int,
      invitedByName: json['invited_by_name'] as String?,
      tournamentId: t['id'] as int,
      tournamentName: t['name'] as String? ?? '',
      tournamentType: t['type'] as String? ?? '',
      startDate: t['start_date'] as String?,
      clubName: t['club_name'] as String?,
    );
  }
}
