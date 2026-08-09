import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/training.dart';
import '../services/training_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';
import 'training_detail_screen.dart';

/// Ближайшие тренировки: список по дате, ближайшие сверху.
class TrainingsScreen extends StatefulWidget {
  const TrainingsScreen({super.key});

  @override
  State<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends State<TrainingsScreen> {
  List<Training> _trainings = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await context.read<TrainingService>().getUpcoming();
      if (!mounted) return;
      setState(() {
        _trainings = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _open(Training t) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TrainingDetailScreen(trainingId: t.id)),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
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
                  Text(
                    'Тренировки',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
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
            'Пока нет запланированных тренировок.\nЗаглядывайте позже.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: _trainings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) => TrainingCard(
          training: _trainings[i],
          onTap: () => _open(_trainings[i]),
        ),
      ),
    );
  }
}

/// Карточка тренировки в списке: когда, где, у кого, почём и сколько мест.
class TrainingCard extends StatelessWidget {
  final Training training;
  final VoidCallback onTap;

  const TrainingCard({super.key, required this.training, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = training;
    final noSlots = t.freeSlots <= 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: t.isJoined ? AppTheme.accent : AppTheme.border,
            width: t.isJoined ? 1.4 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.event_outlined, size: 16, color: AppTheme.accent),
                const SizedBox(width: 6),
                Text(
                  '${t.date}, ${t.time}',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${t.durationMinutes} мин',
                  style: TextStyle(color: AppTheme.textDim, fontSize: 12),
                ),
                const Spacer(),
                if (t.isJoined)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('Вы записаны',
                        style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if ((t.coach?.name ?? '').isNotEmpty)
              Row(
                children: [
                  Icon(Icons.sports_tennis_outlined,
                      size: 15, color: AppTheme.textSecondary),
                  const SizedBox(width: 6),
                  Text(t.coach!.name,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.place_outlined,
                    size: 15, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    t.club.name,
                    style:
                        TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  t.priceLabel,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  noSlots
                      ? 'Мест нет'
                      : 'Свободно ${t.freeSlots} из ${t.capacity}',
                  style: TextStyle(
                    color: noSlots ? AppTheme.textDim : AppTheme.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
