/// Модели клубных карт (только чтение в приложении).

class ClubCardClubBrief {
  final int id;
  final String name;
  final String? logo;
  final String? address;
  final String? cardBgColor; // HEX #RRGGBB, null = дефолт
  final String? cardAccentColor;
  final String? cardProgressColor;

  const ClubCardClubBrief({
    required this.id,
    required this.name,
    this.logo,
    this.address,
    this.cardBgColor,
    this.cardAccentColor,
    this.cardProgressColor,
  });

  factory ClubCardClubBrief.fromJson(Map<String, dynamic> j) => ClubCardClubBrief(
        id: (j['id'] as num?)?.toInt() ?? 0,
        name: j['name'] as String? ?? '',
        logo: j['logo'] as String?,
        address: j['address'] as String?,
        cardBgColor: j['card_bg_color'] as String?,
        cardAccentColor: j['card_accent_color'] as String?,
        cardProgressColor: j['card_progress_color'] as String?,
      );
}

class ClubCard {
  final int id;
  final String code;
  final String? typeName;
  final String? kind; // visits / trainer / discount_court / discount_trainer
  final String? kindName;
  final bool isCounter;
  final int? balance;
  final int? initialBalance;
  final int? discountPercent;
  final String? expiresAt; // yyyy-MM-dd
  final bool isExpired;
  final bool isActual;
  final String status;
  final ClubCardClubBrief? club;

  const ClubCard({
    required this.id,
    required this.code,
    this.typeName,
    this.kind,
    this.kindName,
    this.isCounter = false,
    this.balance,
    this.initialBalance,
    this.discountPercent,
    this.expiresAt,
    this.isExpired = false,
    this.isActual = false,
    this.status = 'active',
    this.club,
  });

  bool get isDiscount =>
      kind == 'discount_court' || kind == 'discount_trainer';

  factory ClubCard.fromJson(Map<String, dynamic> j) => ClubCard(
        id: (j['id'] as num?)?.toInt() ?? 0,
        code: j['code'] as String? ?? '',
        typeName: j['type_name'] as String?,
        kind: j['kind'] as String?,
        kindName: j['kind_name'] as String?,
        isCounter: j['is_counter'] as bool? ?? false,
        balance: (j['balance'] as num?)?.toInt(),
        initialBalance: (j['initial_balance'] as num?)?.toInt(),
        discountPercent: (j['discount_percent'] as num?)?.toInt(),
        expiresAt: j['expires_at'] as String?,
        isExpired: j['is_expired'] as bool? ?? false,
        isActual: j['is_actual'] as bool? ?? false,
        status: j['status'] as String? ?? 'active',
        club: j['club'] != null
            ? ClubCardClubBrief.fromJson(j['club'] as Map<String, dynamic>)
            : null,
      );
}

class ClubCardsGroup {
  final ClubCardClubBrief club;
  final int activeCount;
  final int totalCount;
  final List<ClubCard> cards;

  const ClubCardsGroup({
    required this.club,
    required this.activeCount,
    required this.totalCount,
    required this.cards,
  });

  List<ClubCard> get activeCards =>
      cards.where((c) => c.isActual).toList();
  List<ClubCard> get archivedCards =>
      cards.where((c) => !c.isActual).toList();

  factory ClubCardsGroup.fromJson(Map<String, dynamic> j) => ClubCardsGroup(
        club: ClubCardClubBrief.fromJson(
            (j['club'] as Map<String, dynamic>?) ?? const {}),
        activeCount: (j['active_count'] as num?)?.toInt() ?? 0,
        totalCount: (j['total_count'] as num?)?.toInt() ?? 0,
        cards: ((j['cards'] as List?) ?? const [])
            .map((c) => ClubCard.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

class ClubCardTransaction {
  final int id;
  final int amount; // сколько списано
  final int? balanceAfter;
  final String? note;
  final bool hasBooking;
  final String? createdAt; // ISO8601

  const ClubCardTransaction({
    required this.id,
    required this.amount,
    this.balanceAfter,
    this.note,
    this.hasBooking = false,
    this.createdAt,
  });

  factory ClubCardTransaction.fromJson(Map<String, dynamic> j) =>
      ClubCardTransaction(
        id: (j['id'] as num?)?.toInt() ?? 0,
        amount: (j['amount'] as num?)?.toInt() ?? 0,
        balanceAfter: (j['balance_after'] as num?)?.toInt(),
        note: j['note'] as String?,
        hasBooking: j['has_booking'] as bool? ?? false,
        createdAt: j['created_at'] as String?,
      );
}

class ClubCardDetail {
  final ClubCard card;
  final List<ClubCardTransaction> transactions;

  const ClubCardDetail({required this.card, required this.transactions});

  factory ClubCardDetail.fromJson(Map<String, dynamic> j) => ClubCardDetail(
        card: ClubCard.fromJson((j['card'] as Map<String, dynamic>?) ?? const {}),
        transactions: ((j['transactions'] as List?) ?? const [])
            .map((t) => ClubCardTransaction.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

class ClubCardBooking {
  final int id;
  final String? date; // yyyy-MM-dd
  final String? startTime; // HH:mm
  final String? endTime;
  final String? courtName;
  final String? clubName;
  final String status;
  final bool canCancel;
  final int cancelMinHours;

  const ClubCardBooking({
    required this.id,
    this.date,
    this.startTime,
    this.endTime,
    this.courtName,
    this.clubName,
    this.status = 'confirmed',
    this.canCancel = false,
    this.cancelMinHours = 0,
  });

  factory ClubCardBooking.fromJson(Map<String, dynamic> j) => ClubCardBooking(
        id: (j['id'] as num?)?.toInt() ?? 0,
        date: j['date'] as String?,
        startTime: j['start_time'] as String?,
        endTime: j['end_time'] as String?,
        courtName: j['court_name'] as String?,
        clubName: j['club_name'] as String?,
        status: j['status'] as String? ?? 'confirmed',
        canCancel: j['can_cancel'] as bool? ?? false,
        cancelMinHours: (j['cancel_min_hours'] as num?)?.toInt() ?? 0,
      );
}
