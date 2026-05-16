import 'package:flutter/material.dart';

import '../models/tournament.dart';
import '../screens/tournament_live_bali_koc_screen.dart';
import '../screens/tournament_live_kingofcourt_screen.dart';
import '../screens/tournament_live_mexicano_screen.dart';
import '../screens/tournament_live_screen.dart';
import '../screens/tournament_live_team_screen.dart';

/// Открыть Live-экран для турнира любого типа.
/// Используется для просмотра как идущих, так и завершённых турниров —
/// Live-экраны корректно показывают финальное состояние (таблица, раунды,
/// результаты) и для completed тоже.
///
/// [highlightPlayerId] — кого подсвечивать вместо текущего пользователя
/// (актуально при открытии из чужого профиля).
void openTournamentLiveByType(
  BuildContext context, {
  required int tournamentId,
  required String tournamentType,
  int? highlightPlayerId,
}) {
  Widget target;
  switch (tournamentType) {
    case 'mexicano':
      target = TournamentLiveMexicanoScreen(tournamentId: tournamentId);
      break;
    case 'team':
      target = TournamentLiveTeamScreen(tournamentId: tournamentId);
      break;
    case 'king_of_court':
      target = TournamentLiveKingOfCourtScreen(
        tournamentId: tournamentId,
        highlightPlayerId: highlightPlayerId,
      );
      break;
    case 'bali_koc':
      target = TournamentLiveBaliKocScreen(
        tournamentId: tournamentId,
        highlightPlayerId: highlightPlayerId,
      );
      break;
    default:
      // americano / classic / неизвестный — общий Live-экран
      target = TournamentLiveScreen(tournamentId: tournamentId);
  }

  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => target),
  );
}

/// Удобная обёртка от Tournament-объекта.
void openTournamentLive(BuildContext context, Tournament t,
    {int? highlightPlayerId}) {
  openTournamentLiveByType(
    context,
    tournamentId: t.id,
    tournamentType: t.type,
    highlightPlayerId: highlightPlayerId,
  );
}
