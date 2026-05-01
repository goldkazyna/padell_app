import '../models/admin_tournament_detail.dart';
import '../models/admin_tournament_summary.dart';
import 'api_service.dart';
import 'storage_service.dart';

/// Сервис для админских функций мобилы.
class AdminService {
  final ApiService _api;
  final StorageService _storage;

  AdminService(this._api, this._storage);

  /// Список турниров клуба со всеми статусами для админа.
  Future<List<AdminTournamentSummary>> getClubTournaments(int clubId) async {
    final token = await _storage.getToken();
    final response = await _api.get(
      '/admin/clubs/$clubId/tournaments',
      token,
    );
    final list = (response['tournaments'] as List?) ?? const [];
    return list
        .map((j) => AdminTournamentSummary.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Полные детали турнира для админа.
  Future<AdminTournamentDetail> getTournamentDetail(int id) async {
    final token = await _storage.getToken();
    final response = await _api.get('/admin/tournaments/$id', token);
    return AdminTournamentDetail.fromJson(
      response['tournament'] as Map<String, dynamic>,
    );
  }

  /// Обновить редактируемые поля турнира.
  Future<AdminTournamentDetail> updateTournament(
    int id, {
    required String name,
    String? description,
    required DateTime startDate,
    required double minLevel,
    required double maxLevel,
    required int maxParticipants,
    double? price,
  }) async {
    final token = await _storage.getToken();
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'min_level': minLevel,
      'max_level': maxLevel,
      'max_participants': maxParticipants,
      'price': price,
    };
    final response = await _api.put('/admin/tournaments/$id', body, token);
    return AdminTournamentDetail.fromJson(
      response['tournament'] as Map<String, dynamic>,
    );
  }

  /// Запустить турнир (`status: open` → `in_progress`).
  Future<AdminTournamentDetail> startTournament(int id) async {
    final token = await _storage.getToken();
    final response = await _api.post(
      '/admin/tournaments/$id/start',
      const {},
      token,
    );
    return AdminTournamentDetail.fromJson(
      response['tournament'] as Map<String, dynamic>,
    );
  }

  /// Удалить турнир (только черновик).
  Future<void> deleteTournament(int id) async {
    final token = await _storage.getToken();
    await _api.delete('/admin/tournaments/$id', null, token);
  }
}
