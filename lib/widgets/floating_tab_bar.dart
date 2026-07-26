import 'dart:ui';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../providers/main_tab_notifier.dart';
import '../theme/app_theme.dart';

/// Плавающая «таблетка»-меню (как в [MainScreen]) для вложенных pushed-экранов.
///
/// Возвращает [Positioned], поэтому ставится прямым child внутри Stack:
/// ```
/// body: Stack(children: [content, const FloatingTabBar()])
/// ```
/// (у скроллящегося контента снизу оставляйте отступ ~100, чтобы таблетка
/// не перекрывала последние элементы).
///
/// При тапе: [mainTabNotifier] = индекс + popUntil до корня (MainScreen),
/// который встаёт на нужную вкладку.
class FloatingTabBar extends StatelessWidget {
  const FloatingTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final current = mainTabNotifier.value;
    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomInset > 0 ? bottomInset : 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.background.withOpacity(0.30),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF2A3330), width: 0.5),
            ),
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.0,
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    _item(context, 0, Icons.home_outlined, Icons.home,
                        l.navHome, current),
                    _item(context, 1, Icons.emoji_events_outlined,
                        Icons.emoji_events, l.navTournaments, current),
                    _item(context, 2, Icons.calendar_month_outlined,
                        Icons.calendar_month, l.navBooking, current),
                    _item(context, 3, Icons.leaderboard_outlined,
                        Icons.leaderboard, l.navRating, current),
                    _item(context, 4, Icons.person_outline, Icons.person,
                        l.navProfile, current),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, int idx, IconData inactive,
      IconData active, String label, int current) {
    final selected = current == idx;
    final color = selected ? AppTheme.accent : AppTheme.textSecondary;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          mainTabNotifier.value = idx;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
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
                      color: color, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
