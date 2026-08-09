import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/my_trainings_screen.dart';
import '../../services/training_service.dart';
import 'profile_menu_card.dart';

/// Кнопка «Мои тренировки» в профиле (под «Приглашения на турнир»).
/// Бейдж показывает, на скольких занятиях игрок записан.
class MyTrainingsButton extends StatefulWidget {
  const MyTrainingsButton({super.key});

  @override
  State<MyTrainingsButton> createState() => _MyTrainingsButtonState();
}

class _MyTrainingsButtonState extends State<MyTrainingsButton> {
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    final counts = await context.read<TrainingService>().getCounts();
    if (!mounted) return;
    setState(() => _count = counts.upcoming);
  }

  Future<void> _open() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MyTrainingsScreen()),
    );
    _loadCount();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileCard(
      accent: const Color(0xFF22C55E),
      icon: Icons.fitness_center_outlined,
      title: 'Мои тренировки',
      sub: 'Занятия, на которые ты записан',
      badge: _count,
      onTap: _open,
    );
  }
}
