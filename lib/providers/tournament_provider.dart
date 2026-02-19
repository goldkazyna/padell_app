import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../models/tournament.dart';
import '../services/tournament_service.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';

class TournamentProvider extends ChangeNotifier {
  final TournamentService _service;
  final StorageService _storage;

  List<Tournament> _openTournaments = [];
  List<Tournament> _myTournaments = [];
  List<Tournament> _archiveTournaments = [];

  bool _isLoadingOpen = false;
  bool _isLoadingMy = false;
  bool _isLoadingArchive = false;

  // Детали турнира
  Tournament? _selectedTournament;
  bool _isLoadingDetail = false;
  bool _isActionLoading = false;

  // Поиск партнёра (team registration)
  List<PartnerSearchResult> _partnerSearchResults = [];
  bool _isSearchingPartner = false;
  PartnerSearchResult? _selectedPartner;

  String? _error;

  TournamentProvider(this._service, this._storage);

  List<Tournament> get openTournaments => _openTournaments;
  List<Tournament> get myTournaments => _myTournaments;
  List<Tournament> get archiveTournaments => _archiveTournaments;

  bool get isLoadingOpen => _isLoadingOpen;
  bool get isLoadingMy => _isLoadingMy;
  bool get isLoadingArchive => _isLoadingArchive;

  Tournament? get selectedTournament => _selectedTournament;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isActionLoading => _isActionLoading;

  List<PartnerSearchResult> get partnerSearchResults => _partnerSearchResults;
  bool get isSearchingPartner => _isSearchingPartner;
  PartnerSearchResult? get selectedPartner => _selectedPartner;

  String? get error => _error;

  Future<void> loadOpenTournaments() async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingOpen = true;
    _error = null;
    notifyListeners();

    try {
      _openTournaments = await _service.getOpenTournaments(token);
    } catch (e) {
      _error = 'Ошибка загрузки турниров: $e';
    }

    _isLoadingOpen = false;
    notifyListeners();
  }

  Future<void> loadMyTournaments() async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingMy = true;
    _error = null;
    notifyListeners();

    try {
      _myTournaments = await _service.getMyTournaments(token);
    } catch (e) {
      _error = 'Ошибка загрузки турниров: $e';
    }

    _isLoadingMy = false;
    notifyListeners();
  }

  Future<void> loadArchiveTournaments() async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingArchive = true;
    _error = null;
    notifyListeners();

    try {
      _archiveTournaments = await _service.getArchiveTournaments(token);
    } catch (e) {
      _error = 'Ошибка загрузки турниров: $e';
    }

    _isLoadingArchive = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadOpenTournaments(),
      loadMyTournaments(),
      loadArchiveTournaments(),
    ]);
  }

  // === Детали турнира ===

  Future<void> loadTournamentDetails(int id) async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _selectedTournament = await _service.getTournamentDetails(id, token);
      developer.log('Loaded tournament: ${_selectedTournament?.name}, participants: ${_selectedTournament?.participants.length}', name: 'TournamentProvider');
    } catch (e, stackTrace) {
      _error = 'Ошибка загрузки турнира: $e';
      developer.log('ERROR loading tournament: $e', name: 'TournamentProvider');
      developer.log('Stack: $stackTrace', name: 'TournamentProvider');
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  // === Записаться ===

  Future<({bool success, String message})> registerForTournament(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.register(id, token);
      await loadTournamentDetails(id);
      await Future.wait([loadOpenTournaments(), loadMyTournaments()]);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      // Обновить данные — возможно мест уже нет
      loadTournamentDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Отменить запись ===

  Future<({bool success, String message})> cancelRegistration(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.cancel(id, token);
      await loadTournamentDetails(id);
      await Future.wait([loadOpenTournaments(), loadMyTournaments()]);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Поиск партнёра (team) ===

  Future<void> searchPartner(int tournamentId, String phone) async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isSearchingPartner = true;
    notifyListeners();

    try {
      _partnerSearchResults = await _service.searchPartner(tournamentId, phone, token);
      developer.log('Partner search results: ${_partnerSearchResults.length}', name: 'TournamentProvider');
    } catch (e, stackTrace) {
      developer.log('Partner search ERROR: $e', name: 'TournamentProvider');
      developer.log('Stack: $stackTrace', name: 'TournamentProvider');
      _partnerSearchResults = [];
    }

    _isSearchingPartner = false;
    notifyListeners();
  }

  void selectPartner(PartnerSearchResult partner) {
    _selectedPartner = partner;
    notifyListeners();
  }

  void clearPartnerSearch() {
    _partnerSearchResults = [];
    _selectedPartner = null;
    _isSearchingPartner = false;
    notifyListeners();
  }

  // === Регистрация команды ===

  Future<({bool success, String message})> registerTeam(int tournamentId) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');
    if (_selectedPartner == null) return (success: false, message: 'Выберите партнёра');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.registerTeam(tournamentId, _selectedPartner!.id, token);
      clearPartnerSearch();
      await loadTournamentDetails(tournamentId);
      await Future.wait([loadOpenTournaments(), loadMyTournaments()]);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(tournamentId);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(tournamentId);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  // === Отменить запись команды ===

  Future<({bool success, String message})> cancelTeamRegistration(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.cancelTeam(id, token);
      await loadTournamentDetails(id);
      await Future.wait([loadOpenTournaments(), loadMyTournaments()]);
      _isActionLoading = false;
      notifyListeners();
      return (success: true, message: message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(id);
      return (success: false, message: e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(id);
      return (success: false, message: 'Ошибка: $e');
    }
  }

  void clearSelectedTournament() {
    _selectedTournament = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
