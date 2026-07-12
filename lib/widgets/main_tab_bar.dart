import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../providers/main_tab_notifier.dart';
import '../theme/app_theme.dart';

/// Нижнее меню как у [MainScreen] — повторяет 5 вкладок.
/// Используется на «вспомогательных» pushed-экранах (карточка игрока,
/// детализация турнира), чтобы пользователь мог переключиться сразу
/// на нужную вкладку, не выходя руками.
///
/// При тапе:
/// 1) [mainTabNotifier.value] = выбранный индекс
/// 2) [Navigator.popUntil] до корневого роута (MainScreen),
///    который слушает notifier и встаёт на нужный таб.
class MainTabBar extends StatelessWidget {
  const MainTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final current = mainTabNotifier.value;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        border: Border(
          top: BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: current,
        onTap: (index) {
          mainTabNotifier.value = index;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.card,
        selectedItemColor: AppTheme.accent,
        unselectedItemColor: AppTheme.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: l.navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.emoji_events_outlined),
            activeIcon: const Icon(Icons.emoji_events),
            label: l.navTournaments,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month_outlined),
            activeIcon: const Icon(Icons.calendar_month),
            label: l.navBooking,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.leaderboard_outlined),
            activeIcon: const Icon(Icons.leaderboard),
            label: l.navRating,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: l.navProfile,
          ),
        ],
      ),
    );
  }
}
