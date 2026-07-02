class ChatUser {
  final int id;
  final String name;
  final String? avatar;
  final String? level;

  const ChatUser({required this.id, required this.name, this.avatar, this.level});

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      avatar: json['avatar'] as String?,
      level: json['level']?.toString(),
    );
  }

  /// Инициалы для аватара-заглушки (первые буквы двух слов ФИО).
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Короткая метка уровня для бейджа: "3.50" → "3.5", "4.00" → "4.0".
  String? get levelLabel {
    final raw = level;
    if (raw == null || raw.isEmpty) return null;
    return double.tryParse(raw)?.toString() ?? raw;
  }
}

class ChatMessage {
  final int id;
  final ChatUser user;
  final String text;
  final bool isAdmin;
  final bool isMine;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.user,
    required this.text,
    this.isAdmin = false,
    this.isMine = false,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      user: ChatUser.fromJson(
          (json['user'] as Map<String, dynamic>?) ?? const {}),
      text: json['text'] as String? ?? '',
      isAdmin: json['is_admin'] as bool? ?? false,
      isMine: json['is_mine'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  /// Время сообщения в локальной зоне, формат HH:mm (для подписи под пузырём).
  String get timeLabel {
    final d = createdAt?.toLocal();
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
