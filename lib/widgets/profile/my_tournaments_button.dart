import 'package:flutter/material.dart';

import '../../screens/my_tournaments_screen.dart';
import 'profile_menu_card.dart';

/// Кнопка «Мои турниры» в профиле. Открывает экран турниров с вкладкой «Мои»,
/// где показаны записанные на участие будущие/идущие турниры.
class MyTournamentsButton extends StatelessWidget {
  const MyTournamentsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      accent: const Color(0xFFF0A23B),
      icon: Icons.event_available,
      title: 'Мои турниры',
      sub: 'Те, на которые ты записан',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const MyTournamentsScreen(),
          ),
        );
      },
    );
  }
}
