import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/training.dart';
import '../../services/training_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_primary_button.dart';
import '../../utils/app_alert.dart';
import '../../widgets/app_back_button.dart';

/// Тренировка глазами тренера: кто записался и что с занятием делать.
class CoachTrainingDetailScreen extends StatefulWidget {
  final int trainingId;

  const CoachTrainingDetailScreen({super.key, required this.trainingId});

  @override
  State<CoachTrainingDetailScreen> createState() =>
      _CoachTrainingDetailScreenState();
}

class _CoachTrainingDetailScreenState extends State<CoachTrainingDetailScreen> {
  Training? _training;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final t = await context
          .read<TrainingService>()
          .getCoachTraining(widget.trainingId);
      if (!mounted) return;
      setState(() {
        _training = t;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    }
  }

  /// Подтверждение действия. Своё, а не общий хелпер: в utils его нет,
  /// а тащить приватный из админского экрана нельзя.
  Future<bool> _confirm(String message, {bool destructive = false}) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text('Подтвердите',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 17)),
        content: Text(message,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Отмена',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Да',
              style: TextStyle(
                  color: destructive ? AppTheme.orange : AppTheme.accent,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    return res == true;
  }

  Future<void> _run(Future<void> Function() action, String okText) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      await _load();
      if (mounted) await showAppAlert(context, okText);
    } catch (e) {
      if (mounted) await showAppAlert(context, '$e', title: 'Ошибка', isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _complete() async {
    final ok = await _confirm('Завершить тренировку? Изменить её после этого будет нельзя.');
    if (!ok) return;
    await _run(
      () => context.read<TrainingService>().complete(widget.trainingId),
      'Тренировка завершена',
    );
  }

  Future<void> _cancel() async {
    final ok = await _confirm('Отменить тренировку? Записавшимся уйдёт уведомление.', destructive: true);
    if (!ok) return;
    await _run(
      () => context.read<TrainingService>().cancel(widget.trainingId),
      'Тренировка отменена',
    );
  }

  Future<void> _removeParticipant(TrainingParticipant p) async {
    final ok = await _confirm('Убрать ${p.name} из тренировки?', destructive: true);
    if (!ok) return;
    await _run(
      () => context
          .read<TrainingService>()
          .removeParticipant(widget.trainingId, p.id),
      '${p.name} убран из тренировки',
    );
  }

  // ===================== связь с участником =====================

  String _digitsOnly(String phone) => phone.replaceAll(RegExp(r'[^\d]'), '');

  Future<void> _call(TrainingParticipant p) async {
    final ph = p.phone;
    if (ph == null || ph.isEmpty) return;
    final tel = ph.startsWith('+') ? ph : '+${_digitsOnly(ph)}';
    final uri = Uri.parse('tel:$tel');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _whatsapp(TrainingParticipant p) async {
    final ph = p.phone;
    if (ph == null || ph.isEmpty) return;
    final uri = Uri.parse('https://wa.me/${_digitsOnly(ph)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _copyPhone(TrainingParticipant p) async {
    final ph = p.phone;
    if (ph == null || ph.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: ph));
    if (mounted) await showAppAlert(context, 'Номер скопирован: $ph');
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
        child: Text('Не удалось загрузить',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        _infoCard(t),
        const SizedBox(height: 16),
        Text('Записались (${t.participants.length} из ${t.capacity})',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        if (t.participants.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text('Пока никто не записался',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          )
        else
          for (final p in t.participants) ...[
            _participantRow(p, canManage: t.status == 'planned'),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 16),
        if (t.canComplete) ...[
          SizedBox(
            height: 48,
            child: AppPrimaryButton(
              label: 'Завершить тренировку',
              icon: Icons.check_circle_outline,
              loading: _busy,
              onPressed: _busy ? null : _complete,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (t.canCancel)
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _busy ? null : _cancel,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Отменить тренировку'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.orange,
                side: BorderSide(color: AppTheme.orange.withOpacity(0.6)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ],
    );
  }

  Widget _infoCard(Training t) {
    final (statusText, statusColor) = switch (t.status) {
      'cancelled' => ('Отменена', AppTheme.orange),
      'completed' => ('Завершена', AppTheme.textDim),
      _ => t.isPast ? ('Ждёт завершения', AppTheme.blue) : ('Запланирована', AppTheme.accent),
    };

    return Container(
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          const SizedBox(height: 10),
          _row(Icons.place_outlined, t.club.name),
          _row(Icons.timelapse_outlined, '${t.durationMinutes} минут'),
          _row(Icons.payments_outlined,
              t.priceLabel),
          if ((t.description ?? '').isNotEmpty)
            _row(Icons.notes_outlined, t.description!),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _participantRow(TrainingParticipant p, {required bool canManage}) {
    final hasPhone = (p.phone ?? '').isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.accent.withOpacity(0.15),
            child: Text(
              p.name.isNotEmpty ? p.name.characters.first.toUpperCase() : '?',
              style: TextStyle(
                  color: AppTheme.accent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.name,
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                if (hasPhone)
                  Text(p.phone!,
                      style:
                          TextStyle(color: AppTheme.textDim, fontSize: 12)),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppTheme.textSecondary, size: 20),
            color: AppTheme.cardRaised,
            onSelected: (v) {
              if (v == 'call') _call(p);
              if (v == 'whatsapp') _whatsapp(p);
              if (v == 'copy') _copyPhone(p);
              if (v == 'remove') _removeParticipant(p);
            },
            itemBuilder: (_) => [
              if (hasPhone) ...[
                PopupMenuItem(
                  value: 'copy',
                  child: Row(children: [
                    Icon(Icons.phone_outlined,
                        size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 10),
                    Text(p.phone!,
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ]),
                ),
                PopupMenuItem(
                  value: 'call',
                  child: Row(children: [
                    Icon(Icons.call, size: 18, color: AppTheme.accent),
                    const SizedBox(width: 10),
                    Text('Позвонить',
                        style: TextStyle(
                            color: AppTheme.textPrimary, fontSize: 13)),
                  ]),
                ),
                PopupMenuItem(
                  value: 'whatsapp',
                  child: Row(children: [
                    const FaIcon(FontAwesomeIcons.whatsapp,
                        size: 17, color: Color(0xFF25D366)),
                    const SizedBox(width: 10),
                    Text('WhatsApp',
                        style: TextStyle(
                            color: AppTheme.textPrimary, fontSize: 13)),
                  ]),
                ),
              ],
              if (canManage)
                PopupMenuItem(
                  value: 'remove',
                  child: Row(children: [
                    const Icon(Icons.person_remove_outlined,
                        size: 18, color: Color(0xFFEF4444)),
                    const SizedBox(width: 10),
                    const Text('Убрать из тренировки',
                        style: TextStyle(
                            color: Color(0xFFEF4444), fontSize: 13)),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
