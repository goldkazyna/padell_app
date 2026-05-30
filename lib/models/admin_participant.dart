/// Участник турнира (одиночные форматы) или игрок в составе пары.
class AdminParticipant {
  final int id;
  final String name;
  final String? phone;
  final double? level;
  final int? rating;
  final String? avatarUrl;
  final String? status; // registered / pending / cancelled — только для одиночных
  final DateTime? registeredAt;
  final bool levelVerified;
  final DateTime? moderationDeadline;

  const AdminParticipant({
    required this.id,
    required this.name,
    required this.phone,
    required this.level,
    required this.rating,
    required this.avatarUrl,
    required this.status,
    required this.registeredAt,
    this.levelVerified = false,
    this.moderationDeadline,
  });

  factory AdminParticipant.fromJson(Map<String, dynamic> json) {
    return AdminParticipant(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      level: (json['level'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toInt(),
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String?,
      registeredAt:
          DateTime.tryParse(json['registered_at'] as String? ?? ''),
      levelVerified: json['level_verified'] as bool? ?? false,
      moderationDeadline:
          DateTime.tryParse(json['moderation_deadline'] as String? ?? ''),
    );
  }
}
