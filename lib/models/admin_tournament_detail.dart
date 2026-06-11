/// Полная карточка турнира для админского экрана управления
/// (`GET /api/mobile/admin/tournaments/{id}`).
class AdminTournamentDetail {
  final int id;
  final String name;
  final String? description;
  final String type;
  final String typeName;
  final String status;
  final String statusName;
  final AdminClubBrief? club;
  final DateTime? startDate;
  final double minLevel;
  final double maxLevel;
  final int maxParticipants;
  final int participantsCount;
  final int pendingCount;
  final double? price;
  final bool verifiedOnly;
  final bool hasPlayoff;
  final bool hasLowerBracket;
  final bool hasBronzeMatch;
  final List<String> courts;
  final bool canEdit;
  final bool canStart;
  final bool canRestart;
  final bool canDelete;
  final bool baliPairsCreated;
  final bool tournamentsFullAccess;
  final bool isAdminPairing;
  final bool isPersonal; // личный турнир игрока (без клуба)
  final String? creatorName; // организатор личного турнира

  const AdminTournamentDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.typeName,
    required this.status,
    required this.statusName,
    required this.club,
    required this.startDate,
    required this.minLevel,
    required this.maxLevel,
    required this.maxParticipants,
    required this.participantsCount,
    required this.pendingCount,
    required this.price,
    this.verifiedOnly = false,
    required this.hasPlayoff,
    required this.hasLowerBracket,
    required this.hasBronzeMatch,
    required this.courts,
    required this.canEdit,
    required this.canStart,
    required this.canRestart,
    required this.canDelete,
    this.baliPairsCreated = false,
    this.tournamentsFullAccess = true,
    this.isAdminPairing = false,
    this.isPersonal = false,
    this.creatorName,
  });

  factory AdminTournamentDetail.fromJson(Map<String, dynamic> json) {
    return AdminTournamentDetail(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      type: json['type'] as String? ?? '',
      typeName: json['type_name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusName: json['status_name'] as String? ?? '',
      club: json['club'] is Map<String, dynamic>
          ? AdminClubBrief.fromJson(json['club'] as Map<String, dynamic>)
          : null,
      startDate: DateTime.tryParse(json['start_date'] as String? ?? ''),
      minLevel: (json['min_level'] as num?)?.toDouble() ?? 0,
      maxLevel: (json['max_level'] as num?)?.toDouble() ?? 0,
      maxParticipants: (json['max_participants'] as num?)?.toInt() ?? 0,
      participantsCount: (json['participants_count'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pending_count'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble(),
      verifiedOnly: json['verified_only'] as bool? ?? false,
      isAdminPairing: json['is_admin_pairing'] as bool? ?? false,
      isPersonal: json['is_personal'] as bool? ?? false,
      creatorName: (json['creator'] as Map<String, dynamic>?)?['name'] as String?,
      hasPlayoff: json['has_playoff'] as bool? ?? false,
      hasLowerBracket: json['has_lower_bracket'] as bool? ?? false,
      hasBronzeMatch: json['has_bronze_match'] as bool? ?? false,
      courts: (json['courts'] as List?)
              ?.map((c) => c?.toString() ?? '')
              .where((c) => c.isNotEmpty)
              .toList() ??
          const [],
      canEdit: json['can_edit'] as bool? ?? false,
      canStart: json['can_start'] as bool? ?? false,
      canRestart: json['can_restart'] as bool? ?? false,
      canDelete: json['can_delete'] as bool? ?? false,
      baliPairsCreated: json['bali_pairs_created'] as bool? ?? false,
      tournamentsFullAccess:
          json['tournaments_full_access'] as bool? ?? true,
    );
  }
}

class AdminClubBrief {
  final int id;
  final String name;

  const AdminClubBrief({required this.id, required this.name});

  factory AdminClubBrief.fromJson(Map<String, dynamic> json) {
    return AdminClubBrief(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}
