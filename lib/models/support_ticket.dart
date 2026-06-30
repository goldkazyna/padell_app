class SupportTicket {
  final int id;
  final String subject;
  final String status; // open / answered / closed
  final bool isUrgent;
  final String? category;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final List<SupportMessage> messages;

  const SupportTicket({
    required this.id,
    required this.subject,
    required this.status,
    this.isUrgent = false,
    this.category,
    this.lastMessageAt,
    this.unreadCount = 0,
    this.messages = const [],
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] as int,
      subject: json['subject'] as String? ?? '',
      status: json['status'] as String? ?? 'open',
      isUrgent: json['is_urgent'] as bool? ?? false,
      category: json['category'] as String?,
      lastMessageAt:
          DateTime.tryParse(json['last_message_at'] as String? ?? ''),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      messages: (json['messages'] as List?)
              ?.map((m) => SupportMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  bool get isClosed => status == 'closed';

  String get statusLabel {
    switch (status) {
      case 'answered':
        return 'Отвечено';
      case 'closed':
        return 'Закрыт';
      default:
        return 'Открыт';
    }
  }
}

class SupportMessage {
  final int id;
  final String authorType; // player / support
  final String body;
  final DateTime? createdAt;
  final List<String> attachments; // URLs

  const SupportMessage({
    required this.id,
    required this.authorType,
    required this.body,
    this.createdAt,
    this.attachments = const [],
  });

  bool get isSupport => authorType == 'support';

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    return SupportMessage(
      id: json['id'] as int,
      authorType: json['author_type'] as String? ?? 'player',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      attachments: (json['attachments'] as List?)
              ?.map((a) => (a as Map<String, dynamic>)['url'] as String? ?? '')
              .where((u) => u.isNotEmpty)
              .toList() ??
          const [],
    );
  }
}
