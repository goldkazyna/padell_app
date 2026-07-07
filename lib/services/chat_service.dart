import '../models/chat_message.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ChatService {
  final ApiService _api;
  final StorageService _storage;

  ChatService(this._api, this._storage);

  /// Сообщения турнира. afterId — только новее (опрос/pull-to-refresh),
  /// beforeId — история вверх. Ответ ожидается в ключе `messages`.
  Future<List<ChatMessage>> getMessages(
    int tournamentId, {
    int? afterId,
    int? beforeId,
    int limit = 50,
  }) async {
    final token = await _storage.getToken();
    final qp = <String>['limit=$limit'];
    if (afterId != null) qp.add('after_id=$afterId');
    if (beforeId != null) qp.add('before_id=$beforeId');
    final r = await _api.get(
        '/tournaments/$tournamentId/chat/messages?${qp.join('&')}', token);
    final list = (r['messages'] as List?) ?? const [];
    return list
        .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<ChatMessage> sendMessage(int tournamentId, String text) async {
    final token = await _storage.getToken();
    final r = await _api.post(
        '/tournaments/$tournamentId/chat/messages', {'text': text}, token);
    return ChatMessage.fromJson(r['message'] as Map<String, dynamic>);
  }

  Future<void> deleteMessage(int tournamentId, int messageId) async {
    final token = await _storage.getToken();
    await _api.delete(
        '/tournaments/$tournamentId/chat/messages/$messageId', null, token);
  }

  /// Лёгкий счётчик непрочитанного (для бейджа на экране турнира).
  Future<int> getUnreadCount(int tournamentId) async {
    final token = await _storage.getToken();
    final r = await _api.get(
        '/tournaments/$tournamentId/chat/unread-count', token);
    return (r['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markRead(int tournamentId, int lastMessageId) async {
    final token = await _storage.getToken();
    await _api.post('/tournaments/$tournamentId/chat/read',
        {'last_message_id': lastMessageId}, token);
  }
}
