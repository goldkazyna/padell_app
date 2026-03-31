import 'package:flutter/material.dart';
import '../models/club.dart';
import '../services/court_service.dart';
import '../services/api_service.dart';

class CourtProvider extends ChangeNotifier {
  final CourtService _courtService;

  CourtProvider(this._courtService);

  // Клубы
  bool _isLoading = false;
  String? _error;
  List<Club> _clubs = [];
  List<String> _cities = [];
  String? _selectedCity;
  String _searchQuery = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Club> get clubs => _clubs;
  List<String> get cities => _cities;
  String? get selectedCity => _selectedCity;

  // Расписание
  bool _isScheduleLoading = false;
  String? _scheduleError;
  Map<String, dynamic>? _scheduleData;

  bool get isScheduleLoading => _isScheduleLoading;
  String? get scheduleError => _scheduleError;
  Map<String, dynamic>? get scheduleData => _scheduleData;

  // Бронирования
  bool _isBookingsLoading = false;
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _pastBookings = [];

  bool get isBookingsLoading => _isBookingsLoading;
  List<Map<String, dynamic>> get upcomingBookings => _upcomingBookings;
  List<Map<String, dynamic>> get pastBookings => _pastBookings;

  void setCity(String? city) {
    _selectedCity = city;
    notifyListeners();
    loadClubs();
  }

  void setSearch(String query) {
    _searchQuery = query;
    loadClubs();
  }

  Future<void> loadClubs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _courtService.getClubs(
        city: _selectedCity,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (response['success'] == true) {
        final clubsList = response['clubs'] as List<dynamic>? ?? [];
        _clubs = clubsList.map((c) => Club.fromJson(c as Map<String, dynamic>)).toList();
        final citiesList = response['cities'] as List<dynamic>? ?? [];
        _cities = citiesList.map((c) => c.toString()).toList();
      } else {
        _error = response['message'] as String? ?? 'Ошибка загрузки';
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Ошибка загрузки клубов';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadSchedule(int clubId, String date) async {
    _isScheduleLoading = true;
    _scheduleError = null;
    notifyListeners();

    try {
      final response = await _courtService.getSchedule(clubId, date);
      if (response['success'] == true) {
        _scheduleData = response;
      } else {
        _scheduleError = response['message'] as String? ?? 'Ошибка загрузки';
      }
    } on ApiException catch (e) {
      _scheduleError = e.message;
    } catch (e) {
      _scheduleError = 'Ошибка загрузки расписания';
    }

    _isScheduleLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> book({
    required int clubId,
    required int courtId,
    required String date,
    required String startTime,
    required int slots,
    int? coachId,
    String? comment,
  }) async {
    try {
      final response = await _courtService.book(
        clubId: clubId,
        courtId: courtId,
        date: date,
        startTime: startTime,
        slots: slots,
        coachId: coachId,
        comment: comment,
      );
      return response;
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': 'Ошибка бронирования'};
    }
  }

  Future<void> loadMyBookings() async {
    _isBookingsLoading = true;
    notifyListeners();

    try {
      final response = await _courtService.getMyBookings();
      if (response['success'] == true) {
        _upcomingBookings = List<Map<String, dynamic>>.from(response['upcoming'] ?? []);
        _pastBookings = List<Map<String, dynamic>>.from(response['past'] ?? []);
      }
    } catch (e) {
      // silent
    }

    _isBookingsLoading = false;
    notifyListeners();
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      final response = await _courtService.cancelBooking(bookingId);
      if (response['success'] == true) {
        await loadMyBookings();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
