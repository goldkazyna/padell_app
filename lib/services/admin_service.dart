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
}
