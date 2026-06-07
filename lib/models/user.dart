class AdminClubRef {
  final int id;
  final String name;
  final Map<String, bool> features;

  /// Только для модераторов — есть ли полные права на турниры.
  /// У club_admin всегда true (их клубы хранятся отдельно).
  final bool tournamentsFullAccess;

  const AdminClubRef({
    required this.id,
    required this.name,
    this.features = const {},
    this.tournamentsFullAccess = true,
  });

  /// hasFeature(key) — true если включена. Если ключа нет в карте,
  /// считаем включённой (на бэке тот же дефолт).
  bool hasFeature(String key) => features[key] ?? true;

  factory AdminClubRef.fromJson(Map<String, dynamic> json) {
    final raw = json['features'];
    final features = <String, bool>{};
    if (raw is Map) {
      raw.forEach((k, v) {
        if (k is String) features[k] = v == true;
      });
    }
    return AdminClubRef(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      features: features,
      // Дефолт true — для admin_clubs полей tournaments_full_access нет,
      // они и так с полным доступом.
      tournamentsFullAccess:
          json['tournaments_full_access'] as bool? ?? true,
    );
  }
}

class User {
  final int id;
  final String name;
  final String phone;
  final String? avatar;
  final int rating;
  final String level;
  final String levelName;
  final int? place;
  final String? city;
  final String? gender;
  final DateTime? birthDate;
  final String? hand;
  final String? position;
  final bool levelVerified;
  final List<String> verificationBlockers;
  final bool quizCompleted;
  final String? role;
  final bool isClubAdmin;
  final List<AdminClubRef> adminClubs;
  final bool isClubModerator;
  final List<AdminClubRef> moderatorClubs;
  final bool canCreateTournaments; // грант на создание личных турниров

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.avatar,
    required this.rating,
    required this.level,
    required this.levelName,
    this.place,
    this.city,
    this.gender,
    this.birthDate,
    this.hand,
    this.position,
    this.levelVerified = false,
    this.verificationBlockers = const [],
    this.quizCompleted = false,
    this.role,
    this.isClubAdmin = false,
    this.adminClubs = const [],
    this.isClubModerator = false,
    this.moderatorClubs = const [],
    this.canCreateTournaments = false,
  });

  /// Все клубы где у user есть админский интерфейс — admin или moderator.
  /// Для UI «Управление клубом» на главной.
  List<AdminClubRef> get manageableClubs =>
      [...adminClubs, ...moderatorClubs];

  /// Полные права на турниры в данном клубе:
  /// admin клуба или модератор с tournaments_full_access.
  bool hasTournamentsFullAccess(int clubId) {
    if (adminClubs.any((c) => c.id == clubId)) return true;
    final m = moderatorClubs.where((c) => c.id == clubId).cast<AdminClubRef?>();
    final mod = m.isEmpty ? null : m.first;
    return mod?.tournamentsFullAccess ?? false;
  }

  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int years = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      years--;
    }
    return years;
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  String get formattedPhone {
    if (phone.length == 11) {
      return '+${phone.substring(0, 1)} ${phone.substring(1, 4)} ${phone.substring(4, 7)} ${phone.substring(7, 9)} ${phone.substring(9)}';
    }
    return phone;
  }

  bool get isProfileIncomplete =>
      (city == null || city!.isEmpty) ||
      phone.trim().isEmpty;

  List<String> get missingProfileFieldKeys {
    final missing = <String>[];
    if (city == null || city!.isEmpty) missing.add('city');
    if (phone.trim().isEmpty) missing.add('phone');
    return missing;
  }

  String get genderName {
    switch (gender) {
      case 'male': return 'Мужской';
      case 'female': return 'Женский';
      default: return '';
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final adminClubsList = (json['admin_clubs'] as List?) ?? const [];
    final adminClubs = adminClubsList
        .whereType<Map<String, dynamic>>()
        .map(AdminClubRef.fromJson)
        .toList();
    final modClubsList = (json['moderator_clubs'] as List?) ?? const [];
    final moderatorClubs = modClubsList
        .whereType<Map<String, dynamic>>()
        .map(AdminClubRef.fromJson)
        .toList();

    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      level: json['level']?.toString() ?? '0',
      levelName: json['level_name'] as String? ?? '',
      place: json['place'] as int?,
      city: json['city'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.tryParse(json['birth_date'] as String)
          : null,
      hand: json['hand'] as String?,
      position: json['position'] as String?,
      levelVerified: json['level_verified'] as bool? ?? false,
      verificationBlockers: ((json['verification_blockers'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
      quizCompleted: json['quiz_completed'] as bool? ?? false,
      role: json['role'] as String?,
      isClubAdmin: json['is_club_admin'] as bool? ?? false,
      adminClubs: adminClubs,
      isClubModerator: json['is_club_moderator'] as bool? ?? false,
      moderatorClubs: moderatorClubs,
      canCreateTournaments: json['can_create_tournaments'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'rating': rating,
      'level': level,
      'level_name': levelName,
      'place': place,
    };
  }
}
