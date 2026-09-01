import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/game.dart';
import '../services/game_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _service;
  final StorageService _storage;

  List<Game> _feed = [];
  List<Game> _myGames = [];
  List<GameInvitationItem> _invitations = [];
  List<GameClub> _clubs = [];

  Game? _currentGame;

  bool _isLoadingFeed = false;
  bool _isLoadingMy = false;
  bool _isLoadingDetail = false;
  bool _isActionLoading = false;

  String? _error;

  int _feedTotal = 0;
  int _feedPage = 1;
  int _feedLastPage = 1;

  GameProvider(this._service, this._storage);

  List<Game> get feed => _feed;
  List<Game> get myGames => _myGames;
  List<GameInvitationItem> get invitations => _invitations;
  List<GameClub> get clubs => _clubs;

  Game? get currentGame => _currentGame;

  bool get isLoadingFeed => _isLoadingFeed;
  bool get isLoadingMy => _isLoadingMy;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isActionLoading => _isActionLoading;

  String? get error => _error;

  int get feedTotal => _feedTotal;
  int get feedPage => _feedPage;
  int get feedLastPage => _feedLastPage;

  // === Лента игр ===

  Future<void> loadFeed({Map<String, dynamic>? filters}) async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingFeed = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getFeed(filters ?? {}, token);
      _feed = result.items;
      _feedTotal = result.total;
      _feedLastPage = result.lastPage;
      _feedPage = result.currentPage;
    } catch (e) {
      _error = 'Ошибка загрузки игр: $e';
      developer.log('ERROR loading feed: $e', name: 'GameProvider');
    }

    _isLoadingFeed = false;
    notifyListeners();
  }

  /// Сколько игр сейчас в ленте — для бейджа на главной.
  ///
  /// Просим одну запись: нужен только счётчик из meta, а не список.
  /// Ошибку глотаем: из-за бейджа главная падать не должна.
  Future<int> countFeed() async {
    final token = await _storage.getToken();
    if (token == null) return 0;

    try {
      final result = await _service.getFeed({'per_page': 1}, token);
      return result.total;
    } catch (_) {
      return 0;
    }
  }

  // === Мои игры ===

  Future<void> loadMyGames({Map<String, dynamic>? filters}) async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingMy = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getMyGames(filters ?? {}, token);
      _myGames = result.items;
    } catch (e) {
      _error = 'Ошибка загрузки игр: $e';
      developer.log('ERROR loading my games: $e', name: 'GameProvider');
    }

    _isLoadingMy = false;
    notifyListeners();
  }

  // === Приглашения ===

  Future<void> loadInvitations({String? status}) async {
    final token = await _storage.getToken();
    if (token == null) return;

    try {
      _invitations = await _service.getInvitations(status, token);
    } catch (e) {
      _error = 'Ошибка загрузки приглашений: $e';
      developer.log('ERROR loading invitations: $e', name: 'GameProvider');
    }

    notifyListeners();
  }

  // === Детали игры ===

  Future<void> loadDetails(int id) async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _currentGame = await _service.getDetails(id, token);
      developer.log('Loaded game: ${_currentGame?.id}', name: 'GameProvider');
    } catch (e, stackTrace) {
      _error = 'Ошибка загрузки игры: $e';
      developer.log('ERROR loading game: $e', name: 'GameProvider');
      developer.log('Stack: $stackTrace', name: 'GameProvider');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  // === Клубы ===

  Future<void> loadClubs() async {
    final token = await _storage.getToken();
    if (token == null) return;

    try {
      _clubs = await _service.getClubs(token);
    } catch (e) {
      _error = 'Ошибка загрузки клубов: $e';
      developer.log('ERROR loading clubs: $e', name: 'GameProvider');
    }

    notifyListeners();
  }

  // === Создать игру ===

  Future<({bool success, String message, Game? game})> createGame(
    Map<String, dynamic> data,
  ) async {
    final token = await _storage.getToken();
    if (token == null) {
      return (success: false, message: 'Нет авторизации', game: null);
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final game = await _service.create(data, token);
      _currentGame = game;
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Игра создана', game: game);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      return (success: false, message: e.message, game: null);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      return (success: false, message: 'Ошибка: $e', game: null);
    }
  }

  // === Обновить игру ===

  Future<({bool success, String message})> updateGame(
    int id,
    Map<String, dynamic> data,
  ) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.update(id, data, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Пригласить игрока ===

  Future<({bool success, String message})> invite(int id, int userId) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.invite(id, userId, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Приглашение отправлено');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Подать заявку ===

  Future<({bool success, String message})> apply(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.apply(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Заявка отправлена');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Одобрить заявку ===

  Future<({bool success, String message})> approve(int id, int playerId) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.approveApplication(id, playerId, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Отклонить заявку ===

  Future<({bool success, String message})> reject(int id, int playerId) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.rejectApplication(id, playerId, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Принять приглашение ===

  Future<({bool success, String message})> accept(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.accept(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Приглашение принято');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Отклонить приглашение ===

  Future<({bool success, String message})> decline(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.decline(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Приглашение отклонено');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Покинуть игру ===

  Future<({bool success, String message})> leave(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.leave(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Вы покинули игру');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Удалить игрока ===

  Future<({bool success, String message})> removePlayer(
    int id,
    int playerId,
  ) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.removePlayer(id, playerId, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Начать игру ===

  Future<({bool success, String message})> start(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.start(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Игра началась');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Отменить игру целиком ===

  /// Организатор закрывает игру, чтобы она не висела: после отмены она
  /// пропадает и из ленты, и из «моих игр».
  Future<({bool success, String message})> cancelGame(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.cancelGame(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Игра отменена');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Отменить начало игры ===

  Future<({bool success, String message})> startCancel(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.startCancel(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Завершить игру ===

  Future<({bool success, String message})> finish(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.finish(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Игра завершена');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Подтвердить счёт ===

  Future<({bool success, String message})> confirmScore(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.confirmScore(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Пересоздать расписание ===

  Future<({bool success, String message})> regenerate(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.regenerateSchedule(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Раунды ===

  Future<({bool success, String message})> addRound(
    int id,
    Map<String, dynamic> body,
  ) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.addRound(id, body, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Раунд добавлен');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  Future<({bool success, String message})> updateRound(
    int id,
    int roundId,
    Map<String, dynamic> body,
  ) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.updateRound(id, roundId, body, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  Future<({bool success, String message})> deleteRound(
    int id,
    int roundId,
  ) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.deleteRound(id, roundId, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Раунд удалён');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Ссылка-приглашение ===

  Future<({bool success, String message})> shareRotate(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.shareRotate(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  Future<({bool success, String message})> shareRevoke(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.shareRevoke(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Передача места ===

  Future<({bool success, String message})> transferInitiate(
    int id,
    int toUserId,
  ) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.transferInitiate(id, toUserId, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Передача места отправлена');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  Future<({bool success, String message})> transferCancel(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.transferCancel(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Готово');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  Future<({bool success, String message})> transferAccept(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.transferAccept(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Место принято');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  Future<({bool success, String message})> transferDecline(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentGame = await _service.transferDecline(id, token);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Отклонено');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Поиск партнёра ===

  Future<List<Map<String, dynamic>>> searchPartner(String phone) async {
    final token = await _storage.getToken();
    if (token == null) return [];

    try {
      return await _service.searchPartner(phone, token);
    } catch (e) {
      developer.log('Search partner ERROR: $e', name: 'GameProvider');
      return [];
    }
  }

  void clearCurrentGame() {
    _currentGame = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
