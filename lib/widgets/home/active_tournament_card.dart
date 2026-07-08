import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class ActiveTournamentCard extends StatefulWidget {
  final Tournament? tournament;
  final VoidCallback? onTap;

  const ActiveTournamentCard({
    super.key,
    this.tournament,
    this.onTap,
  });

  @override
  State<ActiveTournamentCard> createState() => _ActiveTournamentCardState();
}

class _ActiveTournamentCardState extends State<ActiveTournamentCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tournament == null) {
      return _buildEmptyState(context);
    }

    final t = widget.tournament!;
    final isLive = t.status == 'in_progress';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLive
                ? AppTheme.accent.withAlpha(60)
                : const Color(0xFF2A2A2A),
            width: isLive ? 1.0 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isLive)
                  _buildLivePill()
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Color(0xFF3B82F6), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          AppLocalizations.of(context)!.registered,
                          style: const TextStyle(
                            color: Color(0xFF3B82F6),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                _buildInfoChip(t.typeName, t.typeColor),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              t.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.club.name,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            if (t.venueClubName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 13, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      t.venueClubName!,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: AppTheme.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  '${t.date} · ${t.time}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                ),
                const Spacer(),
                Text(
                  t.participantsText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Большой яркий бейдж «Идёт сейчас» с пульсирующей точкой
  Widget _buildLivePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accent.withAlpha(38),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: AppTheme.accent.withAlpha(80),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) {
              final scale = 1.0 + 0.45 * _pulseController.value;
              final opacity = 1.0 - 0.55 * _pulseController.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  // пульс — расходящийся круг
                  Opacity(
                    opacity: opacity * 0.5,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppTheme.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppTheme.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'Идёт сейчас',
            style: TextStyle(
              color: AppTheme.accent,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
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
            const Icon(Icons.sports_tennis, color: AppTheme.textSecondary, size: 40),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.of(context)!.notInTournaments,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
