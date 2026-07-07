import '../models/coach_schedule.dart';
import 'api_service.dart';
import 'storage_service.dart';

class CoachService {
  final ApiService _api;
  final StorageService _storage;

  CoachService(this._api, this._storage);

  /// Расписание тренера на день (date = YYYY-MM-DD; по умолчанию сегодня).
  Future<CoachDaySchedule> getSchedule({String? date}) async {
    final token = await _storage.getToken();
    final q = date != null ? '?date=$date' : '';
    final r = await _api.get('/coach/schedule$q', token);
    return CoachDaySchedule.fromJson(r);
  }

  /// Часы занятости по датам за диапазон (для полосок в ленте дат).
  Future<Map<String, double>> getHoursRange({
    required String from,
    required String to,
  }) async {
    final token = await _storage.getToken();
    final r = await _api.get('/coach/hours-range?from=$from&to=$to', token);
    final raw = (r['hours'] as Map?) ?? const {};
    return raw.map(
        (k, v) => MapEntry(k.toString(), (v as num?)?.toDouble() ?? 0));
  }
}
