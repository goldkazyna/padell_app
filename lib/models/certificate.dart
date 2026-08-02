import 'package:flutter/material.dart';

/// Сертификат клиента (из GET /certificates). Содержит значение, статус и
/// дизайн шаблона клуба (для рендера самого сертификата).
class Certificate {
  final int id;
  final String number;
  final String type; // named / generic
  final String? recipientName;
  final String? title;
  final String valueType; // amount / hours / tournament
  final String valueLabel; // «2 часа» / «5 000 ₸» / «1 турнир»
  final bool used;
  final DateTime? usedAt;
  final DateTime? createdAt;
  final CertificateClub club;
  final CertificateDesign design;

  const Certificate({
    required this.id,
    required this.number,
    required this.type,
    required this.recipientName,
    required this.title,
    required this.valueType,
    required this.valueLabel,
    required this.used,
    required this.usedAt,
    required this.createdAt,
    required this.club,
    required this.design,
  });

  bool get isNamed => type == 'named';

  factory Certificate.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v as String);
    return Certificate(
      id: (json['id'] as num).toInt(),
      number: json['number'] as String? ?? '',
      type: json['type'] as String? ?? 'generic',
      recipientName: json['recipient_name'] as String?,
      title: json['title'] as String?,
      valueType: json['value_type'] as String? ?? 'amount',
      valueLabel: json['value_label'] as String? ?? '',
      used: json['used'] as bool? ?? false,
      usedAt: parseDate(json['used_at']),
      createdAt: parseDate(json['created_at']),
      club: CertificateClub.fromJson(
          (json['club'] as Map<String, dynamic>?) ?? const {}),
      design: CertificateDesign.fromJson(
          (json['design'] as Map<String, dynamic>?) ?? const {}),
    );
  }
}

class CertificateClub {
  final int? id;
  final String name;
  final String? city;
  final String? logo;

  const CertificateClub({
    required this.id,
    required this.name,
    required this.city,
    required this.logo,
  });

  factory CertificateClub.fromJson(Map<String, dynamic> json) {
    return CertificateClub(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String? ?? '',
      city: json['city'] as String?,
      logo: json['logo'] as String?,
    );
  }
}

/// Поля дизайна из конструктора клуба (цвета/лого/тексты/ориентация).
class CertificateDesign {
  final String heading;
  final String subtitleNamed;
  final String subtitleGeneric;
  final String bodyText;
  final Color backgroundColor;
  final Color accentColor;
  final Color borderColor;
  final Color textColor;
  final String? logoUrl;
  final bool portrait;

  const CertificateDesign({
    required this.heading,
    required this.subtitleNamed,
    required this.subtitleGeneric,
    required this.bodyText,
    required this.backgroundColor,
    required this.accentColor,
    required this.borderColor,
    required this.textColor,
    required this.logoUrl,
    required this.portrait,
  });

  factory CertificateDesign.fromJson(Map<String, dynamic> json) {
    Color parseColor(String? hex, Color fallback) {
      if (hex == null || hex.isEmpty) return fallback;
      var h = hex.replaceAll('#', '').trim();
      if (h.length == 6) h = 'FF$h';
      final v = int.tryParse(h, radix: 16);
      return v == null ? fallback : Color(v);
    }

    return CertificateDesign(
      heading: json['heading'] as String? ?? 'Сертификат',
      subtitleNamed:
          json['subtitle_named'] as String? ?? 'Настоящий сертификат выдан',
      subtitleGeneric:
          json['subtitle_generic'] as String? ?? 'Сертификат на предъявителя',
      bodyText: json['body_text'] as String? ??
          'подтверждает право на получение услуг клуба.',
      backgroundColor:
          parseColor(json['background_color'] as String?, const Color(0xFFFBFAF6)),
      accentColor:
          parseColor(json['accent_color'] as String?, const Color(0xFFC9A24B)),
      borderColor:
          parseColor(json['border_color'] as String?, const Color(0xFF1F6B3B)),
      textColor:
          parseColor(json['text_color'] as String?, const Color(0xFF14532D)),
      logoUrl: json['logo_url'] as String?,
      portrait: (json['orientation'] as String? ?? 'portrait') == 'portrait',
    );
  }
}

/// Ответ GET /certificates.
class CertificatesResult {
  final int activeCount;
  final int usedCount;
  final List<Certificate> certificates;

  const CertificatesResult({
    required this.activeCount,
    required this.usedCount,
    required this.certificates,
  });

  factory CertificatesResult.empty() =>
      const CertificatesResult(activeCount: 0, usedCount: 0, certificates: []);

  factory CertificatesResult.fromJson(Map<String, dynamic> json) {
    final list = (json['certificates'] as List?) ?? const [];
    return CertificatesResult(
      activeCount: (json['active_count'] as num?)?.toInt() ?? 0,
      usedCount: (json['used_count'] as num?)?.toInt() ?? 0,
      certificates: list
          .map((e) => Certificate.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
