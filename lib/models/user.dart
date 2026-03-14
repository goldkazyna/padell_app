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
  });

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

  bool get isProfileIncomplete => city == null || city!.isEmpty || gender == null || gender!.isEmpty;

  String get genderName {
    switch (gender) {
      case 'male': return 'Мужской';
      case 'female': return 'Женский';
      default: return '';
    }
  }

  factory User.fromJson(Map<String, dynamic> json) {
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
