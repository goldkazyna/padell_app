class ClubCoach {
  final int id;
  final String name;
  final String? specialization;
  final String photo;

  ClubCoach({
    required this.id,
    required this.name,
    this.specialization,
    required this.photo,
  });

  factory ClubCoach.fromJson(Map<String, dynamic> json) {
    return ClubCoach(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      specialization: json['specialization'] as String?,
      photo: json['photo'] as String? ?? '',
    );
  }
}

class Club {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? logo;
  final String? description;
  final String? phone;
  final String? telegramUrl;
  final String? instagramUrl;
  final int courtsCount;
  final double? minPrice;
  final bool isHidden;
  final String? cover;
  final bool isCommunity;
  final bool comingSoon;
  final int openTournamentsCount;
  final bool onlinePaymentEnabled;
  final bool allowBookingWithoutPayment;
  final String? offerAgreementUrl;
  final String? privacyPolicyUrl;
  final String? goodsDescriptionUrl;
  final String? cardPaymentDescriptionUrl;
  final List<ClubCoach> coaches;

  Club({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.logo,
    this.description,
    this.phone,
    this.telegramUrl,
    this.instagramUrl,
    this.courtsCount = 0,
    this.minPrice,
    this.isHidden = false,
    this.cover,
    this.isCommunity = false,
    this.comingSoon = false,
    this.openTournamentsCount = 0,
    this.onlinePaymentEnabled = false,
    this.allowBookingWithoutPayment = true,
    this.offerAgreementUrl,
    this.privacyPolicyUrl,
    this.goodsDescriptionUrl,
    this.cardPaymentDescriptionUrl,
    this.coaches = const [],
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      // null id у личного турнира (club_id null) — не роняем парсинг.
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      city: json['city'] as String?,
      logo: json['logo'] as String?,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      telegramUrl: json['telegram_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
      courtsCount: json['courts_count'] as int? ?? 0,
      minPrice: (json['min_price'] as num?)?.toDouble(),
      isHidden: json['is_hidden'] as bool? ?? false,
      cover: json['cover'] as String?,
      isCommunity: json['is_community'] as bool? ?? false,
      comingSoon: json['coming_soon'] as bool? ?? false,
      openTournamentsCount: json['open_tournaments_count'] as int? ?? 0,
      onlinePaymentEnabled: json['online_payment_enabled'] as bool? ?? false,
      allowBookingWithoutPayment:
          json['allow_booking_without_payment'] as bool? ?? true,
      offerAgreementUrl: json['offer_agreement_url'] as String?,
      privacyPolicyUrl: json['privacy_policy_url'] as String?,
      goodsDescriptionUrl: json['goods_description_url'] as String?,
      cardPaymentDescriptionUrl: json['card_payment_description_url'] as String?,
      coaches: (json['coaches'] as List?)
              ?.map((e) => ClubCoach.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Club copyWith({
    bool? isHidden,
    String? cover,
    bool? isCommunity,
    int? openTournamentsCount,
  }) => Club(
    id: id,
    name: name,
    address: address,
    city: city,
    logo: logo,
    description: description,
    phone: phone,
    telegramUrl: telegramUrl,
    instagramUrl: instagramUrl,
    courtsCount: courtsCount,
    minPrice: minPrice,
    isHidden: isHidden ?? this.isHidden,
    cover: cover ?? this.cover,
    isCommunity: isCommunity ?? this.isCommunity,
    comingSoon: comingSoon,
    openTournamentsCount: openTournamentsCount ?? this.openTournamentsCount,
    onlinePaymentEnabled: onlinePaymentEnabled,
    allowBookingWithoutPayment: allowBookingWithoutPayment,
    offerAgreementUrl: offerAgreementUrl,
    privacyPolicyUrl: privacyPolicyUrl,
    goodsDescriptionUrl: goodsDescriptionUrl,
    cardPaymentDescriptionUrl: cardPaymentDescriptionUrl,
    coaches: coaches,
  );
}
