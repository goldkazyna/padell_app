import 'package:flutter/material.dart';

import '../../models/admin_flex_pairs.dart';
import '../../models/admin_participant.dart';
import '../../theme/app_theme.dart';
import '../player_avatar.dart';

/// Состав парного Americano Flex в админке: сетка пар и пулы под ней.
///
/// В таком турнире место — это место в паре, а не строка списка: пока пары не
/// собраны, турнир не запустить. Плоский список участников этого не показывал,
/// и организатору приходилось идти в веб-CRM. Здесь тот же порядок, что и там:
/// сверху все пары (включая пустые), ниже — кто ещё без места.
/// Тон блока «Без пары»: синий отдан очереди, жёлтый — модерации.
const Color _violet = Color(0xFF7C3AED);

class AdminFlexPairsView extends StatelessWidget {
  final AdminFlexPairs pairs;
  final List<AdminParticipant> participants;
  final int maxParticipants;
  final bool canModify;

  /// Тап по свободному месту в паре: организатор выбирает, кого посадить.
  final void Function(AdminFlexPair pair) onFillSeat;

  /// Тап по пустой строке: открыть новую пару кем-то из состава.
  final VoidCallback onOpenNewPair;

  /// Меню игрока: статусы, пересадка, удаление.
  final void Function(AdminParticipant player) onPlayerMenu;

  /// Распустить пару.
  final void Function(AdminFlexPair pair) onDisbandPair;

  /// Быстрая посадка в первое свободное место.
  final void Function(AdminParticipant player) onSeatPlayer;

  const AdminFlexPairsView({
    super.key,
    required this.pairs,
    required this.participants,
    required this.maxParticipants,
    required this.canModify,
    required this.onFillSeat,
    required this.onOpenNewPair,
    required this.onPlayerMenu,
    required this.onDisbandPair,
    required this.onSeatPlayer,
  });

  @override
  Widget build(BuildContext context) {
    final seated = pairs.seatedIds;
    final pool = participants.where((p) => !seated.contains(p.id)).toList();
    final unpaired = pool.where((p) => p.status == 'registered').toList();
    final pending = pool.where((p) => p.status == 'pending').toList();
    final waiting = pool.where((p) => p.status == 'waiting').toList();

    final inRoster =
        participants.where((p) => p.status != 'waiting').length;
    final emptyRows = (pairs.maxPairs - pairs.pairs.length).clamp(0, 99);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _counters(inRoster),
        const SizedBox(height: 12),

        for (final pair in pairs.pairs) ...[
          _pairRow(pair),
          const SizedBox(height: 8),
        ],
        for (var i = 0; i < emptyRows; i++) ...[
          _emptyRow(pairs.pairs.length + i + 1),
          const SizedBox(height: 8),
        ],

        if (unpaired.isNotEmpty)
          _pool(
            title: 'Без пары',
            hint: 'в составе, но места в сетке нет',
            // Насыщенный фиолетовый, а не бледный AppTheme.purple: синий
            // занят очередью, жёлтый — модерацией.
            color: _violet,
            players: unpaired,
            seatable: true,
          ),
        if (pending.isNotEmpty)
          _pool(
            title: 'На модерации, без пары',
            hint: 'заявка ждёт решения',
            color: AppTheme.orange,
            players: pending,
            seatable: true,
          ),
        if (waiting.isNotEmpty)
          _pool(
            title: 'Лист ожидания',
            hint: 'вне состава — посадите, когда освободится место',
            color: AppTheme.blue,
            players: waiting,
            seatable: true,
          ),
      ],
    );
  }

  Widget _counters(int inRoster) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _chip('пар ${pairs.pairs.length} / ${pairs.maxPairs}', AppTheme.accent),
        _chip('игроков $inRoster / $maxParticipants', AppTheme.textSecondary),
      ],
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _pairRow(AdminFlexPair pair) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _number(pair.position),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  pair.isFull ? 'ср. ${pair.ratingAvg}' : 'пара не собрана',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ),
              if (canModify)
                IconButton(
                  onPressed: () => onDisbandPair(pair),
                  icon: Icon(Icons.close, size: 18, color: AppTheme.error),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Распустить пару',
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (pair.player1 != null) _seat(pair.player1!),
          const SizedBox(height: 6),
          if (pair.player2 != null)
            _seat(pair.player2!)
          else
            _freeSeat(
              label: canModify ? 'Посадить второго' : 'Место свободно',
              onTap: canModify ? () => onFillSeat(pair) : null,
            ),
        ],
      ),
    );
  }

  Widget _emptyRow(int position) {
    return Opacity(
      opacity: 0.55,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            _number(position),
            const SizedBox(width: 8),
            Expanded(
              child: _freeSeat(
                label: canModify ? 'Открыть пару' : 'Свободно',
                onTap: canModify ? onOpenNewPair : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _number(int position) {
    return SizedBox(
      width: 22,
      child: Text(
        '$position',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _seat(AdminParticipant player) {
    final tag = switch (player.status) {
      'pending' => ('на модерации', AppTheme.orange),
      'waiting' => ('лист ожидания', AppTheme.blue),
      _ => null,
    };

    return InkWell(
      onTap: canModify ? () => onPlayerMenu(player) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardRaised,
          borderRadius: BorderRadius.circular(12),
          border: tag == null
              ? null
              : Border(left: BorderSide(color: tag.$2, width: 3)),
        ),
        child: Row(
          children: [
            PlayerAvatar(
              name: player.name,
              avatarUrl: player.avatarUrl,
              size: 34,
              circle: true,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Метка статуса — второй строкой: рядом с именем она
                  // выдавливала строку за экран на длинных именах.
                  Row(
                    children: [
                      if (tag != null) ...[
                        Flexible(child: _chip(tag.$1, tag.$2)),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          [
                            if (player.level != null)
                              player.level!.toStringAsFixed(2),
                            if (player.phone != null && player.phone!.isNotEmpty)
                              player.phone!,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${player.rating ?? 0}',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (canModify) ...[
              const SizedBox(width: 4),
              Icon(Icons.more_vert, size: 18, color: AppTheme.textSecondary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _freeSeat({required String label, VoidCallback? onTap}) {
    final active = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? AppTheme.accent.withValues(alpha: 0.45)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              active ? Icons.add : Icons.remove,
              size: 18,
              color: active ? AppTheme.accent : AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: active ? AppTheme.accent : AppTheme.textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pool({
    required String title,
    required String hint,
    required Color color,
    required List<AdminParticipant> players,
    required bool seatable,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              _chip('${players.length}', color),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            hint,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          for (final player in players) ...[
            Row(
              children: [
                Expanded(child: _seat(player)),
                if (canModify && seatable) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => onSeatPlayer(player),
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.accent.withValues(alpha: 0.16),
                      foregroundColor: AppTheme.accent,
                      minimumSize: const Size(0, 38),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'посадить',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
