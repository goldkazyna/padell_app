import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/training.dart';
import '../services/training_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_primary_button.dart';
import '../utils/app_alert.dart';
import '../widgets/app_back_button.dart';
import '../widgets/training_seats.dart';
import 'player_profile_screen.dart';
import 'club_detail_screen.dart';

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

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            children: [
              if ((t.coach?.name ?? '').isNotEmpty) ...[
                _coachCard(t),
                const SizedBox(height: 10),
              ],
              _clubCard(t),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _fact('Начало', '${t.date}, ${t.time}')),
                  const SizedBox(width: 10),
                  Expanded(child: _fact('Длится', '${t.durationMinutes} мин')),
                ],
              ),
              const SizedBox(height: 14),
              _sectionLabel('УЧАСТНИКИ · ${t.participantsCount} из ${t.capacity}'),
              _card([
                TrainingSeats(
                  training: t,
                  // Тап по свободному кружку записывает так же, как кнопка внизу.
                  onTapFree: t.canJoin && !_busy ? _toggleJoin : null,
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
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          height: 1.35)),
                ]),
              ],
            ],
          ),
        ),
        // Кнопка прилипает к низу: до неё не нужно докручивать список.
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: BoxDecoration(
            color: AppTheme.background,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: _buildAction(t),
        ),
      ],
    );
  }

  /// Тренер — первый блок: на занятие идут к человеку.
  Widget _coachCard(Training t) {
    final coach = t.coach!;
    final canOpen = (coach.id ?? 0) > 0;

    return InkWell(
      onTap: canOpen
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlayerProfileScreen(
                    playerId: coach.id!,
                    playerName: coach.name,
                  ),
                ),
              )
          : null,
      borderRadius: BorderRadius.circular(14),
      child: _card([
        Row(
          children: [
            _avatar(url: coach.avatar, text: coach.name, size: 58),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coach.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('тренер',
                      style:
                          TextStyle(color: AppTheme.textDim, fontSize: 12)),
                ],
              ),
            ),
            if (canOpen)
              Icon(Icons.chevron_right, color: AppTheme.textDim, size: 20),
          ],
        ),
      ]),
    );
  }

  /// Площадка: логотип, город и адрес, переход в карточку клуба.
  Widget _clubCard(Training t) {
    final club = t.club;
    final canOpen = (club.id ?? 0) > 0;
    final place = club.placeLine;

    return InkWell(
      onTap: canOpen
          ? () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClubDetailScreen(clubId: club.id!),
                ),
              )
          : null,
      borderRadius: BorderRadius.circular(14),
      child: _card([
        Row(
          children: [
            _avatar(url: club.logo, text: club.name, size: 34, rounded: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(club.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  if (place.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(place,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppTheme.textDim, fontSize: 12)),
                  ],
                ],
              ),
            ),
            if (canOpen)
              Icon(Icons.chevron_right, color: AppTheme.textDim, size: 20),
          ],
        ),
      ]),
    );
  }

  /// Плашка «подпись + значение» для времени и длительности.
  Widget _fact(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: AppTheme.textDim, fontSize: 11)),
          const SizedBox(height: 3),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  /// Фото с монограммой вместо заглушки: пустой круг выглядит как ошибка.
  Widget _avatar({
    required String? url,
    required String text,
    required double size,
    bool rounded = false,
  }) {
    final hasImage = url != null && url.isNotEmpty;
    final parts = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    final initials =
        parts.isEmpty ? '?' : parts.take(2).map((p) => p[0].toUpperCase()).join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.cardRaised,
        shape: rounded ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: rounded ? BorderRadius.circular(10) : null,
        image: hasImage
            ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: hasImage
          ? null
          : Text(initials,
              style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: size * 0.32,
                  fontWeight: FontWeight.w700)),
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

    // Цену пишем прямо на кнопке — по ней и принимают решение.
    return SizedBox(
      height: 50,
      child: AppPrimaryButton(
        label: 'Записаться · ${t.priceLabel}',
        icon: Icons.check,
        loading: _busy,
        onPressed: _busy ? null : _toggleJoin,
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4)),
      );

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
}
