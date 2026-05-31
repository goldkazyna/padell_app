import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/moderation_service.dart';
import '../../theme/app_theme.dart';
import '../../screens/tournament_detail_screen.dart';

/// Тонкая янтарная полоска под шапкой профиля: «Оплатите участие — <таймер>».
/// Показывается только когда есть неоплаченная заявка с таймером.
class ModerationPaymentBanner extends StatefulWidget {
  const ModerationPaymentBanner({super.key});

  @override
  State<ModerationPaymentBanner> createState() => _ModerationPaymentBannerState();
}

class _ModerationPaymentBannerState extends State<ModerationPaymentBanner> {
  ModerationPending? _pending;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _pending != null) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final p = await context.read<ModerationService>().getPending();
      if (!mounted) return;
      setState(() => _pending = p);
    } catch (_) {
      // тихо игнорируем
    }
  }

  String _fmt(Duration d) {
    if (d.isNegative) return 'время вышло';
    final days = d.inDays;
    final h = d.inHours % 24;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (days > 0) return '$daysд $hч $mм';
    if (h > 0) return '$hч $mм';
    return '$mм $sс';
  }

  @override
  Widget build(BuildContext context) {
    final p = _pending;
    if (p == null) return const SizedBox.shrink();
    final left = p.deadline.difference(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TournamentDetailScreen(tournamentId: p.tournamentId),
              ),
            );
            _load(); // обновить после возврата (вдруг оплатил/отменил)
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: AppTheme.amber.withAlpha(28),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.amber.withAlpha(90)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 18, color: AppTheme.amber),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    left.isNegative
                        ? 'Оплатите участие в «${p.name}»'
                        : 'Оплатите участие — ${_fmt(left)}',
                    style: const TextStyle(
                      color: AppTheme.amber,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right, size: 18, color: AppTheme.amber),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
