import 'package:flutter/material.dart';

import '../../screens/my_leagues_screen.dart';
import 'profile_menu_card.dart';

/// Кнопка «Мои лиги» в профиле: где играю и на каком месте.
class MyLeaguesButton extends StatelessWidget {
  const MyLeaguesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      accent: const Color(0xFF7C3AED),
      icon: Icons.emoji_events_outlined,
      title: 'Мои лиги',
      sub: 'Место в общей таблице и этапы',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MyLeaguesScreen()),
        );
      },
    );
  }
}
