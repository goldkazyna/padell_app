/// Модератор клуба в админском списке
/// (`GET /admin/clubs/{club}/moderators`).
class AdminClubModerator {
  final int id;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final bool tournamentsFullAccess;
  final bool canViewActivityLog;

  const AdminClubModerator({
    required this.id,
    required this.name,
    required this.phone,
    required this.avatarUrl,
    required this.tournamentsFullAccess,
    required this.canViewActivityLog,
  });

  factory AdminClubModerator.fromJson(Map<String, dynamic> json) {
    return AdminClubModerator(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      tournamentsFullAccess: json['tournaments_full_access'] as bool? ?? false,
      canViewActivityLog: json['can_view_activity_log'] as bool? ?? false,
    );
  }
}

/// Кандидат в модераторы (результат поиска по телефону).
class ModeratorCandidate {
  final int id;
  final String name;
  final String? phone;
  final double? level;
  final String? avatarUrl;

  const ModeratorCandidate({
    required this.id,
    required this.name,
    required this.phone,
    required this.level,
    required this.avatarUrl,
  });

  factory ModeratorCandidate.fromJson(Map<String, dynamic> json) {
    return ModeratorCandidate(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      level: (json['level'] as num?)?.toDouble(),
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
