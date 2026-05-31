import 'api_service.dart';
import 'storage_service.dart';

/// Данные для баннера «неоплаченный турнир с таймером».
class ModerationPending {
  final int tournamentId;
  final String name;
  final DateTime deadline;
  ModerationPending({required this.tournamentId, required this.name, required this.deadline});
}

class ModerationService {
  final ApiService _api;
  final StorageService _storage;
  ModerationService(this._api, this._storage);

  /// Ближайшая неоплаченная заявка с таймером, или null.
  Future<ModerationPending?> getPending() async {
    final token = await _storage.getToken();
    final r = await _api.get('/tournaments/moderation-pending', token);
    final p = r['pending'];
    if (p == null) return null;
    final m = p as Map<String, dynamic>;
    final dl = DateTime.tryParse(m['deadline'] as String? ?? '');
    if (dl == null) return null;
    return ModerationPending(
      tournamentId: (m['tournament_id'] as num).toInt(),
      name: m['name'] as String? ?? '',
      deadline: dl,
    );
  }
}
