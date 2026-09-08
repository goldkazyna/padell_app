import 'package:flutter/material.dart';

import '../../models/admin_flex_pairs.dart';
import '../../models/admin_participant.dart';
import '../../theme/app_theme.dart';
import '../player_avatar.dart';

/// Что можно сделать с игроком в составе парного флекса.
enum FlexPlayerAction { approve, toRegistered, toPending, toWaiting, remove }

/// Куда пересадить: [teamId] = 0 — открыть новую пару.
class FlexSeatTarget {
  final int teamId;
  final int seat;

  const FlexSeatTarget(this.teamId, this.seat);
}

/// Меню игрока в сетке пар.
///
/// Пунктов «пересадить» бывает под двадцать — на весь экран это читалось как
/// бесконечный список без начала и конца. Здесь шторка ровно по содержимому,
/// но не выше двух третей экрана, с шапкой «кого двигаем» и разделами.
Future<void> showAdminFlexPlayerMenu(
  BuildContext context, {
  required AdminParticipant player,
  required AdminFlexPairs pairs,
  required void Function(FlexPlayerAction action) onAction,
  required void Function(FlexSeatTarget target) onSeat,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.72,
          ),
          child: AdminFlexPlayerMenuBody(
            player: player,
            pairs: pairs,
            onAction: (a) {
              Navigator.pop(ctx);
              onAction(a);
            },
            onSeat: (t) {
              Navigator.pop(ctx);
              onSeat(t);
            },
            onClose: () => Navigator.pop(ctx),
          ),
        ),
      ),
    ),
  );
}

/// Содержимое меню отдельно от шторки — так его видно в тестах.
class AdminFlexPlayerMenuBody extends StatelessWidget {
  final AdminParticipant player;
  final AdminFlexPairs pairs;
  final void Function(FlexPlayerAction action) onAction;
  final void Function(FlexSeatTarget target) onSeat;
  final VoidCallback? onClose;

  const AdminFlexPlayerMenuBody({
    super.key,
    required this.player,
    required this.pairs,
    required this.onAction,
    required this.onSeat,
    this.onClose,
  });

  static String statusLabel(String? status) => switch (status) {
        'pending' => 'на модерации',
        'waiting' => 'лист ожидания',
        _ => 'в составе',
      };

  @override
  Widget build(BuildContext context) {
    final own = pairs.pairs.where((p) => p.has(player.id)).firstOrNull;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _header(own),
          Divider(height: 1, color: AppTheme.border),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                _section('СОСТАВ'),
                // Цвет статуса тот же, что в сетке и в вебе: модерация —
                // жёлтая, очередь — синяя, состав — зелёный.
                if (player.status == 'pending')
                  _item(
                    Icons.check,
                    'Одобрить заявку',
                    () => onAction(FlexPlayerAction.approve),
                    color: AppTheme.accent,
                  )
                else
                  _item(
                    Icons.hourglass_top,
                    'На модерацию',
                    () => onAction(FlexPlayerAction.toPending),
                    color: AppTheme.orange,
                  ),
                if (player.status != 'registered')
                  _item(
                    Icons.how_to_reg,
                    'В основной список',
                    () => onAction(FlexPlayerAction.toRegistered),
                    color: AppTheme.accent,
                  ),
                if (player.status != 'waiting')
                  _item(
                    Icons.hourglass_empty,
                    'В лист ожидания',
                    () => onAction(FlexPlayerAction.toWaiting),
                    color: AppTheme.blue,
                    note: 'освободит место',
                  ),
                ..._moves(own),
                Divider(height: 1, color: AppTheme.border),
                _item(
                  Icons.close,
                  'Убрать из турнира',
                  () => onAction(FlexPlayerAction.remove),
                  color: AppTheme.error,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(AdminFlexPair? own) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
      child: Row(
        children: [
          PlayerAvatar(
            name: player.name,
            avatarUrl: player.avatarUrl,
            size: 40,
            circle: true,
          ),
          const SizedBox(width: 12),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${statusLabel(player.status)}, '
                  '${own == null ? 'без пары' : 'пара ${own.position}'}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, size: 20, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  List<Widget> _moves(AdminFlexPair? own) {
    final moves = <Widget>[
      // В пустую пару зовём только того, кто занимает место в полной: тому,
      // кто и так один в паре, переезжать некуда.
      if (pairs.canCreatePair && own?.isFull != false)
        _item(
          Icons.add_box_outlined,
          'Открыть новую пару',
          () => onSeat(const FlexSeatTarget(0, 2)),
          color: AppTheme.accent,
          note: 'строка ${pairs.nextPosition}',
        ),
      for (final target in pairs.pairs)
        if (target.id != own?.id) ...[
          if (target.player2 == null)
            _item(
              Icons.person_add_alt,
              'Пара ${target.position} · свободное место',
              () => onSeat(FlexSeatTarget(target.id, 2)),
              note: target.player1?.name,
            )
          else ...[
            _item(
              Icons.swap_horiz,
              'Пара ${target.position} · вместо: ${target.player1?.name ?? '—'}',
              () => onSeat(FlexSeatTarget(target.id, 1)),
              note: 'обмен',
            ),
            _item(
              Icons.swap_horiz,
              'Пара ${target.position} · вместо: ${target.player2?.name ?? '—'}',
              () => onSeat(FlexSeatTarget(target.id, 2)),
              note: 'обмен',
            ),
          ],
        ],
    ];

    if (moves.isEmpty) return const [];

    return [
      Divider(height: 1, color: AppTheme.border),
      _section('ПЕРЕСАДИТЬ'),
      ...moves,
    ];
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _item(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
    String? note,
  }) {
    final tint = color ?? AppTheme.textSecondary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Иконка в плашке своего цвета: так действие узнаётся раньше,
            // чем прочитан текст, — как блоки статусов в вебе.
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 18, color: tint),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  // Текст красим только у опасного действия: пять цветных
                  // строк подряд читаются как гирлянда.
                  color: color == AppTheme.error
                      ? AppTheme.error
                      : AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (note != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  note,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
