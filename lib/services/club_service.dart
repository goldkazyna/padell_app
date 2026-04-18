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

  Future<List<Club>> getClubs({String? search, String? city}) async {
    final token = await _storage.getToken();
    var endpoint = '/clubs';
    final params = <String>[];
    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(search)}');
    }
    if (city != null && city.isNotEmpty) {
      params.add('city=${Uri.encodeQueryComponent(city)}');
    }
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await _api.get(endpoint, token);
    final list = response['clubs'] ?? response['data'] ?? [];
    return (list as List)
        .map((e) => Club.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
