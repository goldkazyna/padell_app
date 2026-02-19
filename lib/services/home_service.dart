import '../models/user.dart';
import '../models/tournament.dart';
import 'api_service.dart';
import 'storage_service.dart';

class HomeData {
  final User user;
  final Tournament? nearestTournament;
  final Tournament? activeTournament;
  final List<Tournament> upcomingTournaments;

  HomeData({
    required this.user,
    this.nearestTournament,
    this.activeTournament,
    required this.upcomingTournaments,
  });
}

class HomeResult {
  final bool success;
  final String? message;
  final HomeData? data;

  HomeResult({required this.success, this.message, this.data});
}

class HomeService {
  final ApiService _api;
  final StorageService _storage;

  HomeService(this._api, this._storage);

  Future<HomeResult> getHomeData() async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        return HomeResult(success: false, message: 'Не авторизован');
      }

      final response = await _api.get('/home', token);

      if (response['success'] != true) {
        return HomeResult(
          success: false,
          message: response['message'] as String? ?? 'Ошибка загрузки',
        );
      }

      final userData = response['user'] as Map<String, dynamic>;
      final user = User.fromJson(userData);

      Tournament? nearestTournament;
      if (response['nearest_tournament'] != null) {
        nearestTournament = Tournament.fromJson(
          response['nearest_tournament'] as Map<String, dynamic>,
        );
      }

      Tournament? activeTournament;
      if (response['active_tournament'] != null) {
        activeTournament = Tournament.fromJson(
          response['active_tournament'] as Map<String, dynamic>,
        );
      }

      final upcomingList = response['upcoming_tournaments'] as List<dynamic>? ?? [];
      final upcomingTournaments = upcomingList
          .map((t) => Tournament.fromJson(t as Map<String, dynamic>))
          .toList();

      return HomeResult(
        success: true,
        data: HomeData(
          user: user,
          nearestTournament: nearestTournament,
          activeTournament: activeTournament,
          upcomingTournaments: upcomingTournaments,
        ),
      );
    } on ApiException catch (e) {
      return HomeResult(success: false, message: e.message);
    } catch (e) {
      return HomeResult(success: false, message: 'Ошибка загрузки данных');
    }
  }
}
