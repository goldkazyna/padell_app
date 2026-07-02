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
}
