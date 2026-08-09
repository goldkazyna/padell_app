import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/training.dart';
import '../../services/training_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';
import 'coach_create_training_screen.dart';
import 'coach_training_detail_screen.dart';

/// Тренировки тренера: список своих занятий и кнопка создания.
class CoachTrainingsScreen extends StatefulWidget {
  const CoachTrainingsScreen({super.key});

  @override
  State<CoachTrainingsScreen> createState() => _CoachTrainingsScreenState();
}

class _CoachTrainingsScreenState extends State<CoachTrainingsScreen> {
  List<Training> _trainings = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await context.read<TrainingService>().getCoachTrainings();
      if (!mounted) return;
      setState(() {
        _trainings = list;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _create() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const CoachCreateTrainingScreen()),
    );
    if (created == true) {
      _load();
      if (mounted) await showAppAlert(context, 'Тренировка создана');
    }
  }

  Future<void> _open(Training t) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachTrainingDetailScreen(trainingId: t.id),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Тренировка',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const SizedBox(width: 12),
                  Text('Мои тренировки',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary)),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: const Text('Повторить')),
            ],
          ),
        ),
      );
    }
    if (_trainings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Тренировок пока нет.\nНажмите «Тренировка», чтобы создать первую.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
        itemCount: _trainings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => _card(_trainings[i]),
      ),
    );
  }

  Widget _card(Training t) {
    final (statusText, statusColor) = switch (t.status) {
      'cancelled' => ('отменена', AppTheme.orange),
      'completed' => ('завершена', AppTheme.textDim),
      _ => t.isPast ? ('ждёт завершения', AppTheme.blue) : ('запланирована', AppTheme.accent),
    };

    return InkWell(
      onTap: () => _open(t),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${t.date}, ${t.time}',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Text('${t.durationMinutes} мин',
                    style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(t.club.name,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.group_outlined, size: 15, color: AppTheme.accent),
                const SizedBox(width: 6),
                Text('${t.participantsCount} из ${t.capacity}',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(t.price > 0 ? '${t.price} ₸' : 'Бесплатно',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
