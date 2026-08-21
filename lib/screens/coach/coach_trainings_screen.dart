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

  /// Активная вкладка: all / upcoming / awaiting / completed / cancelled.
  String _tab = 'all';

  /// Тренировка попадает в одну вкладку: отменённые и завершённые — по
  /// статусу, остальные делим по дате (прошедшие ждут проведения).
  String _bucketOf(Training t) {
    if (t.isCancelled) return 'cancelled';
    if (t.isCompleted) return 'completed';
    return t.isPast ? 'awaiting' : 'upcoming';
  }

  List<Training> get _filtered => _tab == 'all'
      ? _trainings
      : _trainings.where((t) => _bucketOf(t) == _tab).toList();

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

  Future<void> _edit(Training t) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CoachCreateTrainingScreen(training: t),
      ),
    );
    if (saved == true) {
      _load();
      if (mounted) await showAppAlert(context, 'Тренировка изменена');
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
            if (!_loading && _error == null && _trainings.isNotEmpty)
              _buildTabs(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  /// Вкладки статусов со счётчиками — как в списке турниров у админа.
  Widget _buildTabs() {
    const tabs = [
      ('all', 'Все'),
      ('upcoming', 'Запланированы'),
      ('awaiting', 'Ждут завершения'),
      ('completed', 'Завершены'),
      ('cancelled', 'Отменены'),
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (key, label) = tabs[i];
          final count = key == 'all'
              ? _trainings.length
              : _trainings.where((t) => _bucketOf(t) == key).length;
          final isActive = _tab == key;

          // Пустые вкладки не прячем: пропавшая на глазах вкладка сбивает,
          // а ноль сразу говорит, что там ничего нет.
          return GestureDetector(
            onTap: () => setState(() => _tab = key),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.accent.withAlpha(40) : AppTheme.card,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isActive
                      ? AppTheme.accent.withAlpha(120)
                      : const Color(0xFF2A3330),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isActive ? AppTheme.accent : AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.accent.withAlpha(80)
                          : const Color(0xFF27272A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isActive ? AppTheme.accent : AppTheme.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

    final list = _filtered;

    return RefreshIndicator(
      onRefresh: _load,
      child: list.isEmpty
          // ListView, а не Center: иначе на пустой вкладке не работает
          // «потянуть, чтобы обновить».
          ? ListView(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 90),
              children: [
                Text(
                  'В этой вкладке пусто',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _card(list[i]),
            ),
    );
  }

  Widget _card(Training t) {
    final (statusText, statusColor) = switch (t.status) {
      'cancelled' => ('отменена', AppTheme.orange),
      'completed' => ('завершена', AppTheme.textDim),
      _ => t.isPast ? ('ждёт завершения', AppTheme.blue) : ('запланирована', AppTheme.accent),
    };

    final spotsLeft = t.capacity - t.participantsCount;
    final isFull = spotsLeft <= 0;
    final fill = t.capacity > 0
        ? (t.participantsCount / t.capacity).clamp(0.0, 1.0)
        : 0.0;

    return Opacity(
      // Отменённые приглушаем: они остаются в списке, но не тянут взгляд.
      opacity: t.isCancelled ? 0.55 : 1,
      child: InkWell(
      onTap: () => _open(t),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: statusColor == AppTheme.accent
                ? AppTheme.accent.withAlpha(60)
                : AppTheme.border,
          ),
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
                // Править можно только запланированные: завершённые и
                // отменённые сервер менять не даёт.
                if (!t.isCancelled && !t.isCompleted) ...[
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _edit(t),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(Icons.edit_outlined,
                          size: 17, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place_outlined,
                    size: 14, color: AppTheme.textDim),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(t.club.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.group_outlined,
                    size: 15, color: AppTheme.textSecondary),
                const SizedBox(width: 6),
                Text('${t.participantsCount} из ${t.capacity}',
                    style: TextStyle(
                        color: isFull ? AppTheme.accent : AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                if (!t.isCancelled && !t.isCompleted && !isFull) ...[
                  const SizedBox(width: 6),
                  Text('· свободно $spotsLeft',
                      style:
                          TextStyle(color: AppTheme.textDim, fontSize: 12)),
                ],
                const Spacer(),
                Text(t.priceLabel,
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 10),
            // Полоска набора: видно с одного взгляда, сколько мест закрыто.
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fill,
                minHeight: 4,
                backgroundColor: AppTheme.cardRaised,
                valueColor: AlwaysStoppedAnimation(
                  isFull ? AppTheme.accent : statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
