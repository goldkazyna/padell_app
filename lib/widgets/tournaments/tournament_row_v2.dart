import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';

/// Компактная строка турнира для секции «Остальные турниры» /
/// вкладок «Мои» и «Архив». Визуально full-состояние: перечёркнутое
/// название + диагональная штриховка + opacity 0.55.
class TournamentRowV2 extends StatelessWidget {
  final Tournament tournament;
  final double? userLevel;
  final VoidCallback onTap;
  final bool showPrice;
  final bool showStatusChip;

  const TournamentRowV2({
    super.key,
    required this.tournament,
    required this.userLevel,
    required this.onTap,
    this.showPrice = true,
    this.showStatusChip = true,
  });

  @override
  Widget build(BuildContext context) {
    final full = tournament.isFull;
    final inRange = userLevel != null && tournament.isInLevelRange(userLevel);
    final fmt = _chipColorsFor(tournament.formatColor);
    final spotsLeft = tournament.spotsLeft;
    final amberClose = !full && spotsLeft > 0 && spotsLeft <= 2;

    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          if (full)
            const Positioned.fill(
              child: IgnorePointer(child: _DiagonalStripes()),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // День недели + время
                Opacity(
                  opacity: full ? 0.5 : 1.0,
                  child: SizedBox(
                    width: 44,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          tournament.dayOfWeekShort.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppTheme.textDim,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          tournament.time,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Центр: название + подзаголовок
                Expanded(
                  child: Opacity(
                    opacity: full ? 0.55 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                tournament.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.15,
                                  color: AppTheme.textPrimary,
                                  decoration: full
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor:
                                      AppTheme.error.withValues(alpha: 0.5),
                                  decorationThickness: 1.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (inRange && !full) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppTheme.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: fmt.bg,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                tournament.typeName,
                                style: TextStyle(
                                  color: fmt.fg,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'L${tournament.minLevel.toStringAsFixed(2)}–${tournament.maxLevel.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: AppTheme.textDim,
                                  fontSize: 11,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('·',
                                style:
                                    TextStyle(color: AppTheme.textDim, fontSize: 11)),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                tournament.dateShort,
                                style: const TextStyle(
                                  color: AppTheme.textDim,
                                  fontSize: 11,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Справа: статус / цена
                if (showStatusChip) _buildRightSide(full, spotsLeft, amberClose),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSide(bool full, int spotsLeft, bool amberClose) {
    if (full) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.errorSoft,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cancel_outlined, size: 11, color: AppTheme.error),
            const SizedBox(width: 4),
            const Text(
              'ЗАПОЛНЕН',
              style: TextStyle(
                color: AppTheme.error,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${tournament.participantsCount}/${tournament.maxParticipants}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: amberClose ? AppTheme.amber : AppTheme.accent,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (showPrice && tournament.price > 0) ...[
          const SizedBox(height: 1),
          Text(
            tournament.priceTextCompact,
            style: const TextStyle(
              color: AppTheme.textDim,
              fontSize: 10,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }
}

class _ChipColors {
  final Color bg;
  final Color fg;
  const _ChipColors(this.bg, this.fg);
}

_ChipColors _chipColorsFor(TournamentFormatColor color) {
  switch (color) {
    case TournamentFormatColor.blue:
      return _ChipColors(
        AppTheme.blue.withValues(alpha: 0.15),
        const Color(0xFF7AA8F8),
      );
    case TournamentFormatColor.purple:
      return _ChipColors(
        AppTheme.purple.withValues(alpha: 0.15),
        const Color(0xFFB3A7F8),
      );
    case TournamentFormatColor.orange:
      return _ChipColors(
        AppTheme.orange.withValues(alpha: 0.15),
        const Color(0xFFF5A37A),
      );
  }
}

class _DiagonalStripes extends StatelessWidget {
  const _DiagonalStripes();

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DiagonalStripesPainter());
}

class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x04FFFFFF)
      ..strokeWidth = 1;
    const step = 9.0;
    final diag = size.width + size.height;
    for (var x = -size.height; x < diag; x += step) {
      canvas.drawLine(
          Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalStripesPainter oldDelegate) => false;
}
