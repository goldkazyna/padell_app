import '../models/training.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Тренировки: списки для игрока и кабинет тренера.
class TrainingService {
  final ApiService _api;
  final StorageService _storage;

  TrainingService(this._api, this._storage);

  // ===================== Игрок =====================

  /// Ближайшие тренировки, на которые открыта запись.
  Future<List<Training>> getUpcoming() async {
    final token = await _storage.getToken();
    final r = await _api.get('/trainings', token);
    return _parseList(r['trainings']);
  }

  Future<Training> getOne(int id) async {
    final token = await _storage.getToken();
    final r = await _api.get('/trainings/$id', token);
    return Training.fromJson(r['training'] as Map<String, dynamic>);
  }

  Future<void> join(int id) async {
    final token = await _storage.getToken();
    await _api.post('/trainings/$id/join', {}, token);
  }

  Future<void> leave(int id) async {
    final token = await _storage.getToken();
    await _api.post('/trainings/$id/leave', {}, token);
  }

  /// Свои записи: предстоящие и прошедшие.
  Future<({List<Training> upcoming, List<Training> past})> getMy() async {
    final token = await _storage.getToken();
    final r = await _api.get('/trainings/my', token);
    return (
      upcoming: _parseList(r['upcoming']),
      past: _parseList(r['past']),
    );
  }

  /// Числа для бейджей. Ошибку глотаем: бейдж не повод ронять экран.
  Future<TrainingCounts> getCounts() async {
    try {
      final token = await _storage.getToken();
      final r = await _api.get('/trainings/count', token);
      return TrainingCounts.fromJson(r);
    } catch (_) {
      return const TrainingCounts(upcoming: 0, available: 0);
    }
  }

  // ===================== Тренер =====================

  Future<List<Training>> getCoachTrainings() async {
    final token = await _storage.getToken();
    final r = await _api.get('/coach/trainings', token);
    return _parseList(r['trainings']);
  }

  Future<Training> getCoachTraining(int id) async {
    final token = await _storage.getToken();
    final r = await _api.get('/coach/trainings/$id', token);
    return Training.fromJson(r['training'] as Map<String, dynamic>);
  }

  /// Клубы для выбора при создании (комьюнити не приходят).
  /// [query] ищет по названию и городу.
  Future<List<TrainingClub>> getCoachClubs({String query = ''}) async {
    final token = await _storage.getToken();
    final q = Uri.encodeQueryComponent(query.trim());
    final r = await _api.get('/coach/clubs?search=$q', token);
    return ((r['clubs'] as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(TrainingClub.fromJson)
        .toList();
  }

  Future<int> create({
    required int clubId,
    required String startsAt,
    required int durationMinutes,
    required int price,
    required int capacity,
    String? description,
  }) async {
    final token = await _storage.getToken();
    final r = await _api.post('/coach/trainings', {
      'club_id': clubId,
      'starts_at': startsAt,
      'duration_minutes': durationMinutes,
      'price': price,
      'capacity': capacity,
      if (description != null && description.isNotEmpty)
        'description': description,
    }, token);
    return (r['training_id'] as num).toInt();
  }

  Future<void> complete(int id) async {
    final token = await _storage.getToken();
    await _api.post('/coach/trainings/$id/complete', {}, token);
  }

  Future<void> cancel(int id) async {
    final token = await _storage.getToken();
    await _api.post('/coach/trainings/$id/cancel', {}, token);
  }

  Future<void> removeParticipant(int trainingId, int userId) async {
    final token = await _storage.getToken();
    await _api.delete('/coach/trainings/$trainingId/participants/$userId', null, token);
  }

  List<Training> _parseList(dynamic raw) {
    return ((raw as List?) ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(Training.fromJson)
        .toList();
  }
}
