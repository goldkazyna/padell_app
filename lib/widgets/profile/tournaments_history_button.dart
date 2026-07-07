import 'package:flutter/material.dart';

import '../../screens/my_tournaments_history_screen.dart';
import 'profile_menu_card.dart';

/// Кнопка «История турниров» в профиле. Открывает экран со всеми
/// сыгранными турнирами пользователя.
class TournamentsHistoryButton extends StatelessWidget {
  const TournamentsHistoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      accent: const Color(0xFF2ECF72),
      icon: Icons.history,
      title: 'История турниров',
      sub: 'Все сыгранные турниры',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const MyTournamentsHistoryScreen(),
          ),
        );
      },
    );
  }
}
