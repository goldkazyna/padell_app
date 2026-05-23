class AdminClubEdit {
  final int id;
  final String name;
  final String address;
  final String? city;
  final String? phone;
  final String? email;
  final String? description;
  final String? paymentUrl;
  final String? telegramUrl;
  final String? instagramUrl;

  AdminClubEdit({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.phone,
    this.email,
    this.description,
    this.paymentUrl,
    this.telegramUrl,
    this.instagramUrl,
  });

  factory AdminClubEdit.fromJson(Map<String, dynamic> json) {
    return AdminClubEdit(
      id: json['id'] as int,
      name: (json['name'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      city: json['city'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      paymentUrl: json['payment_url'] as String?,
      telegramUrl: json['telegram_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
    );
  }
}
