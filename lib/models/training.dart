/// Тренировка: занятие тренера, на которое записываются игроки.
class Training {
  final int id;
  final TrainingClub club;
  final TrainingPerson? coach;

  /// Начало в формате «YYYY-MM-DD HH:MM» — настенное время клуба.
  final String startsAt;

  /// Готовые к показу «10 августа» и «19:00» — считает сервер.
  final String date;
  final String time;

  final int durationMinutes;
  final int price;
  final int capacity;
  final int participantsCount;
  final int freeSlots;
  final String? description;

  /// planned / completed / cancelled
  final String status;

  final bool isJoined;
  final bool canJoin;

  /// Только в кабинете тренера.
  final bool canComplete;
  final bool canCancel;
  final bool isPast;
  final List<TrainingParticipant> participants;

  const Training({
    required this.id,
    required this.club,
    required this.coach,
    required this.startsAt,
    required this.date,
    required this.time,
    required this.durationMinutes,
    required this.price,
    required this.capacity,
    required this.participantsCount,
    required this.freeSlots,
    required this.description,
    required this.status,
    this.isJoined = false,
    this.canJoin = false,
    this.canComplete = false,
    this.canCancel = false,
    this.isPast = false,
    this.participants = const [],
  });

  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';

  /// Цена для показа: «20 000 ₸» или «Бесплатно».
  /// Тысячи разделяем пробелом — тот же формат, что в выборе клуба.
  String get priceLabel {
    if (price <= 0) return 'Бесплатно';
    final digits = price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+$)'),
          (m) => '${m[1]} ',
        );
    return '$digits ₸';
  }

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: (json['id'] as num).toInt(),
      club: TrainingClub.fromJson(
          (json['club'] as Map<String, dynamic>?) ?? const {}),
      coach: json['coach'] is Map<String, dynamic>
          ? TrainingPerson.fromJson(json['coach'] as Map<String, dynamic>)
          : null,
      startsAt: json['starts_at'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 60,
      price: (json['price'] as num?)?.toInt() ?? 0,
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      participantsCount: (json['participants_count'] as num?)?.toInt() ?? 0,
      freeSlots: (json['free_slots'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'planned',
      isJoined: json['is_joined'] as bool? ?? false,
      canJoin: json['can_join'] as bool? ?? false,
      canComplete: json['can_complete'] as bool? ?? false,
      canCancel: json['can_cancel'] as bool? ?? false,
      isPast: json['is_past'] as bool? ?? false,
      participants: ((json['participants'] as List?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TrainingParticipant.fromJson)
          .toList(),
    );
  }
}

class TrainingClub {
  final int? id;
  final String name;
  final String? city;

  const TrainingClub({this.id, required this.name, this.city});

  factory TrainingClub.fromJson(Map<String, dynamic> json) => TrainingClub(
        id: (json['id'] as num?)?.toInt(),
        name: json['name'] as String? ?? '',
        city: json['city'] as String?,
      );
}

class TrainingPerson {
  final int? id;
  final String name;
  final String? avatar;

  const TrainingPerson({this.id, required this.name, this.avatar});

  factory TrainingPerson.fromJson(Map<String, dynamic> json) => TrainingPerson(
        id: (json['id'] as num?)?.toInt(),
        name: json['name'] as String? ?? '',
        avatar: json['avatar'] as String?,
      );
}

/// Записавшийся игрок. Телефон приходит только тренеру — для звонка и WhatsApp.
class TrainingParticipant {
  final int id;
  final String name;

  /// Приходит только тренеру — для звонка и WhatsApp.
  final String? phone;
  final String? avatar;
  final int rating;

  /// Это место текущего игрока: подсвечиваем кружок.
  final bool isMe;

  const TrainingParticipant({
    required this.id,
    required this.name,
    this.phone,
    this.avatar,
    this.rating = 0,
    this.isMe = false,
  });

  factory TrainingParticipant.fromJson(Map<String, dynamic> json) =>
      TrainingParticipant(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String?,
        avatar: json['avatar'] as String?,
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        isMe: json['is_me'] as bool? ?? false,
      );
}

/// Счётчики для бейджей: на плитке главной и на кнопке в профиле.
class TrainingCounts {
  final int upcoming;
  final int available;

  const TrainingCounts({required this.upcoming, required this.available});

  factory TrainingCounts.fromJson(Map<String, dynamic> json) => TrainingCounts(
        upcoming: (json['upcoming'] as num?)?.toInt() ?? 0,
        available: (json['available'] as num?)?.toInt() ?? 0,
      );
}
