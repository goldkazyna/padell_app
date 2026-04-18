class Club {
  final int id;
  final String name;
  final String? address;
  final String? city;
  final String? logo;
  final String? description;
  final String? phone;
  final int courtsCount;
  final double? minPrice;

  Club({
    required this.id,
    required this.name,
    this.address,
    this.city,
    this.logo,
    this.description,
    this.phone,
    this.courtsCount = 0,
    this.minPrice,
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
      courtsCount: json['courts_count'] as int? ?? 0,
      minPrice: (json['min_price'] as num?)?.toDouble(),
    );
  }
}
