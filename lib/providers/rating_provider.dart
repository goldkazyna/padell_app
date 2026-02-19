import 'package:flutter/material.dart';
import '../services/rating_service.dart';

class RatingProvider extends ChangeNotifier {
  final RatingService _ratingService;

  RatingProvider(this._ratingService);

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  MyRatingCard? _myCard;
  List<RatingPlayer> _players = [];
  List<RatingPlayer> _neighbors = [];
  int _page = 1;
  int _totalPages = 1;
  int _total = 0;
  String _levelFilter = 'all';
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  MyRatingCard? get myCard => _myCard;
  List<RatingPlayer> get players => _players;
  List<RatingPlayer> get neighbors => _neighbors;
  int get page => _page;
  int get totalPages => _totalPages;
  int get total => _total;
  String get levelFilter => _levelFilter;
  String get searchQuery => _searchQuery;
  bool get hasMore => _page < _totalPages;

  Future<void> loadRating({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      _players = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _ratingService.getRating(
      level: _levelFilter,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      page: _page,
    );

    _isLoading = false;

    if (result.success && result.data != null) {
      _myCard = result.data!.myCard;
      _players = result.data!.players;
      _neighbors = result.data!.neighbors;
      _page = result.data!.page;
      _totalPages = result.data!.totalPages;
      _total = result.data!.total;
      _error = null;
    } else {
      _error = result.message;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final result = await _ratingService.getRating(
      level: _levelFilter,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      page: _page + 1,
    );

    _isLoadingMore = false;

    if (result.success && result.data != null) {
      _players.addAll(result.data!.players);
      _page = result.data!.page;
      _totalPages = result.data!.totalPages;
      _total = result.data!.total;
    }

    notifyListeners();
  }

  void setLevelFilter(String level) {
    if (_levelFilter != level) {
      _levelFilter = level;
      loadRating(refresh: true);
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadRating(refresh: true);
  }

  Future<void> refresh() async {
    await loadRating(refresh: true);
  }
}
