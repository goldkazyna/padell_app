import '../models/club.dart';
import 'api_service.dart';
import 'storage_service.dart';

class ClubService {
  final ApiService _api;
  final StorageService _storage;

  ClubService(this._api, this._storage);

  Future<Club> getClub(int id) async {
    final token = await _storage.getToken();
    final response = await _api.get('/clubs/$id', token);
    final data = response['data'] ?? response['club'] ?? response;
    return Club.fromJson(data as Map<String, dynamic>);
  }
}
