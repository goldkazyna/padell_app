import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'player_avatar.dart';
import 'verified_badge.dart';

/// Колонка показателей в таблице.
class StandingsColumn {
  final String title;

  /// Значение строки: уже готовый текст, чтобы таблица не знала о моделях.
  final String Function(int index) value;

  /// Цвет значения — для разницы очков (плюс зелёный, минус красный).
  final Color? Function(int index)? color;

  final bool bold;
  final double width;

  const StandingsColumn({
    required this.title,
    required this.value,
    this.color,
    this.bold = false,
    this.width = 52,
  });
}

/// Игрок в строке таблицы.
class StandingsPlayer {
  final String name;
  final String? avatarUrl;
  final bool verified;

  const StandingsPlayer({
    required this.name,
    this.avatarUrl,
    this.verified = false,
  });
}

/// Строка: место и один-два игрока.
class StandingsEntry {
  final int place;
  final List<StandingsPlayer> players;

  /// Подсветить свою строку (в приложении игрока).
  final bool highlight;

  const StandingsEntry({
    required this.place,
    required this.players,
    this.highlight = false,
  });
}

/// Турнирная таблица: имена закреплены слева, показатели листаются вбок.
///
/// Прежняя таблица пыталась уместить девять колонок в ширину телефона: ФИО
/// сжимались до нечитаемого, цифры лепились друг к другу. Здесь пара всегда
/// на виду — каждый игрок своей строкой, с аватаром и галочкой, — а цифры
/// уезжают пальцем, сколько бы их ни было.
class StandingsTable extends StatelessWidget {
  final List<StandingsEntry> entries;
  final List<StandingsColumn> columns;

  /// Заголовок левой колонки: «Пара» или «Игрок».
  final String nameHeader;

  /// Ширина закреплённой части. По умолчанию — под ФИО с аватаром.
  final double nameWidth;

  final void Function(int index)? onTapRow;

  const StandingsTable({
    super.key,
    required this.entries,
    required this.columns,
    this.nameHeader = 'Пара',
    this.nameWidth = 226,
    this.onTapRow,
  });

  static const double _headerHeight = 34;

  @override
  Widget build(BuildContext context) {
    // Строка тянется под число игроков: у пары две строки имён, у одиночного
    // формата одна — таблица одинаково годится обоим.
    final maxPlayers = entries.fold<int>(
      1,
      (acc, e) => e.players.length > acc ? e.players.length : acc,
    );
    final rowHeight = 22.0 + maxPlayers * 24.0;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _fixed(rowHeight),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final column in columns) _column(column, rowHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fixed(double rowHeight) {
    return Container(
      width: nameWidth,
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border(right: BorderSide(color: AppTheme.border)),
        // Тень у границы: видно, что справа есть ещё содержимое.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(4, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _headerCell(nameHeader, alignment: Alignment.centerLeft, padding: 10),
          for (var i = 0; i < entries.length; i++)
            _nameRow(entries[i], i, rowHeight),
        ],
      ),
    );
  }

  Widget _nameRow(StandingsEntry entry, int index, double height) {
    return InkWell(
      onTap: onTapRow == null ? null : () => onTapRow!(index),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: entry.highlight
              ? AppTheme.accent.withValues(alpha: 0.08)
              : null,
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            _place(entry.place),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final player in entry.players) _playerLine(player),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playerLine(StandingsPlayer player) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          PlayerAvatar(
            name: player.name,
            avatarUrl: player.avatarUrl,
            size: 22,
            circle: true,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              player.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (player.verified) ...[
            const SizedBox(width: 5),
            const VerifiedBadge(size: 11),
          ],
        ],
      ),
    );
  }

  /// Место: медальный тон у первых трёх, у остальных — приглушённый.
  Widget _place(int place) {
    final (bg, fg) = switch (place) {
      1 => (const Color(0x29F2C14E), const Color(0xFFF2C14E)),
      2 => (const Color(0x24C9D1D9), const Color(0xFFC9D1D9)),
      3 => (const Color(0x29CD7F32), const Color(0xFFCD7F32)),
      _ => (Colors.white.withValues(alpha: 0.05), AppTheme.textSecondary),
    };

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      alignment: Alignment.center,
      child: Text(
        '$place',
        style: TextStyle(
          color: fg,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _column(StandingsColumn column, double rowHeight) {
    return SizedBox(
      width: column.width,
      child: Column(
        children: [
          _headerCell(column.title),
          for (var i = 0; i < entries.length; i++)
            Container(
              height: rowHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: entries[i].highlight
                    ? AppTheme.accent.withValues(alpha: 0.08)
                    : null,
                border: Border(top: BorderSide(color: AppTheme.border)),
              ),
              child: Text(
                column.value(i),
                style: TextStyle(
                  color: column.color?.call(i) ?? AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: column.bold ? FontWeight.w800 : FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerCell(
    String text, {
    AlignmentGeometry alignment = Alignment.center,
    double padding = 4,
  }) {
    return Container(
      height: _headerHeight,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Text(
        text.toUpperCase(),
        // Заголовок узкой колонки не должен переноситься: строка шапки
        // фиксирована, вторая строка просто обрезалась бы.
        maxLines: 1,
        overflow: TextOverflow.fade,
        softWrap: false,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 10.5,
          letterSpacing: 0.6,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
