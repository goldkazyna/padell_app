import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/training.dart';
import '../services/training_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_primary_button.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';

/// Тренировка глазами игрока: подробности и запись.
class TrainingDetailScreen extends StatefulWidget {
  final int trainingId;

  const TrainingDetailScreen({super.key, required this.trainingId});

  @override
  State<TrainingDetailScreen> createState() => _TrainingDetailScreenState();
}

class _TrainingDetailScreenState extends State<TrainingDetailScreen> {
  Training? _training;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final t = await context.read<TrainingService>().getOne(widget.trainingId);
      if (!mounted) return;
      setState(() {
        _training = t;
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

  Future<void> _toggleJoin() async {
    final t = _training;
    if (t == null || _busy) return;

    setState(() => _busy = true);
    try {
      final service = context.read<TrainingService>();
      if (t.isJoined) {
        await service.leave(t.id);
      } else {
        await service.join(t.id);
      }
      await _load();
      if (mounted) {
        await showAppAlert(
          context,
          t.isJoined ? 'Вы отписались от тренировки' : 'Вы записаны на тренировку',
        );
      }
    } catch (e) {
      if (mounted) {
        await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
                  Text('Тренировка',
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

    final t = _training;
    if (t == null) {
      return Center(
        child: Text(_error ?? 'Не удалось загрузить',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _card([
          _row(Icons.event_outlined, '${t.date}, ${t.time}'),
          _row(Icons.timelapse_outlined, '${t.durationMinutes} минут'),
          _row(Icons.place_outlined, t.club.name),
          if ((t.coach?.name ?? '').isNotEmpty)
            _row(Icons.sports_tennis_outlined, 'Тренер: ${t.coach!.name}'),
          _row(Icons.payments_outlined,
              t.price > 0 ? '${t.price} ₸' : 'Бесплатно'),
          _row(
            Icons.group_outlined,
            t.freeSlots > 0
                ? 'Свободно ${t.freeSlots} из ${t.capacity}'
                : 'Мест нет, записано ${t.participantsCount}',
          ),
        ]),
        if ((t.description ?? '').isNotEmpty) ...[
          const SizedBox(height: 12),
          _card([
            Text('Описание',
                style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(t.description!,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.35)),
          ]),
        ],
        const SizedBox(height: 20),
        _buildAction(t),
      ],
    );
  }

  Widget _buildAction(Training t) {
    if (t.isCancelled) {
      return _notice('Тренировка отменена тренером', AppTheme.orange);
    }
    if (t.isCompleted) {
      return _notice('Тренировка завершена', AppTheme.textDim);
    }

    // Записанному всегда даём отписаться, даже когда мест уже нет.
    if (!t.isJoined && !t.canJoin) {
      return _notice(
        t.freeSlots <= 0 ? 'Свободных мест нет' : 'Запись закрыта',
        AppTheme.textDim,
      );
    }

    // Отписка — действие «не основное», поэтому не зелёная кнопка.
    if (t.isJoined) {
      return SizedBox(
        height: 50,
        child: OutlinedButton.icon(
          onPressed: _busy ? null : _toggleJoin,
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Отписаться'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.textPrimary,
            side: BorderSide(color: AppTheme.border),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return SizedBox(
      height: 50,
      child: AppPrimaryButton(
        label: 'Записаться',
        icon: Icons.check,
        loading: _busy,
        onPressed: _busy ? null : _toggleJoin,
      ),
    );
  }

  Widget _notice(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 17, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
