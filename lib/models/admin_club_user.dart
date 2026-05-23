/// Игрок в админском списке клуба (`GET /admin/clubs/{club}/users`).
class AdminClubUser {
  final int id;
  final String name;
  final double? level;
  final int rating;
  final bool levelVerified;
  final String? avatarUrl;

  const AdminClubUser({
    required this.id,
    required this.name,
    required this.level,
    required this.rating,
    required this.levelVerified,
    required this.avatarUrl,
  });

  factory AdminClubUser.fromJson(Map<String, dynamic> json) {
    return AdminClubUser(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      level: (json['level'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      levelVerified: json['level_verified'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class AdminClubUsersStats {
  final int l1, l2, l3, l4, l5;

  const AdminClubUsersStats({
    required this.l1,
    required this.l2,
    required this.l3,
    required this.l4,
    required this.l5,
  });

  factory AdminClubUsersStats.fromJson(Map<String, dynamic> json) {
    return AdminClubUsersStats(
      l1: (json['l1'] as num?)?.toInt() ?? 0,
      l2: (json['l2'] as num?)?.toInt() ?? 0,
      l3: (json['l3'] as num?)?.toInt() ?? 0,
      l4: (json['l4'] as num?)?.toInt() ?? 0,
      l5: (json['l5'] as num?)?.toInt() ?? 0,
    );
  }
}

class AdminClubUsersPage {
  final List<AdminClubUser> users;
  final int page;
  final int totalPages;
  final int total;
  final AdminClubUsersStats stats;

  const AdminClubUsersPage({
    required this.users,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.stats,
  });

  factory AdminClubUsersPage.fromJson(Map<String, dynamic> json) {
    return AdminClubUsersPage(
      users: ((json['users'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminClubUser.fromJson)
          .toList(),
      page: (json['page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      total: (json['total'] as num?)?.toInt() ?? 0,
      stats: AdminClubUsersStats.fromJson(
          (json['level_stats'] as Map<String, dynamic>?) ?? {}),
    );
  }
}
