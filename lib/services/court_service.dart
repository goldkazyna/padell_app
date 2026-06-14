import 'api_service.dart';
import 'storage_service.dart';

class CourtService {
  final ApiService _api;
  final StorageService _storage;

  CourtService(this._api, this._storage);

  Future<String?> _getToken() async {
    return await _storage.getToken();
  }

  /// Список клубов с кортами
  Future<Map<String, dynamic>> getClubs({String? city, String? search}) async {
    final token = await _getToken();
    var endpoint = '/courts/clubs';
    final params = <String>[];
    if (city != null && city.isNotEmpty) params.add('city=$city');
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await _api.get(endpoint, token);
    return response;
  }

  /// Расписание кортов клуба на дату
  Future<Map<String, dynamic>> getSchedule(int clubId, String date) async {
    final token = await _getToken();
    final response = await _api.get('/courts/clubs/$clubId/schedule?date=$date', token);
    return response;
  }

  /// Забронировать корт
  Future<Map<String, dynamic>> book({
    required int clubId,
    required int courtId,
    required String date,
    required String startTime,
    required int slots,
    String? clientName,
    String? clientPhone,
    int? coachId,
    String? comment,
    bool needsCoach = false,
  }) async {
    final token = await _getToken();
    final body = <String, dynamic>{
      'court_id': courtId,
      'date': date,
      'start_time': startTime,
      'slots': slots,
    };
    if (clientName != null && clientName.isNotEmpty) body['client_name'] = clientName;
    if (clientPhone != null && clientPhone.isNotEmpty) body['client_phone'] = clientPhone;
    if (coachId != null) body['coach_id'] = coachId;
    if (comment != null && comment.isNotEmpty) body['comment'] = comment;
    if (needsCoach) body['needs_coach'] = true;
    final response = await _api.post('/courts/clubs/$clubId/book', body, token);
    return response;
  }

  /// Создать онлайн-платёж (Plexy) для брони. Возвращает payment_url.
  Future<Map<String, dynamic>> createPayment(int bookingId) async {
    final token = await _getToken();
    final response =
        await _api.post('/courts/bookings/$bookingId/create-payment', {}, token);
    return response;
  }

  /// Статус оплаты брони (для опроса из экрана оплаты).
  Future<Map<String, dynamic>> getPaymentStatus(int bookingId) async {
    final token = await _getToken();
    return await _api.get('/courts/bookings/$bookingId/payment-status', token);
  }

  /// Мои бронирования
  Future<Map<String, dynamic>> getMyBookings() async {
    final token = await _getToken();
    final response = await _api.get('/courts/my-bookings', token);
    return response;
  }

  /// Загруженность по неделе
  Future<Map<String, dynamic>> getWeekOccupancy(int clubId, String startDate) async {
    final token = await _getToken();
    final response = await _api.get('/courts/clubs/$clubId/week-occupancy?start_date=$startDate', token);
    return response;
  }

  /// Отмена бронирования
  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    final token = await _getToken();
    final response = await _api.post('/courts/bookings/$bookingId/cancel', {}, token);
    return response;
  }
}
