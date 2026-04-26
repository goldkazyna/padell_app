import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../screens/tournament_detail_screen.dart';

/// Слушает входящие deep-link'и (padelp://tournament/{id}) и роутит на
/// нужный экран.
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

    // padelp://tournament/123  — host=tournament, segments=[123]
    // https://padel-p.kz/t/123 — segments=[t, 123]
    int? tournamentId;
    if (uri.host == 'tournament' && uri.pathSegments.isNotEmpty) {
      tournamentId = int.tryParse(uri.pathSegments.first);
    } else if (uri.pathSegments.length >= 2 &&
        (uri.pathSegments[0] == 't' || uri.pathSegments[0] == 'tournament')) {
      tournamentId = int.tryParse(uri.pathSegments[1]);
    }

    if (tournamentId == null) return;
    _navigateToTournament(tournamentId, fromInitial: fromInitial);
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
}
