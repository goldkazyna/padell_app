/// Компактная карточка турнира для админского списка
/// (`GET /api/mobile/admin/clubs/{club}/tournaments`).
class AdminTournamentSummary {
  final int id;
  final String name;
  final String type;
  final String typeName;
  final String date;
  final String time;
  final DateTime datetime;
  final String status;
  final String statusName;
  final double minLevel;
  final double maxLevel;
  final int maxParticipants;
  final int participantsCount;
  final int pendingCount;

  const AdminTournamentSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.typeName,
    required this.date,
    required this.time,
    required this.datetime,
    required this.status,
    required this.statusName,
    required this.minLevel,
    required this.maxLevel,
    required this.maxParticipants,
    required this.participantsCount,
    required this.pendingCount,
  });

  factory AdminTournamentSummary.fromJson(Map<String, dynamic> json) {
    return AdminTournamentSummary(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      typeName: json['type_name'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      datetime: DateTime.tryParse(json['datetime'] as String? ?? '') ??
          DateTime.now(),
      status: json['status'] as String? ?? '',
      statusName: json['status_name'] as String? ?? '',
      minLevel: (json['min_level'] as num?)?.toDouble() ?? 0,
      maxLevel: (json['max_level'] as num?)?.toDouble() ?? 0,
      maxParticipants: json['max_participants'] as int? ?? 0,
      participantsCount: json['participants_count'] as int? ?? 0,
      pendingCount: json['pending_count'] as int? ?? 0,
    );
  }
}
