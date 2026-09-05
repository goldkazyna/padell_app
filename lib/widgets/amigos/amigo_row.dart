import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/amigo.dart';
import '../../theme/app_theme.dart';
import '../player_avatar.dart';

/// Строка амигос: аватар, имя, уровень и чем человек занят.
///
/// Статус справа — не украшение, а вход: «играет» ведёт в трансляцию,
/// «турнир 19:00» — в турнир, «ищет игроков» — в игру. Поэтому у бейджа свой
/// обработчик, отдельный от тапа по строке.
class AmigoRow extends StatelessWidget {
  final Amigo amigo;

  /// Тап по строке — обычно профиль игрока.
  final VoidCallback? onTap;

  /// Тап по статусу — трансляция, турнир или игра.
  final VoidCallback? onStatusTap;

  /// Кнопка справа вместо статуса: «В ответ» на вкладке «меня добавили».
  final Widget? trailing;

  const AmigoRow({
    super.key,
    required this.amigo,
    this.onTap,
    this.onStatusTap,
    this.trailing,
  });

  /// Подпись статуса своими словами: с сервера приходит вид и время,
  /// а текст у приложения на трёх языках свой.
  String _statusLabel(AppLocalizations l10n, AmigoStatus status) {
    final when = status.startsAt == null
        ? ''
        : ' ${DateFormat('HH:mm').format(status.startsAt!.toLocal())}';

    return switch (status.kind) {
      'playing' => l10n.amigoPlaying,
      'soon' => '${l10n.amigoTournament}$when',
      'looking' => l10n.amigoLooking,
      _ => status.title,
    };
  }

  Color _statusColor(AmigoStatus status) {
    return status.isSoon ? AppTheme.orange : AppTheme.accent;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = amigo.status;

    final meta = <String>[
      if (amigo.level != null) 'ур. ${amigo.level!.toStringAsFixed(2)}',
      if (amigo.rating > 0) '${amigo.rating}',
      if (amigo.mutual) l10n.amigosMutual,
    ].join(' · ');

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // Кольцо вокруг аватара у играющих: видно и без чтения бейджа.
            Container(
              decoration: status?.isPlaying == true
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accent, width: 1.5),
                    )
                  : null,
              padding: status?.isPlaying == true
                  ? const EdgeInsets.all(2)
                  : EdgeInsets.zero,
              child: PlayerAvatar(
                name: amigo.name,
                avatarUrl: amigo.avatar,
                size: status?.isPlaying == true ? 34 : 38,
                circle: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amigo.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status != null && status.subtitle.isNotEmpty
                        ? status.subtitle
                        : meta,
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
            const SizedBox(width: 10),
            if (trailing != null)
              trailing!
            else if (status != null)
              _StatusBadge(
                label: _statusLabel(l10n, status),
                color: _statusColor(status),
                pulsing: status.isPlaying,
                onTap: status.hasTarget ? onStatusTap : null,
              )
            else
              Icon(Icons.chevron_right, size: 18, color: AppTheme.textDim),
          ],
        ),
      ),
    );
  }
}

/// Бейдж статуса: капсы, фон цветом статуса, точка у идущей игры.
class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool pulsing;
  final VoidCallback? onTap;

  const _StatusBadge({
    required this.label,
    required this.color,
    this.pulsing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (pulsing) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
