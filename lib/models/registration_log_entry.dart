import 'admin_participant.dart';

/// Одна запись журнала записей турнира: игрок + действие + время.
class RegistrationLogEntry {
  final int id;
  final String action; // registered / unregistered
  final DateTime? createdAt;
  final AdminParticipant user;

  const RegistrationLogEntry({
    required this.id,
    required this.action,
    required this.createdAt,
    required this.user,
  });

  factory RegistrationLogEntry.fromJson(Map<String, dynamic> json) {
    return RegistrationLogEntry(
      id: (json['id'] as num).toInt(),
      action: json['action'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      user: AdminParticipant.fromJson(
          (json['user'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}
