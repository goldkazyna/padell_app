import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

/// Плавающая «таблетка» нижнего меню.
///
/// Живёт не только на главном экране: вложенные экраны, из которых человек
/// продолжает ходить по приложению (например, лига), показывают её у себя,
/// чтобы меню не пропадало под ногами. Внешний вид один на всех — поэтому
/// он и вынесен сюда.
class MainNavPill extends StatelessWidget {
  /// Подсвеченная вкладка.
  final int current;

  /// Профиль не заполнен: часть вкладок закрыта.
  final bool profileIncomplete;

  /// Выбрали доступную вкладку.
  final ValueChanged<int> onSelect;

  /// Тапнули по закрытой вкладке — показать «заполните профиль».
  final VoidCallback onLockedTap;

  const MainNavPill({
    super.key,
    required this.current,
    required this.onSelect,
    required this.onLockedTap,
    this.profileIncomplete = false,
  });

  /// Вкладки, закрытые до заполнения профиля.
  static const Set<int> lockedTabs = {1, 2, 3};

  /// Сколько места оставить снизу в прокручиваемом содержимом, чтобы
  /// таблетка не накрывала последний элемент.
  static const double contentInset = 96;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.background.withValues(alpha: 0.30),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
          ),
          // Подпись авто-ужимается (FittedBox), всегда влезает целиком.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.0,
            // Высота фиксированная: иначе пересчёт раскладки дёргает ленту
            // при скролле.
            child: SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _item(0, Icons.home_outlined, Icons.home, l10n.navHome),
                  _item(1, Icons.emoji_events_outlined, Icons.emoji_events,
                      l10n.navTournaments),
                  _item(2, Icons.calendar_month_outlined, Icons.calendar_month,
                      l10n.navBooking),
                  _item(3, Icons.leaderboard_outlined, Icons.leaderboard,
                      l10n.navRating),
                  _item(4, Icons.person_outline, Icons.person, l10n.navProfile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Один таб. Подпись в FittedBox(scaleDown) — ужимается под ширину таба и
  /// влезает целиком при любом системном шрифте.
  Widget _item(int idx, IconData inactive, IconData active, String label) {
    final selected = current == idx;
    final locked = profileIncomplete && lockedTabs.contains(idx);
    final color = selected ? AppTheme.accent : AppTheme.textSecondary;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => locked ? onLockedTap() : onSelect(idx),
        child: Opacity(
          opacity: locked ? 0.35 : 1.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(selected ? active : inactive, color: color, size: 24),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
