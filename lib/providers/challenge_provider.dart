import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class ChallengeProvider extends ChangeNotifier {
  final ChallengeService _service;
  final StorageService _storage;

  List<Challenge> _openChallenges = [];
  List<Challenge> _myChallenges = [];

  bool _isLoadingOpen = false;
  bool _isLoadingMy = false;

  // Детали челленджа
  Challenge? _currentChallenge;
  bool _isLoadingDetail = false;
  bool _isActionLoading = false;

  String? _error;

  ChallengeProvider(this._service, this._storage);

  List<Challenge> get openChallenges => _openChallenges;
  List<Challenge> get myChallenges => _myChallenges;

  bool get isLoadingOpen => _isLoadingOpen;
  bool get isLoadingMy => _isLoadingMy;

  Challenge? get currentChallenge => _currentChallenge;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isActionLoading => _isActionLoading;

  String? get error => _error;

  Future<void> loadOpenChallenges() async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingOpen = true;
    _error = null;
    notifyListeners();

    try {
      _openChallenges = await _service.getOpenChallenges(token);
    } catch (e) {
      _error = 'Ошибка загрузки челленджей: $e';
    }

    _isLoadingOpen = false;
    notifyListeners();
  }

  Future<void> loadMyChallenges() async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingMy = true;
    _error = null;
    notifyListeners();

    try {
      _myChallenges = await _service.getMyChallenges(token);
    } catch (e) {
      _error = 'Ошибка загрузки челленджей: $e';
    }

    _isLoadingMy = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadOpenChallenges(),
      loadMyChallenges(),
    ]);
  }

  // === Детали челленджа ===

  Future<void> loadChallengeDetails(int id) async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _currentChallenge = await _service.getChallengeDetails(id, token);
      developer.log('Loaded challenge: ${_currentChallenge?.id}, players: ${_currentChallenge?.players.length}', name: 'ChallengeProvider');
    } catch (e, stackTrace) {
      _error = 'Ошибка загрузки челленджа: $e';
      developer.log('ERROR loading challenge: $e', name: 'ChallengeProvider');
      developer.log('Stack: $stackTrace', name: 'ChallengeProvider');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  // === Создать челлендж ===

  Future<({bool success, String message, Challenge? challenge})> createChallenge(Map<String, dynamic> data) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации', challenge: null);

    _isActionLoading = true;
    notifyListeners();

    try {
      final challenge = await _service.create(data, token);
      await loadAll();
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Челлендж создан', challenge: challenge);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      return (success: false, message: e.message, challenge: null);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      return (success: false, message: 'Ошибка: $e', challenge: null);
    }
  }

  // === Присоединиться ===

  Future<({bool success, String message})> joinChallenge(int id, int position) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentChallenge = await _service.join(id, position, token);
      await loadAll();
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Вы присоединились');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadChallengeDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadChallengeDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Пригласить игрока ===

  Future<({bool success, String message})> invitePlayer(int id, String phone, int position) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.invite(id, phone, position, token);
      await loadChallengeDetails(id);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Принять приглашение ===

  Future<({bool success, String message})> acceptChallenge(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentChallenge = await _service.accept(id, token);
      await loadAll();
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Приглашение принято');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadChallengeDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadChallengeDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Отклонить приглашение ===

  Future<({bool success, String message})> declineChallenge(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.decline(id, token);
      await loadAll();
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Начать игру ===

  Future<({bool success, String message})> startChallenge(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.start(id, token);
      await loadChallengeDetails(id);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadChallengeDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadChallengeDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Отправить счёт ===

  Future<({bool success, String message})> submitScore(int id, List<Map<String, int>> sets) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      _currentChallenge = await _service.submitScore(id, sets, token);
      await loadAll();
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: 'Счёт сохранён');
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadChallengeDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadChallengeDetails(id);
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
      final response = await _service.confirmScore(id, token);
      final message = response['message'] as String? ?? 'Готово';
      if (response['data'] != null) {
        _currentChallenge = Challenge.fromJson(response['data'] as Map<String, dynamic>);
      }
      return (success: true, message: message);
    } catch (e) {
      return (success: false, message: 'Ошибка: $e');
    } finally {
      _isActionLoading = false;
      notifyListeners();
    }
  }

  // === Отменить челлендж ===

  Future<({bool success, String message})> cancelChallenge(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.cancel(id, token);
      await loadAll();
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Покинуть челлендж ===

  Future<({bool success, String message})> leaveChallenge(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.leave(id, token);
      await loadAll();
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadChallengeDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadChallengeDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Поиск игрока ===

  Future<List<Map<String, dynamic>>> searchPlayers(String phone) async {
    final token = await _storage.getToken();
    if (token == null) return [];

    try {
      return await _service.searchPlayers(phone, token);
    } catch (e) {
      developer.log('Search players ERROR: $e', name: 'ChallengeProvider');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getClubs() async {
    final token = await _storage.getToken();
    if (token == null) return [];
    try {
      return await _service.getClubs(token);
    } catch (e) {
      developer.log('Get clubs ERROR: $e', name: 'ChallengeProvider');
      return [];
    }
  }

  void clearCurrentChallenge() {
    _currentChallenge = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
