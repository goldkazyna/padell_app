import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'standings_bits.dart';
import 'verified_badge.dart';

/// Таблица лидеров для Americano Flex: Забито / Пропущено / Разница / Матчей /
/// % побед / Среднее, с горизонтальным скроллом (данные не сжимаются).
/// Ранжирование —
/// по среднему за матч (у игроков разное число игр из-за отдыхов).
///
/// Данные из `getLeaderboard` (одинаковы для /live, /results, /stats):
/// points_for, points_against, matches_played, total_points, position, ...
class FlexStandingsTable extends StatelessWidget {
  final List<Map<String, dynamic>> leaderboard;
  final int? currentUserId;
  final void Function(int? id, String? name)? onPlayerTap;

  const FlexStandingsTable({
    super.key,
    required this.leaderboard,
    this.currentUserId,
    this.onPlayerTap,
  });

  static const _hdrStyle = TextStyle(
    color: Color(0xFF8A968F),
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: c.maxWidth),
              child: Table(
                columnWidths: const {
                  0: IntrinsicColumnWidth(), // #
                  1: IntrinsicColumnWidth(), // avatar
                  2: IntrinsicColumnWidth(), // имя
                  3: IntrinsicColumnWidth(), // В
                  4: IntrinsicColumnWidth(), // П
                  5: IntrinsicColumnWidth(), // Н
                  6: IntrinsicColumnWidth(), // З
                  7: IntrinsicColumnWidth(), // Пр
                  8: IntrinsicColumnWidth(), // ±
                  9: IntrinsicColumnWidth(), // М
                  10: IntrinsicColumnWidth(), // Ср
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [_headerRow(), for (final p in leaderboard) _row(p)],
              ),
            ),
          ),
          const StandingsLegend(
            items: [
              ...StandingsLegend.scoring,
              ('М', 'матчей'),
              ('Ср', 'среднее забитых за матч'),
            ],
            padding: EdgeInsets.fromLTRB(10, 8, 10, 4),
          ),
        ],
      ),
    );
  }

  TableRow _headerRow() {
    Widget hdr(
      String t, {
      AlignmentGeometry alignment = Alignment.center,
      EdgeInsets? padding,
    }) => Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(6, 8, 6, 6),
      child: Align(
        alignment: alignment,
        child: Text(t, style: _hdrStyle),
      ),
    );
    return TableRow(
      children: [
        hdr(
          '#',
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(2, 8, 6, 6),
        ),
        const SizedBox(),
        hdr('Игрок', alignment: Alignment.centerLeft),
        hdr('В'),
        hdr('П'),
        hdr('Н'),
        hdr('З'),
        hdr('Пр'),
        hdr('±'),
        hdr('М'),
        hdr('Ср'),
      ],
    );
  }

  TableRow _row(Map<String, dynamic> p) {
    final position = (p['position'] as num?)?.toInt() ?? 0;
    final playerId = p['id'] is num ? (p['id'] as num).toInt() : null;
    final playerName = p['name'] as String?;
    final isMe =
        p['is_me'] == true ||
        (currentUserId != null && playerId == currentUserId);
    // Парная строка: оба игрока с аватарами на двух строках.
    final rawPlayers = p['players'] as List?;
    final pair = (rawPlayers != null && rawPlayers.length == 2)
        ? rawPlayers.cast<Map<String, dynamic>>()
        : null;

    final pointsFor = (p['points_for'] as num?)?.toInt() ?? 0;
    final pointsAgainst = (p['points_against'] as num?)?.toInt() ?? 0;
    // /live отдаёт число матчей как games_played, /results и /stats — matches_played.
    final matches =
        (p['matches_played'] as num?)?.toInt() ??
        (p['games_played'] as num?)?.toInt() ??
        0;
    final diff = pointsFor - pointsAgainst;
    // Среднее = забито ÷ матчей (как в вебе: 113/6 = 18.83).
    final avg = matches > 0 ? pointsFor / matches : 0.0;

    Color rankColor = AppTheme.textDim;
    if (position == 1) rankColor = const Color(0xFFFFD700);
    if (position == 2) rankColor = const Color(0xFFC0C0C0);
    if (position == 3) rankColor = const Color(0xFFCD7F32);

    Widget cell(
      Widget child, {
      EdgeInsets? padding,
      AlignmentGeometry alignment = Alignment.center,
    }) => InkWell(
      onTap: onPlayerTap == null
          ? null
          : () => onPlayerTap!(playerId, playerName),
      child: Container(
        padding: padding ?? const EdgeInsets.fromLTRB(6, 8, 6, 8),
        alignment: alignment,
        child: child,
      ),
    );

    return TableRow(
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accent.withAlpha(20) : null,
        border: Border(top: BorderSide(color: AppTheme.divider, width: 0.5)),
      ),
      children: [
        cell(
          Text(
            '$position',
            style: TextStyle(
              color: rankColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(2, 8, 6, 8),
          alignment: Alignment.centerLeft,
        ),
        cell(
          pair == null
              ? _Avatar(url: p['avatar'] as String?, name: playerName ?? '')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final pl in pair)
                      SizedBox(
                        height: 26,
                        child: Center(
                          child: _Avatar(
                            url: pl['avatar'] as String?,
                            name: (pl['name'] as String?) ?? '',
                            size: 20,
                          ),
                        ),
                      ),
                  ],
                ),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
        cell(
          pair == null
              ? ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: StandingsName(
                    name: playerName ?? '—',
                    color: isMe ? AppTheme.accent : null,
                    trailing: [
                      if (p['verified'] == true)
                        VerifiedBadge(
                          size: 12,
                          userId: playerId,
                          playerName: playerName,
                        ),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final pl in pair)
                      SizedBox(
                        height: 26,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 240),
                              child: Text(
                                (pl['name'] as String?) ?? '—',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isMe
                                      ? AppTheme.accent
                                      : AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (pl['verified'] == true) ...[
                              const SizedBox(width: 5),
                              VerifiedBadge(
                                size: 12,
                                userId: (pl['id'] as num?)?.toInt(),
                                playerName: pl['name'] as String?,
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
          padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
          alignment: Alignment.centerLeft,
        ),
        // Победы / поражения / ничьи — первыми, как в остальных таблицах
        cell(
          Text(
            '${(p['wins'] as num?)?.toInt() ?? 0}',
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        cell(
          Text(
            '${(p['losses'] as num?)?.toInt() ?? 0}',
            style: TextStyle(
              color: AppTheme.error,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        cell(
          Text(
            '${(p['draws'] as num?)?.toInt() ?? 0}',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Забито
        cell(
          Text(
            '$pointsFor',
            style: const TextStyle(
              color: Color(0xFF22C55E),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Пропущено
        cell(
          Text(
            '$pointsAgainst',
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Разница
        cell(
          Text(
            diff > 0 ? '+$diff' : '$diff',
            style: TextStyle(
              color: diff > 0
                  ? const Color(0xFF22C55E)
                  : diff < 0
                  ? const Color(0xFFEF4444)
                  : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Матчей
        cell(
          Text(
            '$matches',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Среднее
        cell(
          Text(
            avg.toStringAsFixed(2),
            style: const TextStyle(
              color: Color(0xFF22C55E),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(6, 8, 4, 8),
          alignment: Alignment.centerRight,
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  final String name;
  final double size;
  const _Avatar({this.url, required this.name, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.length >= 2
        ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF27302B),
      ),
      child: url != null && url!.isNotEmpty
          ? Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(initials),
            )
          : _fallback(initials),
    );
  }

  Widget _fallback(String t) => Center(
    child: Text(
      t,
      style: TextStyle(
        color: AppTheme.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
