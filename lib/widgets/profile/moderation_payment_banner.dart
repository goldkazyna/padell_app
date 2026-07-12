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
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TournamentDetailScreen(tournamentId: p.tournamentId),
              ),
            );
            _load(); // обновить после возврата (вдруг оплатил/отменил)
          },
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppTheme.amber.withAlpha(36),
                  AppTheme.amber.withAlpha(10),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.amber.withAlpha(56)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Акцентная полоса слева
                  Container(width: 4, color: AppTheme.amber),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      child: Row(
                        children: [
                          // Иконка в мягком янтарном квадрате
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.amber.withAlpha(46),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(Icons.schedule,
                                size: 20, color: AppTheme.amber),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  left.isNegative
                                      ? 'Оплатите участие'
                                      : 'Оплатите участие — ${_fmt(left)}',
                                  style: TextStyle(
                                    color: AppTheme.amber,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  p.date.isNotEmpty
                                      ? '${p.name} · ${p.date}'
                                      : p.name,
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.chevron_right,
                              size: 20, color: AppTheme.amber.withAlpha(230)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
