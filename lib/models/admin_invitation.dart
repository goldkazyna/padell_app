import 'admin_participant.dart';

/// Приглашение игрока на турнир (сторона админа).
class AdminInvitation {
  final int id;
  final String status; // pending / accepted / declined
  final DateTime? createdAt;
  final AdminParticipant player;

  const AdminInvitation({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.player,
  });

  factory AdminInvitation.fromJson(Map<String, dynamic> json) {
    return AdminInvitation(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      player: AdminParticipant.fromJson(
          (json['player'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}
