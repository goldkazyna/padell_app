import 'package:flutter/material.dart';
import '../models/club.dart';
import '../theme/app_theme.dart';

class CourtScheduleScreen extends StatelessWidget {
  final Club club;

  const CourtScheduleScreen({super.key, required this.club});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          club.name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: const Center(
        child: Text(
          'Расписание — следующий шаг',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}
