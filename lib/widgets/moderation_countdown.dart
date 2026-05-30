import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Локальный обратный отсчёт до дедлайна модерации (без сети/вебсокетов).
class ModerationCountdown extends StatefulWidget {
  final DateTime deadline;
  final bool compact;
  const ModerationCountdown({super.key, required this.deadline, this.compact = false});

  @override
  State<ModerationCountdown> createState() => _ModerationCountdownState();
}

class _ModerationCountdownState extends State<ModerationCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    if (d.isNegative) return 'время вышло';
    final days = d.inDays;
    final h = d.inHours % 24;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (days > 0) return '$daysд $hч $mм';
    if (h > 0) return '$hч $mм $sс';
    return '$mм $sс';
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.deadline.difference(DateTime.now());
    final urgent = left.inHours < 3;
    final color = left.isNegative
        ? AppTheme.error
        : (urgent ? AppTheme.amber : AppTheme.accent);

    if (widget.compact) {
      return Text('⏳ ${_fmt(left)}',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700));
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(24),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              left.isNegative
                  ? 'Время на оплату вышло'
                  : 'Оплатите в течение ${_fmt(left)}',
              style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
