import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/game.dart';
import '../../l10n/app_localizations.dart';

/// Секция итога завершённой игры: таблица ранжирования (для Американо)
/// и изменение рейтинга (ELO) по каждому игроку.
class GameResultSection extends StatelessWidget {
  final Game game;

  const GameResultSection({super.key, required this.game});

  String _nameFor(int userId) {
    for (final p in game.players) {
      if (p.id == userId) return p.fullName;
    }
    return '#$userId';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showRanking = game.isAmericano && game.americanoRanking.isNotEmpty;
    final ratedPlayers = game.players
        .where((p) => p.isAccepted && p.ratingChange != null)
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2A3330),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.gameResultTitle,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          if (showRanking) ...[
            _buildRankingTable(l10n),
            if (ratedPlayers.isNotEmpty) const SizedBox(height: 16),
          ],
          if (ratedPlayers.isNotEmpty) _buildRatingList(l10n, ratedPlayers),
        ],
      ),
    );
  }

  Widget _buildRankingTable(AppLocalizations l10n) {
    final rows = [...game.americanoRanking]
      ..sort((a, b) => a.place.compareTo(b.place));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gameRankingTitle,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                l10n.gameRankPlace,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                l10n.gameRankPoints,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(
              width: 56,
              child: Text(
                l10n.gameRankWins,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...List.generate(rows.length, (index) {
          final row = rows[index];
          return Padding(
            padding: EdgeInsets.only(bottom: index < rows.length - 1 ? 8 : 0),
            child: _buildRankingRow(row),
          );
        }),
      ],
    );
  }

  Widget _buildRankingRow(GameRankingRow row) {
    final isTop = row.place == 1 || row.place == 2;
    final placeColor = row.place == 1
        ? AppTheme.accent
        : row.place == 2
            ? AppTheme.orange
            : AppTheme.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isTop ? placeColor.withAlpha(15) : Colors.white.withAlpha(7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '${row.place}',
              style: TextStyle(
                color: placeColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _nameFor(row.userId),
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '${row.points}',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 56,
            child: Text(
              '${row.wins}',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingList(AppLocalizations l10n, List<GamePlayer> players) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.gameRatingChange,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(players.length, (index) {
          final player = players[index];
          final change = player.ratingChange ?? 0;
          final isPositive = change > 0;
          final color = isPositive ? AppTheme.accent : AppTheme.error;
          final formatted = isPositive ? '+$change' : '−${change.abs()}';

          return Padding(
            padding: EdgeInsets.only(bottom: index < players.length - 1 ? 8 : 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    player.fullName,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  formatted,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
