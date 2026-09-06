import '../models/amigo.dart';
import 'api_service.dart';

/// Амигос: связи, активность, переписка, блокировки.
///
/// Разбор ответов держим здесь, чтобы экраны работали с моделями, а не с
/// сырыми Map — как в остальных сервисах приложения.
class AmigoService {
  final ApiService _api;

  AmigoService(this._api);

  // ===== связи =====

  /// Мои амигос со статусами. Сортировка приходит с сервера: сначала те,
  /// кто на корте.
  Future<({List<Amigo> items, int count, int playingCount})> getAmigos(
    String token,
  ) async {
    final response = await _api.get('/amigos', token);
    final list = (response['amigos'] as List<dynamic>?) ?? const [];

    return (
      items: list
          .map((json) => Amigo.fromJson(json as Map<String, dynamic>))
          .toList(),
      count: (response['count'] as num?)?.toInt() ?? 0,
      playingCount: (response['playing_count'] as num?)?.toInt() ?? 0,
    );
  }

  /// Кто добавил меня.
  Future<List<Amigo>> getFollowers(String token) async {
    final response = await _api.get('/amigos/followers', token);
    final list = (response['followers'] as List<dynamic>?) ?? const [];

    return list
        .map((json) => Amigo.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// С кем уже играли, но ещё не добавили, — лечит пустой экран на старте.
  Future<List<AmigoCandidate>> getCandidates(String token) async {
    final response = await _api.get('/amigos/candidates', token);
    final list = (response['candidates'] as List<dynamic>?) ?? const [];

    return list
        .map((json) => AmigoCandidate.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Поиск игроков по имени — чтобы добавить не только тех, с кем уже играли.
  Future<List<AmigoCandidate>> search(String query, String token) async {
    final response = await _api.get(
      '/amigos/search?q=${Uri.encodeQueryComponent(query)}',
      token,
    );
    final list = (response['players'] as List<dynamic>?) ?? const [];

    return list
        .map((json) => AmigoCandidate.fromJson({
              ...json as Map<String, dynamic>,
              // Уже добавленных показываем сразу отмеченными.
              'added': (json)['is_amigo'] ?? false,
            }))
        .toList();
  }

  Future<List<AmigoFeedEvent>> getFeed(String token) async {
    final response = await _api.get('/amigos/feed', token);
    final list = (response['events'] as List<dynamic>?) ?? const [];

    return list
        .map((json) => AmigoFeedEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Добавить. Возвращает, стало ли взаимно.
  Future<bool> follow(int userId, String token) async {
    final response = await _api.post('/amigos/$userId', const {}, token);

    return response['mutual'] as bool? ?? false;
  }

  Future<void> unfollow(int userId, String token) async {
    await _api.delete('/amigos/$userId', null, token);
  }

  // ===== переписка =====

  Future<List<ConversationSummary>> getConversations(String token) async {
    final response = await _api.get('/messages', token);
    final list = (response['conversations'] as List<dynamic>?) ?? const [];

    return list
        .map((json) => ConversationSummary.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount(String token) async {
    final response = await _api.get('/messages/unread-count', token);

    return (response['count'] as num?)?.toInt() ?? 0;
  }

  /// Переписка с игроком. [afterId] — догрузить только новые сообщения.
  Future<ChatThread> getThread(int userId, String token, {int? afterId}) async {
    final suffix = afterId == null ? '' : '?after_id=$afterId';
    final response = await _api.get('/messages/$userId$suffix', token);

    return ChatThread.fromJson(response);
  }

  Future<ChatMessage> sendMessage(int userId, String text, String token) async {
    final response = await _api.post('/messages/$userId', {'text': text}, token);

    return ChatMessage.fromJson(response['message'] as Map<String, dynamic>);
  }

  Future<int> markRead(int userId, String token) async {
    final response = await _api.post('/messages/$userId/read', const {}, token);

    return (response['unread_total'] as num?)?.toInt() ?? 0;
  }

  Future<void> deleteMessage(int messageId, String token) async {
    await _api.delete('/messages/message/$messageId', null, token);
  }

  // ===== блокировки и жалобы =====

  Future<List<BlockedUser>> getBlocked(String token) async {
    final response = await _api.get('/blocks', token);
    final list = (response['blocked'] as List<dynamic>?) ?? const [];

    return list
        .map((json) => BlockedUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> block(int userId, String token) async {
    await _api.post('/users/$userId/block', const {}, token);
  }

  Future<void> unblock(int userId, String token) async {
    await _api.delete('/users/$userId/block', null, token);
  }

  Future<void> report(
    int userId,
    String reason,
    String token, {
    String? comment,
  }) async {
    await _api.post(
      '/reports',
      {
        'user_id': userId,
        'reason': reason,
        if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
      },
      token,
    );
  }
}
