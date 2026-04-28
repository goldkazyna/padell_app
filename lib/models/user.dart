class AdminClubRef {
  final int id;
  final String name;
  const AdminClubRef({required this.id, required this.name});

  factory AdminClubRef.fromJson(Map<String, dynamic> json) =>
      AdminClubRef(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
      );
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
  final bool quizCompleted;
  final String? role;
  final bool isClubAdmin;
  final List<AdminClubRef> adminClubs;

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
    this.quizCompleted = false,
    this.role,
    this.isClubAdmin = false,
    this.adminClubs = const [],
  });

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
      quizCompleted: json['quiz_completed'] as bool? ?? false,
      role: json['role'] as String?,
      isClubAdmin: json['is_club_admin'] as bool? ?? false,
      adminClubs: adminClubs,
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
