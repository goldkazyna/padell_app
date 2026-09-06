import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/amigo.dart';
import '../../screens/game_detail_screen.dart';
import '../../screens/player_profile_screen.dart';
import '../../screens/tournament_detail_screen.dart';
import '../../screens/tournament_live_entry_screen.dart';
import '../../theme/app_theme.dart';
import '../player_avatar.dart';

/// Есть ли из чего выбирать: занят ли человек чем-то, что можно открыть.
///
/// Вынесено отдельной функцией, потому что это и есть правило: спрашиваем,
/// только когда вариантов два. Лишний вопрос там, где выбора нет, злит.
bool amigoHasChoice(AmigoStatus? status) => status != null && status.hasTarget;

/// Куда идти по тапу на амигос: в трансляцию (турнир, игру) или в профиль.
///
/// Раньше тап сразу уводил в трансляцию, и попасть в профиль человека было
/// нечем — а это две разные потребности: «посмотреть, как он играет» и
/// «посмотреть, кто он такой».
Future<void> openAmigoTarget(
  BuildContext context, {
  required int playerId,
  required String playerName,
  String? avatar,
  AmigoStatus? status,
}) async {
  void push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  // Выбора нет — открываем профиль без лишнего вопроса.
  if (!amigoHasChoice(status)) {
    push(PlayerProfileScreen(playerId: playerId, playerName: playerName));
    return;
  }

  // Здесь статус точно есть: amigoHasChoice это проверил.
  final target = status!;

  final l10n = AppLocalizations.of(context)!;

  final choice = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A3330),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              PlayerAvatar(
                name: playerName,
                avatarUrl: avatar,
                size: 38,
                circle: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (target.subtitle.isNotEmpty)
                      Text(
                        target.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _SheetAction(
            icon: target.isPlaying
                ? Icons.play_circle_outline
                : Icons.event_outlined,
            label: target.isPlaying
                ? l10n.amigoOpenLive
                : (target.gameId != null ? l10n.amigoOpenGame : l10n.amigoOpenTournament),
            accent: true,
            onTap: () => Navigator.pop(ctx, 'target'),
          ),
          _SheetAction(
            icon: Icons.person_outline,
            label: l10n.amigoOpenProfile,
            onTap: () => Navigator.pop(ctx, 'profile'),
          ),
        ],
      ),
    ),
  );

  if (choice == null || !context.mounted) return;

  if (choice == 'profile') {
    push(PlayerProfileScreen(playerId: playerId, playerName: playerName));
    return;
  }

  if (target.isPlaying && target.tournamentId != null) {
    push(TournamentLiveEntryScreen(tournamentId: target.tournamentId!));
  } else if (target.tournamentId != null) {
    push(TournamentDetailScreen(tournamentId: target.tournamentId!));
  } else if (target.gameId != null) {
    push(GameDetailScreen(gameId: target.gameId!));
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool accent;
  final VoidCallback onTap;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accent ? AppTheme.accent : AppTheme.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 19, color: color),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
