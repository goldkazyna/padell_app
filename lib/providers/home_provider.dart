import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/tournament.dart';
import '../models/home_banner.dart';
import '../services/home_service.dart';

class HomeProvider extends ChangeNotifier {
  final HomeService _homeService;

  HomeProvider(this._homeService);

  bool _isLoading = false;
  String? _error;
  User? _user;
  Tournament? _nearestTournament;
  Tournament? _activeTournament;
  List<Tournament> _upcomingTournaments = [];
  HomeBanner? _banner;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  Tournament? get nearestTournament => _nearestTournament;
  Tournament? get activeTournament => _activeTournament;
  List<Tournament> get upcomingTournaments => _upcomingTournaments;
  HomeBanner? get banner => _banner;

  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _homeService.getHomeData();

    _isLoading = false;

    if (result.success && result.data != null) {
      _user = result.data!.user;
      _nearestTournament = result.data!.nearestTournament;
      _activeTournament = result.data!.activeTournament;
      _upcomingTournaments = result.data!.upcomingTournaments;
      _banner = result.data!.banner;
      _error = null;
    } else {
      _error = result.message;
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}
