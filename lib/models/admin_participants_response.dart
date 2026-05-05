import 'admin_participant.dart';
import 'admin_team.dart';

/// Ответ от GET /admin/tournaments/{id}/participants.
/// Для team-турниров содержит teams, для остальных — participants.
class AdminParticipantsResponse {
  final String type; // 'single' | 'team'
  final List<AdminParticipant> participants;
  final List<AdminTeam> teams;
  final int max; // max_participants или max_teams (для display)
  final bool canModify;

  const AdminParticipantsResponse({
    required this.type,
    required this.participants,
    required this.teams,
    required this.max,
    required this.canModify,
  });

  bool get isTeam => type == 'team';

  factory AdminParticipantsResponse.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'single';
    final isTeam = type == 'team';
    return AdminParticipantsResponse(
      type: type,
      participants: !isTeam
          ? ((json['participants'] as List?) ?? const [])
              .map((j) =>
                  AdminParticipant.fromJson(j as Map<String, dynamic>))
              .toList()
          : const [],
      teams: isTeam
          ? ((json['teams'] as List?) ?? const [])
              .map((j) => AdminTeam.fromJson(j as Map<String, dynamic>))
              .toList()
          : const [],
      max: ((isTeam ? json['max_teams'] : json['max_participants']) as num?)
              ?.toInt() ??
          0,
      canModify: json['can_modify'] as bool? ?? false,
    );
  }
}
