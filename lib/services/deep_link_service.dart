import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../screens/club_detail_screen.dart';
import '../screens/club_waiver_screen.dart';
import '../screens/tournament_detail_screen.dart';
import '../screens/tournament_live_entry_screen.dart';

/// Слушает входящие deep-link'и (padelp://tournament/{id}, padelp://live/{id},
/// padelp://club/{id}, padelp://waiver/{id}) и роутит на нужный экран.
///
/// Деплинки приходят:
/// - При тапе на ссылку «Открыть в приложении» с лендинга /t/{id}
/// - При тапе на padelp:// в любом приложении (мессенджере, браузере)
class DeepLinkService {
  DeepLinkService._();
  static final DeepLinkService instance = DeepLinkService._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  GlobalKey<NavigatorState>? _navigatorKey;
  bool _initialHandled = false;

  void attachNavigator(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> init() async {
    // Холодный старт: получаем uri если приложение запустили по ссылке
    if (!_initialHandled) {
      _initialHandled = true;
      try {
        final initial = await _appLinks.getInitialLink();
        if (initial != null) {
          _handleUri(initial, fromInitial: true);
        }
      } catch (e) {
        if (kDebugMode) debugPrint('DeepLink init error: $e');
      }
    }

    // Горячая ссылка: пока приложение запущено
    _sub ??= _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri),
      onError: (e) {
        if (kDebugMode) debugPrint('DeepLink stream error: $e');
      },
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }

  void _handleUri(Uri uri, {bool fromInitial = false}) {
    if (kDebugMode) debugPrint('DeepLink: $uri (initial=$fromInitial)');

    // --- Трансляция турнира ---
    // padelp://live/123      — host=live, segments=[123]
    // https://padel-p.kz/live/123 — segments=[live, 123]
    // Проверяем раньше турнира: у ссылки на live тот же номер турнира,
    // и общий разбор увёл бы зрителя на карточку вместо трансляции.
    int? liveTournamentId;
    if (uri.host == 'live' && uri.pathSegments.isNotEmpty) {
      liveTournamentId = int.tryParse(uri.pathSegments.first);
    } else if (uri.pathSegments.length >= 2 && uri.pathSegments[0] == 'live') {
      liveTournamentId = int.tryParse(uri.pathSegments[1]);
    }

    if (liveTournamentId != null) {
      _navigateToLive(liveTournamentId, fromInitial: fromInitial);
      return;
    }

    // --- Tournament ---
    // padelp://tournament/123  — host=tournament, segments=[123]
    // https://padel-p.kz/t/123 — segments=[t, 123]
    int? tournamentId;
    if (uri.host == 'tournament' && uri.pathSegments.isNotEmpty) {
      tournamentId = int.tryParse(uri.pathSegments.first);
    } else if (uri.pathSegments.length >= 2 &&
        (uri.pathSegments[0] == 't' || uri.pathSegments[0] == 'tournament')) {
      tournamentId = int.tryParse(uri.pathSegments[1]);
    }

    if (tournamentId != null) {
      _navigateToTournament(tournamentId, fromInitial: fromInitial);
      return;
    }

    // --- Отказ от ответственности ---
    // padelp://waiver/12     — host=waiver, segments=[12]
    // https://padel-p.kz/w/12 — segments=[w, 12]
    int? waiverClubId;
    if (uri.host == 'waiver' && uri.pathSegments.isNotEmpty) {
      waiverClubId = int.tryParse(uri.pathSegments.first);
    } else if (uri.pathSegments.length >= 2 &&
        (uri.pathSegments[0] == 'w' || uri.pathSegments[0] == 'waiver')) {
      waiverClubId = int.tryParse(uri.pathSegments[1]);
    }

    if (waiverClubId != null) {
      _navigateToWaiver(waiverClubId, fromInitial: fromInitial);
      return;
    }

    // --- Club ---
    // padelp://club/123  — host=club, segments=[123]
    // https://padel-p.kz/c/123 — segments=[c, 123]
    int? clubId;
    if (uri.host == 'club' && uri.pathSegments.isNotEmpty) {
      clubId = int.tryParse(uri.pathSegments.first);
    } else if (uri.pathSegments.length >= 2 &&
        (uri.pathSegments[0] == 'c' || uri.pathSegments[0] == 'club')) {
      clubId = int.tryParse(uri.pathSegments[1]);
    }

    if (clubId != null) {
      _navigateToClub(clubId, fromInitial: fromInitial);
    }
  }

  Future<void> _navigateToTournament(int id, {required bool fromInitial}) async {
    final key = _navigatorKey;
    if (key == null) return;

    // При cold-start Navigator может быть ещё не готов — ждём.
    for (int i = 0; i < 100; i++) {
      final state = key.currentState;
      if (state != null && state.mounted) {
        state.push(
          MaterialPageRoute(
            builder: (_) => TournamentDetailScreen(tournamentId: id),
          ),
        );
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _navigateToLive(int id, {required bool fromInitial}) async {
    final key = _navigatorKey;
    if (key == null) return;

    // При cold-start Navigator может быть ещё не готов — ждём.
    for (int i = 0; i < 100; i++) {
      final state = key.currentState;
      if (state != null && state.mounted) {
        state.push(
          MaterialPageRoute(
            builder: (_) => TournamentLiveEntryScreen(tournamentId: id),
          ),
        );
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _navigateToWaiver(int clubId, {required bool fromInitial}) async {
    final key = _navigatorKey;
    if (key == null) return;

    // При cold-start Navigator может быть ещё не готов — ждём.
    for (int i = 0; i < 100; i++) {
      final state = key.currentState;
      if (state != null && state.mounted) {
        state.push(
          MaterialPageRoute(
            builder: (_) => ClubWaiverScreen(clubId: clubId),
          ),
        );
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _navigateToClub(int id, {required bool fromInitial}) async {
    final key = _navigatorKey;
    if (key == null) return;

    // При cold-start Navigator может быть ещё не готов — ждём.
    for (int i = 0; i < 100; i++) {
      final state = key.currentState;
      if (state != null && state.mounted) {
        state.push(
          MaterialPageRoute(
            builder: (_) => ClubDetailScreen(clubId: id),
          ),
        );
        return;
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
