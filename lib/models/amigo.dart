/// Чем занят игрок прямо сейчас: играет, скоро турнир, ищет людей в игру.
///
/// Считает бэкенд (`App\Support\AmigoActivity`), приложение только показывает:
/// правило приоритета одно на всех и живёт в одном месте.
class AmigoStatus {
  /// playing · soon · looking · played
  final String kind;

  /// Короткое слово для бейджа: «играет», «турнир сегодня 19:00».
  final String title;

  /// Строка под именем: турнир, клуб, время.
  final String subtitle;

  final int? tournamentId;
  final int? gameId;

  /// Когда начнётся турнир или игра — время показываем своим форматом,
  /// а не строкой с сервера: у приложения три языка.
  final DateTime? startsAt;

  const AmigoStatus({
    required this.kind,
    required this.title,
    required this.subtitle,
    this.tournamentId,
    this.gameId,
    this.startsAt,
  });

  bool get isPlaying => kind == 'playing';
  bool get isSoon => kind == 'soon';
  bool get isLooking => kind == 'looking';

  /// Есть ли куда провалиться по тапу.
  bool get hasTarget => tournamentId != null || gameId != null;

  static AmigoStatus? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return AmigoStatus(
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      tournamentId: json['tournament_id'] as int?,
      gameId: json['game_id'] as int?,
      startsAt: json['at'] == null ? null : DateTime.tryParse(json['at'] as String),
    );
  }
}

/// Игрок в списке амигос.
class Amigo {
  final int id;
  final String name;
  final String? avatar;
  final double? level;
  final int rating;

  /// Добавили друг друга.
  final bool mutual;

  /// Я его добавил (на вкладке «меня добавили» бывает false).
  final bool isAmigo;

  final AmigoStatus? status;

  /// Когда он добавил меня — только на вкладке «меня добавили».
  final DateTime? addedAt;

  const Amigo({
    required this.id,
    required this.name,
    this.avatar,
    this.level,
    this.rating = 0,
    this.mutual = false,
    this.isAmigo = false,
    this.status,
    this.addedAt,
  });

  factory Amigo.fromJson(Map<String, dynamic> json) {
    return Amigo(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Игрок',
      avatar: json['avatar'] as String?,
      // Уровень с бэка приходит то числом, то строкой — как везде в проекте.
      level: json['level'] == null ? null : double.tryParse('${json['level']}'),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      mutual: json['mutual'] as bool? ?? false,
      isAmigo: json['is_amigo'] as bool? ?? false,
      status: AmigoStatus.fromJson(json['status'] as Map<String, dynamic>?),
      addedAt: json['added_at'] == null
          ? null
          : DateTime.tryParse(json['added_at'] as String),
    );
  }

  Amigo copyWith({bool? isAmigo, bool? mutual}) {
    return Amigo(
      id: id,
      name: name,
      avatar: avatar,
      level: level,
      rating: rating,
      mutual: mutual ?? this.mutual,
      isAmigo: isAmigo ?? this.isAmigo,
      status: status,
      addedAt: addedAt,
    );
  }
}

/// Кандидат в амигос: тот, с кем уже играли.
class AmigoCandidate {
  final int id;
  final String name;
  final String? avatar;
  final double? level;
  final int rating;
  final int gamesTogether;
  final int winrate;

  /// Локальное состояние: добавили прямо на этом экране.
  final bool added;

  const AmigoCandidate({
    required this.id,
    required this.name,
    this.avatar,
    this.level,
    this.rating = 0,
    this.gamesTogether = 0,
    this.winrate = 0,
    this.added = false,
  });

  factory AmigoCandidate.fromJson(Map<String, dynamic> json) {
    return AmigoCandidate(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Игрок',
      avatar: json['avatar'] as String?,
      level: json['level'] == null ? null : double.tryParse('${json['level']}'),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      gamesTogether: (json['games_together'] as num?)?.toInt() ?? 0,
      winrate: (json['winrate'] as num?)?.toInt() ?? 0,
      added: json['added'] as bool? ?? json['is_amigo'] as bool? ?? false,
    );
  }

  AmigoCandidate copyWith({bool? added}) {
    return AmigoCandidate(
      id: id,
      name: name,
      avatar: avatar,
      level: level,
      rating: rating,
      gamesTogether: gamesTogether,
      winrate: winrate,
      added: added ?? this.added,
    );
  }
}

/// Событие ленты: кто-то играет, записался, ищет людей или сыграл.
class AmigoFeedEvent {
  final int userId;
  final String playerName;
  final String? playerAvatar;
  final String kind;
  final String title;
  final String subtitle;
  final int? tournamentId;
  final int? gameId;
  final int? ratingChange;
  final DateTime? at;

  const AmigoFeedEvent({
    required this.userId,
    required this.playerName,
    this.playerAvatar,
    required this.kind,
    required this.title,
    required this.subtitle,
    this.tournamentId,
    this.gameId,
    this.ratingChange,
    this.at,
  });

