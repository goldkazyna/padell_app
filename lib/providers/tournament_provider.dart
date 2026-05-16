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
  List<Tournament> _cancelledTournaments = [];

  bool _isLoadingOpen = false;
  bool _isLoadingMy = false;
  bool _isLoadingArchive = false;
  bool _isLoadingCancelled = false;

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
  List<Tournament> get cancelledTournaments => _cancelledTournaments;

  bool get isLoadingOpen => _isLoadingOpen;
  bool get isLoadingMy => _isLoadingMy;
  bool get isLoadingArchive => _isLoadingArchive;
  bool get isLoadingCancelled => _isLoadingCancelled;

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

  Future<void> loadArchiveTournaments({String? dateFrom, String? dateTo}) async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingArchive = true;
    _error = null;
    notifyListeners();

    try {
      _archiveTournaments = await _service.getArchiveTournaments(
        token,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
    } catch (e) {
      _error = 'Ошибка загрузки турниров: $e';
    }

    _isLoadingArchive = false;
    notifyListeners();
  }

  Future<void> loadCancelledTournaments() async {
    final token = await _storage.getToken();
    if (token == null) return;

    _isLoadingCancelled = true;
    _error = null;
    notifyListeners();

    try {
      _cancelledTournaments = await _service.getCancelledTournaments(token);
    } catch (e) {
      _error = 'Ошибка загрузки турниров: $e';
    }

    _isLoadingCancelled = false;
    notifyListeners();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadOpenTournaments(),
      loadMyTournaments(),
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

  Future<RegisterOutcome> registerForTournament(
    int id, {
    int? friendUserId,
    bool confirmWaitlist = false,
  }) async {
    final token = await _storage.getToken();
    if (token == null) {
      return RegisterOutcome.error('Нет авторизации');
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final result = await _service.register(
        id,
        token,
        friendUserId: friendUserId,
        confirmWaitlist: confirmWaitlist,
      );
      // Если требуется подтверждение листа ожидания — не перезагружаем
      if (result.requiresWaitlistConfirmation) {
        _isActionLoading = false;
        notifyListeners();
        return RegisterOutcome.waitlistConfirm(result);
      }
      await loadTournamentDetails(id);
      await Future.wait([loadOpenTournaments(), loadMyTournaments()]);
      _isActionLoading = false;
      notifyListeners();
      return result.success
          ? RegisterOutcome.success(result)
          : RegisterOutcome.error(result.message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(id);
      return RegisterOutcome.error(e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(id);
      return RegisterOutcome.error('Ошибка: $e');
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

  Future<RegisterOutcome> registerTeam(int tournamentId,
      {bool confirmWaitlist = false}) async {
    final token = await _storage.getToken();
    if (token == null) return RegisterOutcome.error('Нет авторизации');
    if (_selectedPartner == null) {
      return RegisterOutcome.error('Выберите партнёра');
    }

    _isActionLoading = true;
    notifyListeners();

    try {
      final result = await _service.registerTeam(
        tournamentId,
        _selectedPartner!.id,
        token,
        confirmWaitlist: confirmWaitlist,
      );
      if (result.requiresWaitlistConfirmation) {
        _isActionLoading = false;
        notifyListeners();
        return RegisterOutcome.waitlistConfirm(result);
      }
      clearPartnerSearch();
      await loadTournamentDetails(tournamentId);
      await Future.wait([loadOpenTournaments(), loadMyTournaments()]);
      _isActionLoading = false;
      notifyListeners();
      return result.success
          ? RegisterOutcome.success(result)
          : RegisterOutcome.error(result.message);
    } on ApiException catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(tournamentId);
      return RegisterOutcome.error(e.message);
    } catch (e) {
      _isActionLoading = false;
      notifyListeners();
      loadTournamentDetails(tournamentId);
      return RegisterOutcome.error('Ошибка: $e');
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

  // === Подписка на свободное место ===

  Future<({bool success, String message})> subscribeToTournament(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.subscribe(id, token);
      await loadTournamentDetails(id);
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

  Future<({bool success, String message})> unsubscribeFromTournament(int id) async {
    final token = await _storage.getToken();
    if (token == null) return (success: false, message: 'Нет авторизации');

    _isActionLoading = true;
    notifyListeners();

    try {
      final message = await _service.unsubscribe(id, token);
      await loadTournamentDetails(id);
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

/// Результат попытки регистрации на турнир.
/// Бывает трёх видов:
/// - [success]: успешно записан/в waitlist
/// - [waitlistConfirm]: основной состав полный, требуется подтверждение
/// - [error]: ошибка
class RegisterOutcome {
  final bool isSuccess;
  final bool isWaitlistConfirm;
  final String message;
  final RegisterResult? result;

  const RegisterOutcome._({
    required this.isSuccess,
    required this.isWaitlistConfirm,
    required this.message,
    this.result,
  });

  factory RegisterOutcome.success(RegisterResult r) => RegisterOutcome._(
        isSuccess: true,
        isWaitlistConfirm: false,
        message: r.message,
        result: r,
      );

  factory RegisterOutcome.waitlistConfirm(RegisterResult r) => RegisterOutcome._(
        isSuccess: false,
        isWaitlistConfirm: true,
        message: r.message,
        result: r,
      );

  factory RegisterOutcome.error(String msg) => RegisterOutcome._(
        isSuccess: false,
        isWaitlistConfirm: false,
        message: msg,
      );
}
