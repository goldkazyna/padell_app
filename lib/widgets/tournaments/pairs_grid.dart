import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../player_avatar.dart';
import '../verified_badge.dart';

/// Сетка пар в парном флексе: все пары турнира сразу, включая пустые.
///
/// Раньше показывался общий список записавшихся, и человек не понимал, с кем
/// играет и куда можно сесть. Здесь турнир виден целиком: 16 мест — это
/// восемь пар, свободное место так и подписано, тап по нему сажает туда.
class PairsGrid extends StatelessWidget {
  final Tournament tournament;
  final int? currentUserId;

  /// Сесть к тому, кто уже занял пару.
  final void Function(TournamentTeam team) onJoinTeam;

  /// Занять пустую пару.
  final VoidCallback onTakeEmpty;

  /// Пока идёт запрос — не даём нажимать второй раз.
  final bool busy;

  const PairsGrid({
    super.key,
    required this.tournament,
    required this.onJoinTeam,
    required this.onTakeEmpty,
    this.currentUserId,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final teams = tournament.teams;
    final maxPairs = tournament.maxPairs > 0
        ? tournament.maxPairs
        : (tournament.maxParticipants / 2).floor();
    final emptyCount = (maxPairs - teams.length).clamp(0, maxPairs);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.pairs,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '${teams.length} / $maxPairs',
                style: const TextStyle(
                  color: Color(0xFF08090A),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const Spacer(),
            Text(
              l10n.seatsCount(tournament.maxParticipants),
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),

        for (var i = 0; i < teams.length; i++) ...[
          _pair(context, number: i + 1, team: teams[i]),
          const SizedBox(height: 8),
        ],

        // Пустые пары рисуем всегда: турнир должен быть виден целиком.
        for (var i = 0; i < emptyCount; i++) ...[
          _emptyPair(context, number: teams.length + i + 1),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _pair(
    BuildContext context, {
    required int number,
    required TournamentTeam team,
  }) {
    final mine = team.player1.id == currentUserId ||
        team.player2?.id == currentUserId;

    return _shell(
      number: number,
      mine: mine,
      children: [
        _player(context, team.player1),
        const SizedBox(height: 8),
        if (team.player2 != null)
          _player(context, team.player2!)
        else
          _freeSlot(
            context,
            // К уже занятой паре подписываем, с кем сядешь.
            label: AppLocalizations.of(context)!
                .freeSlotWith(_firstName(team.player1.name)),
            onTap: mine ? null : () => onJoinTeam(team),
          ),
      ],
    );
  }

  Widget _emptyPair(BuildContext context, {required int number}) {
    final l10n = AppLocalizations.of(context)!;

    return _shell(
      number: number,
      mine: false,
      children: [
        _freeSlot(context, label: l10n.freeSlot, onTap: onTakeEmpty),
        const SizedBox(height: 8),
        _freeSlot(context, label: l10n.freeSlot, onTap: onTakeEmpty),
      ],
    );
  }

  Widget _shell({
    required int number,
    required bool mine,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        color: mine ? AppTheme.accent.withValues(alpha: 0.07) : AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: mine
              ? AppTheme.accent.withValues(alpha: 0.5)
              : AppTheme.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            child: Padding(
              padding: const EdgeInsets.only(top: 9),
              child: Text(
                '$number',
                style: TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
          Expanded(child: Column(children: children)),
        ],
      ),
    );
  }

  Widget _player(BuildContext context, TournamentTeamPlayer player) {
    final mine = player.id == currentUserId;

    return Row(
      children: [
        PlayerAvatar(name: player.name, avatarUrl: player.avatar, size: 34, circle: true),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      player.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: mine ? AppTheme.accent : AppTheme.textPrimary,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (player.levelVerified) ...[
                    const SizedBox(width: 5),
                    const VerifiedBadge(size: 10),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'L${player.level.floor()} · ${player.level.toStringAsFixed(2)}',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${player.rating}',
          style: TextStyle(
            color: mine ? AppTheme.accent : AppTheme.textPrimary,
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _freeSlot(
    BuildContext context, {
    required String label,
    VoidCallback? onTap,
  }) {
    final active = onTap != null && !busy;

    return GestureDetector(
      onTap: active ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.accent.withValues(alpha: active ? 0.06 : 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: active ? 0.45 : 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 16, color: AppTheme.accent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.accent
                      .withValues(alpha: active ? 1 : 0.5),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _firstName(String name) =>
      name.trim().split(RegExp(r'\s+')).first;
}
