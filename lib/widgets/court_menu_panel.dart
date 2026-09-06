import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'court_grid_background.dart';

/// Панель-корт: рамка, разметка и зоны вместо кнопок.
///
/// Появилась в меню профиля вместо шести цветных карточек во всю ширину и
/// оттуда же переехала на главную: два блока подряд должны быть одним
/// приёмом, а не двумя похожими. Ряды разделены акцентной линией — она же
/// сетка корта, колонки — белой разметкой.
class CourtMenuPanel extends StatelessWidget {
  /// Ряды по две зоны: [CourtMenuRow].
  final List<Widget> rows;

  const CourtMenuPanel({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.42),
            width: 1.5,
          ),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF16281F), Color(0xFF12211C), Color(0xFF0D1714)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: CourtGridBackground()),
            Column(children: rows),
          ],
        ),
      ),
    );
  }
}

/// Ряд из двух зон: вертикальная линия между ними — как разметка корта,
/// горизонтальная снизу — акцентная, она же граница половин.
class CourtMenuRow extends StatelessWidget {
  /// Ячейки ряда: две широкие (как в профиле) или четыре узкие.
  final List<Widget> cells;

  /// Линия снизу — у последнего ряда её нет.
  final bool divider;

  const CourtMenuRow.cells({
    super.key,
    required this.cells,
    this.divider = true,
  });

  CourtMenuRow({
    super.key,
    required Widget left,
    required Widget right,
    this.divider = true,
  }) : cells = [left, right];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: divider
            ? Border(
                bottom: BorderSide(
                  color: AppTheme.accent.withValues(alpha: 0.26),
                  width: 1.5,
                ),
              )
            : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < cells.length; i++)
              Expanded(
                // Разметка между колонками; у последней её нет — там рамка.
                child: i == cells.length - 1
                    ? cells[i]
                    : DecoratedBox(
                        decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(
                              color: Color(0x1AFFFFFF),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: cells[i],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Одна зона корта: иконка, число или бейдж, название и подпись.
class CourtMenuZone extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  /// Число справа сверху (сколько турниров, сыграно и так далее).
  final String? value;
  final Color? valueColor;

  /// Красный кружок с числом — там, где ждут ответа.
  final int badge;

  /// Короткая метка вместо числа: «NEW». Показывается, когда числа нет.
  final String? tag;

  /// Акцентная иконка (свои ближайшие турниры).
  final bool accent;

  /// Зона, которая умеет тревожить: пока бейдж пуст — обычная, с бейджем
  /// краснеет иконка и фон. Красный без дела быстро перестают замечать.
  final bool alert;

  /// Узкая зона: иконка и название, без подписи. Для ряда из четырёх.
  final bool compact;

  final VoidCallback onTap;

  const CourtMenuZone({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.value,
    this.valueColor,
    this.badge = 0,
    this.tag,
    this.accent = false,
    this.alert = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final alarmed = alert && badge > 0;

    final iconColor = alarmed
        ? AppTheme.error
        : (accent ? AppTheme.accent : AppTheme.textPrimary);
    final iconBg = alarmed
        ? AppTheme.error.withValues(alpha: 0.16)
        : (accent
            ? AppTheme.accent.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.06));
    final iconBorder = alarmed
        ? AppTheme.error.withValues(alpha: 0.32)
        : (accent
            ? AppTheme.accent.withValues(alpha: 0.32)
            : Colors.white.withValues(alpha: 0.08));

    if (compact) return _compact(alarmed, iconColor, iconBg, iconBorder);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 94),
        color: alarmed ? AppTheme.error.withValues(alpha: 0.10) : null,
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: iconBorder),
                  ),
                  child: Icon(icon, size: 17, color: iconColor),
                ),
                const Spacer(),
                if (badge > 0)
                  Container(
                    constraints: const BoxConstraints(minWidth: 20),
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      badge > 99 ? '99+' : '$badge',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else if (value != null)
                  Text(
                    value!,
                    style: TextStyle(
                      color: valueColor ?? AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  )
                else if (tag != null)
                  Container(
                    height: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppTheme.accent.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      tag!,
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  )
                else
                  Icon(Icons.chevron_right, size: 16, color: AppTheme.textDim),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Узкий вариант: иконка по центру, название под ней, метка углом.
  Widget _compact(
    bool alarmed,
    Color iconColor,
    Color iconBg,
    Color iconBorder,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 84),
        color: alarmed ? AppTheme.error.withValues(alpha: 0.10) : null,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: iconBorder),
                  ),
                  child: Icon(icon, size: 17, color: iconColor),
                ),
                if (badge > 0 || value != null || tag != null)
                  Positioned(
                    top: -6,
                    right: -10,
                    child: Container(
                      height: 17,
                      constraints: const BoxConstraints(minWidth: 17),
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badge > 0
                            ? AppTheme.error
                            : AppTheme.accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: badge > 0
                              ? AppTheme.error
                              : AppTheme.accent.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        badge > 0 ? '${badge > 99 ? '99+' : badge}' : (value ?? tag!),
                        style: TextStyle(
                          color: badge > 0 ? Colors.white : AppTheme.accent,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
