import '../models/support_ticket.dart';
import 'api_service.dart';
import 'storage_service.dart';

class SupportService {
  final ApiService _api;
  final StorageService _storage;

  SupportService(this._api, this._storage);

  /// Список тикетов игрока.
  Future<List<SupportTicket>> getTickets() async {
    final token = await _storage.getToken();
    final r = await _api.get('/support/tickets', token);
    final list = (r['tickets'] as List?) ?? const [];
    return list
        .map((t) => SupportTicket.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Детали тикета (с сообщениями). Помечает ответы поддержки прочитанными.
  Future<SupportTicket> getTicket(int id) async {
    final token = await _storage.getToken();
    final r = await _api.get('/support/tickets/$id', token);
    return SupportTicket.fromJson(r['ticket'] as Map<String, dynamic>);
  }

  /// Создать тикет: тема + текст + фото (пути к файлам).
  Future<SupportTicket> createTicket({
    required String subject,
    required String body,
    String? category,
    List<String> photoPaths = const [],
  }) async {
    final token = await _storage.getToken();
    final r = await _api.multipartPostMulti(
      '/support/tickets',
      {
        'subject': subject,
        'body': body,
        'category': ?category,
      },
      photoPaths,
      'photos[]',
      token,
    );
    return SupportTicket.fromJson(r['ticket'] as Map<String, dynamic>);
  }

  /// Дописать сообщение в тикет (+фото).
  Future<SupportTicket> addMessage({
    required int ticketId,
    required String body,
    List<String> photoPaths = const [],
  }) async {
    final token = await _storage.getToken();
    final r = await _api.multipartPostMulti(
      '/support/tickets/$ticketId/messages',
      {'body': body},
      photoPaths,
      'photos[]',
      token,
    );
    return SupportTicket.fromJson(r['ticket'] as Map<String, dynamic>);
  }

  /// Кол-во непрочитанных ответов поддержки (для бейджа).
  Future<int> getUnreadCount() async {
    final token = await _storage.getToken();
    final r = await _api.get('/support/unread-count', token);
    return (r['count'] as num?)?.toInt() ?? 0;
  }
}
