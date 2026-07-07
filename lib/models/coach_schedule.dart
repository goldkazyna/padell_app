class CoachSlotBooking {
  final String? court;
  final String? client;
  final String start;
  final String end;

  const CoachSlotBooking({
    this.court,
    this.client,
    required this.start,
    required this.end,
  });

  factory CoachSlotBooking.fromJson(Map<String, dynamic> json) {
    return CoachSlotBooking(
      court: json['court'] as String?,
      client: json['client'] as String?,
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
    );
  }
}

class CoachSlot {
  final String time;
  final String status; // free | booked | blocked
  final CoachSlotBooking? booking;

  const CoachSlot({required this.time, required this.status, this.booking});

  factory CoachSlot.fromJson(Map<String, dynamic> json) {
    return CoachSlot(
      time: json['time'] as String? ?? '',
      status: json['status'] as String? ?? 'free',
      booking: json['booking'] == null
          ? null
          : CoachSlotBooking.fromJson(json['booking'] as Map<String, dynamic>),
    );
  }
}

class CoachWeekDay {
  final String date; // YYYY-MM-DD
  final String dayName; // «пн» (fallback; фронт форматирует сам по date)
  final String dayNum;
  final bool isToday;
  final bool isSelected;
  final double hours;

  const CoachWeekDay({
    required this.date,
    required this.dayName,
    required this.dayNum,
    required this.isToday,
    required this.isSelected,
    required this.hours,
  });

  factory CoachWeekDay.fromJson(Map<String, dynamic> json) {
    return CoachWeekDay(
      date: json['date'] as String? ?? '',
      dayName: json['day_name'] as String? ?? '',
      dayNum: json['day_num'] as String? ?? '',
      isToday: json['is_today'] as bool? ?? false,
      isSelected: json['is_selected'] as bool? ?? false,
      hours: (json['hours'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CoachDaySchedule {
  final String coachName;
  final String? clubName;
  final String date;
  final double busyHours;
  final List<CoachSlot> slots;
  final List<CoachWeekDay> week;

  const CoachDaySchedule({
    required this.coachName,
    this.clubName,
    required this.date,
    required this.busyHours,
    required this.slots,
    required this.week,
  });

  factory CoachDaySchedule.fromJson(Map<String, dynamic> json) {
    final coach = (json['coach'] as Map<String, dynamic>?) ?? const {};
    return CoachDaySchedule(
      coachName: coach['name'] as String? ?? '',
      clubName: coach['club_name'] as String?,
      date: json['date'] as String? ?? '',
      busyHours: (json['busy_hours'] as num?)?.toDouble() ?? 0,
      slots: (json['slots'] as List?)
              ?.map((s) => CoachSlot.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      week: (json['week'] as List?)
              ?.map((w) => CoachWeekDay.fromJson(w as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
