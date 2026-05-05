import 'admin_participant.dart';

/// Пара в team-турнире.
class AdminTeam {
  final int id;
  final String status; // pending / approved / rejected
  final AdminParticipant? player1;
  final AdminParticipant? player2;

  const AdminTeam({
    required this.id,
    required this.status,
    required this.player1,
    required this.player2,
  });

  factory AdminTeam.fromJson(Map<String, dynamic> json) {
    return AdminTeam(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? '',
      player1: json['player1'] is Map<String, dynamic>
          ? AdminParticipant.fromJson(
              json['player1'] as Map<String, dynamic>)
          : null,
      player2: json['player2'] is Map<String, dynamic>
          ? AdminParticipant.fromJson(
              json['player2'] as Map<String, dynamic>)
          : null,
    );
  }
}
