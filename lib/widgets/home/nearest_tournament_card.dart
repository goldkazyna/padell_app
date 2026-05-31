import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../tournaments/club_logo.dart';

class NearestTournamentCard extends StatelessWidget {
  final Tournament? tournament;
  final VoidCallback? onTap;
  final VoidCallback? onBrowse;

  const NearestTournamentCard({
    super.key,
    this.tournament,
    this.onTap,
    this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    if (tournament == null) {
      return _buildEmptyState(context);
    }

    final t = tournament!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.accent.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today, color: AppTheme.accent, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${t.date} · ${t.time}',
                      style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClubLogoTile(
                    url: t.club.logo,
                    name: t.club.name,
                    size: 44,
                    radius: 11,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.club.name,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildInfoChip(t.typeName, t.typeColor),
                  const SizedBox(width: 8),
                  _buildInfoChip(t.priceText, AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  _buildInfoChip(AppLocalizations.of(context)!.levelShort(t.levelText), AppTheme.textSecondary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.participantsText,
                style: TextStyle(
                  color: t.isFull ? AppTheme.error : AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.details,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
              ],
            ),
          ),
          if (t.moderationDeadline != null)
            _PaymentTimerFooter(deadline: t.moderationDeadline!),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
      ),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.event_available, color: AppTheme.textSecondary, size: 40),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.notInTournaments,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onBrowse,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.chooseTournament,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Янтарная строка-футер «Оплатите участие — осталось …» на всю ширину карточки.
/// Появляется, когда у текущего игрока неоплаченная заявка с таймером на этом турнире.
class _PaymentTimerFooter extends StatefulWidget {
  final DateTime deadline;
  const _PaymentTimerFooter({required this.deadline});

  @override
  State<_PaymentTimerFooter> createState() => _PaymentTimerFooterState();
}

class _PaymentTimerFooterState extends State<_PaymentTimerFooter> {
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
    if (h > 0) return '$hч $mм';
    return '$mм $sс';
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.deadline.difference(DateTime.now());
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: AppTheme.amber.withAlpha(26),
        border: Border(top: BorderSide(color: AppTheme.amber.withAlpha(56))),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, size: 16, color: AppTheme.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              left.isNegative
                  ? 'Оплатите участие'
                  : 'Оплатите участие — осталось ${_fmt(left)}',
              style: const TextStyle(
                color: AppTheme.amber,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
