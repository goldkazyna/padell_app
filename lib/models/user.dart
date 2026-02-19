class User {
  final int id;
  final String name;
  final String firstName;
  final String lastName;
  final String phone;
  final String? avatar;
  final int rating;
  final String level;
  final String levelName;
  final int? place;

  const User({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.avatar,
    required this.rating,
    required this.level,
    required this.levelName,
    this.place,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0] : '';
    final last = lastName.isNotEmpty ? lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  String get formattedPhone {
    if (phone.length == 11) {
      return '+${phone.substring(0, 1)} ${phone.substring(1, 4)} ${phone.substring(4, 7)} ${phone.substring(7, 9)} ${phone.substring(9)}';
    }
    return phone;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      avatar: json['avatar'] as String?,
      rating: json['rating'] as int? ?? 0,
      level: json['level']?.toString() ?? '0',
      levelName: json['level_name'] as String? ?? '',
      place: json['place'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'avatar': avatar,
      'rating': rating,
      'level': level,
      'level_name': levelName,
      'place': place,
    };
  }
}
