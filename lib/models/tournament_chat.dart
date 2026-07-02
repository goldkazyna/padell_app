class TournamentChat {
  final bool enabled;
  final String writeMode; // admin | participants | everyone
  final bool canRead;
  final bool canWrite;
  final bool isAdmin;
  final int unreadCount;

  const TournamentChat({
    this.enabled = false,
    this.writeMode = 'participants',
    this.canRead = false,
    this.canWrite = false,
    this.isAdmin = false,
    this.unreadCount = 0,
  });

  factory TournamentChat.fromJson(Map<String, dynamic> json) {
    return TournamentChat(
      enabled: json['enabled'] as bool? ?? false,
      writeMode: json['write_mode'] as String? ?? 'participants',
      canRead: json['can_read'] as bool? ?? false,
      canWrite: json['can_write'] as bool? ?? false,
      isAdmin: json['is_admin'] as bool? ?? false,
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
    );
  }
}
