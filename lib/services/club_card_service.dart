import '../models/club_card.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Клубные карты (только чтение). Связка user↔клиент клуба — на бэкенде по телефону.
class ClubCardService {
  final ApiService _api;
  final StorageService _storage;

  ClubCardService(this._api, this._storage);

  /// Карты пользователя, сгруппированные по клубам.
  Future<List<ClubCardsGroup>> getClubCards() async {
    final token = await _storage.getToken();
    if (token == null) return [];
    final response = await _api.get('/club-cards', token);
    final clubs = (response['clubs'] as List?) ?? const [];
    return clubs
        .map((c) => ClubCardsGroup.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// Детали карты + история операций.
  Future<ClubCardDetail> getCardDetail(int cardId) async {
    final token = await _storage.getToken();
    if (token == null) {
      throw ApiException('Не авторизован');
    }
    final response = await _api.get('/club-cards/$cardId', token);
    return ClubCardDetail.fromJson(response);
  }

  /// Будущие брони, оплаченные этой картой.
  Future<List<ClubCardBooking>> getCardBookings(int cardId) async {
    final token = await _storage.getToken();
    if (token == null) return [];
    final response = await _api.get('/club-cards/$cardId/bookings', token);
    final list = (response['bookings'] as List?) ?? const [];
    return list
        .map((b) => ClubCardBooking.fromJson(b as Map<String, dynamic>))
        .toList();
  }
}
