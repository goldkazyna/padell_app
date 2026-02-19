import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/match.dart';
import '../models/tournament.dart';
import '../services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;

  ProfileProvider(this._profileService);

  bool _isLoading = false;
  String? _error;
  User? _user;
  ProfileStatistics? _statistics;

  List<Tournament> _tournamentHistory = [];
  bool _isLoadingHistory = false;

  List<Match> _matches = [];
  bool _isLoadingMatches = false;
  int _matchesPage = 1;
  int _matchesLastPage = 1;
  bool get hasMoreMatches => _matchesPage < _matchesLastPage;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  ProfileStatistics? get statistics => _statistics;
  List<Tournament> get tournamentHistory => _tournamentHistory;
  bool get isLoadingHistory => _isLoadingHistory;
  List<Match> get matches => _matches;
  bool get isLoadingMatches => _isLoadingMatches;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _profileService.getProfile();

    _isLoading = false;

    if (result.success && result.data != null) {
      _user = result.data!.user;
      _statistics = result.data!.statistics;
      _error = null;
    } else {
      _error = result.message;
    }

    notifyListeners();
  }

  Future<void> loadTournamentHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    _tournamentHistory = await _profileService.getTournamentHistory();
    _isLoadingHistory = false;
    notifyListeners();
  }

  Future<void> loadMatches() async {
    _isLoadingMatches = true;
    _matchesPage = 1;
    notifyListeners();

    final result = await _profileService.getMatchHistory(page: 1);

    _isLoadingMatches = false;

    if (result.success) {
      _matches = result.matches;
      _matchesPage = result.currentPage;
      _matchesLastPage = result.lastPage;
    }

    notifyListeners();
  }

  Future<void> loadMoreMatches() async {
    if (_isLoadingMatches || !hasMoreMatches) return;

    _isLoadingMatches = true;
    notifyListeners();

    final result = await _profileService.getMatchHistory(
      page: _matchesPage + 1,
    );

    _isLoadingMatches = false;

    if (result.success) {
      _matches.addAll(result.matches);
      _matchesPage = result.currentPage;
      _matchesLastPage = result.lastPage;
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    await Future.wait([loadProfile(), loadTournamentHistory()]);
  }
}
