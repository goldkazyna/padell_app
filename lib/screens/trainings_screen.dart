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

  /// Инициалы для заглушки: у клуба — первые буквы слов названия,
  /// у тренера — имени и фамилии.
  static String _initials(String name, {int max = 2}) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    return parts.take(max).map((part) => part[0].toUpperCase()).join();
  }

  Widget _coachAvatar() {
    final url = training.coach?.avatar;
    final hasPhoto = url != null && url.isNotEmpty;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.cardRaised,
        image: hasPhoto
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: hasPhoto
          ? null
          : Text(
              _initials(training.coach?.name ?? ''),
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  Widget _clubLogo() {
    final url = training.club.logo;
    final hasLogo = url != null && url.isNotEmpty;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: AppTheme.cardRaised,
        image: hasLogo
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: hasLogo
          ? null
          : Text(
              _initials(training.club.name),
              style: TextStyle(
                color: AppTheme.textDim,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = training;
    final noSlots = t.freeSlots <= 0;
    // Полоска набора — доля занятых мест. Последнее место подсвечиваем
    // жёлтым, при полном наборе гасим.
    final taken = (t.capacity - t.freeSlots).clamp(0, t.capacity);
    final fill = t.capacity > 0 ? taken / t.capacity : 0.0;
    final lastSpot = !noSlots && t.freeSlots == 1;
    final slotsColor = noSlots
        ? AppTheme.textDim
        : (lastSpot ? AppTheme.amber : AppTheme.accent);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _coachAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${t.date}, ${t.time}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${t.durationMinutes} мин',
                            style: TextStyle(
                                color: AppTheme.textDim, fontSize: 12),
                          ),
                        ],
                      ),
                      if ((t.coach?.name ?? '').isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          t.coach!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _clubLogo(),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              t.club.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (t.isJoined) ...[
                  const SizedBox(width: 8),
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
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: fill,
                minHeight: 4,
                backgroundColor: AppTheme.cardRaised,
                valueColor: AlwaysStoppedAnimation(slotsColor),
              ),
            ),
            const SizedBox(height: 9),
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
                      : (lastSpot
                          ? 'Осталось 1 место'
                          : 'Свободно ${t.freeSlots} из ${t.capacity}'),
                  style: TextStyle(
                    color: slotsColor,
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
