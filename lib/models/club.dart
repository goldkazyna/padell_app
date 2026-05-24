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
  final int openTournamentsCount;
  final bool onlinePaymentEnabled;
  final String? offerAgreementUrl;
  final String? privacyPolicyUrl;
  final String? goodsDescriptionUrl;
  final String? cardPaymentDescriptionUrl;

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
    this.openTournamentsCount = 0,
    this.onlinePaymentEnabled = false,
    this.offerAgreementUrl,
    this.privacyPolicyUrl,
    this.goodsDescriptionUrl,
    this.cardPaymentDescriptionUrl,
  });

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(
      id: json['id'] as int,
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
      openTournamentsCount: json['open_tournaments_count'] as int? ?? 0,
      onlinePaymentEnabled: json['online_payment_enabled'] as bool? ?? false,
      offerAgreementUrl: json['offer_agreement_url'] as String?,
      privacyPolicyUrl: json['privacy_policy_url'] as String?,
      goodsDescriptionUrl: json['goods_description_url'] as String?,
      cardPaymentDescriptionUrl: json['card_payment_description_url'] as String?,
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
    openTournamentsCount: openTournamentsCount ?? this.openTournamentsCount,
    onlinePaymentEnabled: onlinePaymentEnabled,
    offerAgreementUrl: offerAgreementUrl,
    privacyPolicyUrl: privacyPolicyUrl,
    goodsDescriptionUrl: goodsDescriptionUrl,
    cardPaymentDescriptionUrl: cardPaymentDescriptionUrl,
  );
}
