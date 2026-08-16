/// Отказ от ответственности клуба и состояние подписи текущего игрока.
class ClubWaiver {
  final bool collects;
  final String clubName;
  final String? text;

  /// Контрольная сумма текста — возвращается при подписи, чтобы сервер
  /// понял, ту ли редакцию человек читал.
  final String? textHash;

  final DateTime? signedAt;
  final String? fullName;

  /// Текст, который человек подписал. Может отличаться от текущего:
  /// клуб мог поправить его после подписи.
  final String? signedText;

  const ClubWaiver({
    required this.collects,
    required this.clubName,
    this.text,
    this.textHash,
    this.signedAt,
    this.fullName,
    this.signedText,
  });

  bool get isSigned => signedAt != null;

  factory ClubWaiver.fromJson(Map<String, dynamic> json) {
    final signed = json['signed_at'] as String?;
    return ClubWaiver(
      collects: json['collects'] as bool? ?? false,
      clubName: json['club_name'] as String? ?? '',
      text: json['text'] as String?,
      textHash: json['text_hash'] as String?,
      signedAt: signed == null ? null : DateTime.tryParse(signed)?.toLocal(),
      fullName: json['full_name'] as String?,
      signedText: json['signed_text'] as String?,
    );
  }
}