  bool get isPlaying => kind == 'playing';

  factory AmigoFeedEvent.fromJson(Map<String, dynamic> json) {
    final player = json['player'] as Map<String, dynamic>? ?? const {};

    return AmigoFeedEvent(
      userId: (json['user_id'] as num?)?.toInt() ?? 0,
      playerName: player['name'] as String? ?? 'Игрок',
      playerAvatar: player['avatar'] as String?,
      kind: json['kind'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      tournamentId: json['tournament_id'] as int?,
      gameId: json['game_id'] as int?,
      ratingChange: (json['rating_change'] as num?)?.toInt(),
      at: json['at'] == null ? null : DateTime.tryParse(json['at'] as String),
    );
  }
}

/// Строка в списке переписок.
class ConversationSummary {
  final int conversationId;
  final int playerId;
  final String playerName;
  final String? playerAvatar;
  final AmigoStatus? playerStatus;
  final String? lastText;
  final bool lastIsMine;
  final DateTime? lastAt;
  final int unread;

  const ConversationSummary({
    required this.conversationId,
    required this.playerId,
    required this.playerName,
    this.playerAvatar,
    this.playerStatus,
    this.lastText,
    this.lastIsMine = false,
    this.lastAt,
    this.unread = 0,
  });

  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    final player = json['player'] as Map<String, dynamic>? ?? const {};
    final last = json['last_message'] as Map<String, dynamic>?;

    return ConversationSummary(
      conversationId: (json['conversation_id'] as num?)?.toInt() ?? 0,
      playerId: (player['id'] as num?)?.toInt() ?? 0,
      playerName: player['name'] as String? ?? 'Игрок',
      playerAvatar: player['avatar'] as String?,
      playerStatus: AmigoStatus.fromJson(player['status'] as Map<String, dynamic>?),
      lastText: last?['text'] as String?,
      lastIsMine: last?['is_mine'] as bool? ?? false,
      lastAt: last?['created_at'] == null
          ? null
          : DateTime.tryParse(last!['created_at'] as String),
      unread: (json['unread'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Сообщение в переписке.
class ChatMessage {
  final int id;
  final String text;
  final bool isMine;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
      isMine: json['is_mine'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
    );
  }
}

/// Переписка целиком: собеседник, состояние блокировки, сообщения.
class ChatThread {
  final int playerId;
  final String playerName;
  final String? playerAvatar;
  final double? playerLevel;
  final AmigoStatus? playerStatus;
  final bool isAmigo;
  final bool blockedByMe;
  final bool blockedMe;
  final bool showRules;
  final List<ChatMessage> messages;

  const ChatThread({
    required this.playerId,
    required this.playerName,
    this.playerAvatar,
    this.playerLevel,
    this.playerStatus,
    this.isAmigo = false,
    this.blockedByMe = false,
    this.blockedMe = false,
    this.showRules = false,
    this.messages = const [],
  });

  /// Писать нельзя, если блокировка есть хоть с одной стороны.
  bool get canWrite => !blockedByMe && !blockedMe;

  factory ChatThread.fromJson(Map<String, dynamic> json) {
    final player = json['player'] as Map<String, dynamic>? ?? const {};

    return ChatThread(
      playerId: (player['id'] as num?)?.toInt() ?? 0,
      playerName: player['name'] as String? ?? 'Игрок',
      playerAvatar: player['avatar'] as String?,
      playerLevel:
          player['level'] == null ? null : double.tryParse('${player['level']}'),
      playerStatus: AmigoStatus.fromJson(player['status'] as Map<String, dynamic>?),
      isAmigo: player['is_amigo'] as bool? ?? false,
      blockedByMe: json['blocked_by_me'] as bool? ?? false,
      blockedMe: json['blocked_me'] as bool? ?? false,
      showRules: json['show_rules'] as bool? ?? false,
      messages: ((json['messages'] as List<dynamic>?) ?? const [])
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  ChatThread copyWith({
    List<ChatMessage>? messages,
    bool? blockedByMe,
    bool? showRules,
    bool? isAmigo,
  }) {
    return ChatThread(
      playerId: playerId,
      playerName: playerName,
      playerAvatar: playerAvatar,
      playerLevel: playerLevel,
      playerStatus: playerStatus,
      isAmigo: isAmigo ?? this.isAmigo,
      blockedByMe: blockedByMe ?? this.blockedByMe,
      blockedMe: blockedMe,
      showRules: showRules ?? this.showRules,
      messages: messages ?? this.messages,
    );
  }
}

/// Заблокированный игрок.
class BlockedUser {
  final int id;
  final String name;
  final String? avatar;
  final DateTime? blockedAt;

  const BlockedUser({
    required this.id,
    required this.name,
    this.avatar,
    this.blockedAt,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Игрок',
      avatar: json['avatar'] as String?,
      blockedAt: json['blocked_at'] == null
          ? null
          : DateTime.tryParse(json['blocked_at'] as String),
    );
  }
}
