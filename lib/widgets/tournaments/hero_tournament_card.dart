import 'package:flutter/material.dart';
import '../../models/tournament.dart';
import '../../theme/app_theme.dart';
import 'level_bar.dart';

class HeroTournamentCard extends StatelessWidget {
  final Tournament tournament;
  final double? userLevel;
  final VoidCallback onTap;

  const HeroTournamentCard({
    super.key,
    required this.tournament,
    required this.userLevel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final full = tournament.isFull;
    final fmt = _formatChipColors(tournament.formatColor);
    final progressFraction = tournament.maxParticipants > 0
        ? tournament.participantsCount / tournament.maxParticipants
        : 0.0;
    final spotsLeft = tournament.spotsLeft;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.4, 1.0],
              colors: full
                  ? const [
                      Color(0xFF25201D),
                      Color(0xFF221C1C),
                      Color(0xFF1C1C21),
                    ]
                  : const [
                      Color(0xFF1D3025),
                      Color(0xFF1C2820),
                      Color(0xFF1C1C21),
                    ],
            ),
            border: Border.all(
              color: full
                  ? AppTheme.error.withValues(alpha: 0.18)
                  : AppTheme.border,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              if (full)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: _DiagonalStripes(),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTopRow(full, fmt),
                    const SizedBox(height: 10),
                    _buildDateTimeRow(full),
                    const SizedBox(height: 10),
                    _buildLevelRow(full),
                    const SizedBox(height: 10),
                    _buildBottomRow(full, progressFraction, spotsLeft),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(bool full, _FmtChipColors fmt) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _chip(tournament.typeName, fmt.fg, fmt.bg),
                  if (userLevel != null && tournament.isInLevelRange(userLevel))
                    _chip('Ваш уровень', AppTheme.accent, AppTheme.accentSoft),
                  if (full)
                    _chip(
                      'ЗАПОЛНЕН',
                      AppTheme.error,
                      AppTheme.errorSoft,
                      uppercase: true,
                      bold: true,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                tournament.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  color: full ? AppTheme.textSecondary : AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 11),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${tournament.club.name} · ${tournament.club.city ?? ''}'
                            .trimRight(),
                        style: const TextStyle(color: AppTheme.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (tournament.price > 0) ...[
                      const Text(
                        ' · ',
                        style: TextStyle(color: AppTheme.textDim),
                      ),
                      Text(
                        tournament.priceTextCompact,
                        style: TextStyle(
                          color: full
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        if (!full)
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Записаться',
                style: TextStyle(
                  color: Color(0xFF0A0A0D),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDateTimeRow(bool full) {
    final dim = full ? AppTheme.textSecondary : AppTheme.textPrimary;
    return Row(
      children: [
        Text(
          tournament.dateShort,
          style: TextStyle(
            fontSize: 12,
            color: dim,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Text(' · ', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        Text(
          tournament.time,
          style: TextStyle(
            fontSize: 12,
            color: dim,
            fontWeight: FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const Text(' · ', style: TextStyle(color: AppTheme.textDim, fontSize: 12)),
        Text(
          tournament.dayOfWeekShort,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildLevelRow(bool full) {
    return Opacity(
      opacity: full ? 0.6 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Уровень ${tournament.minLevel.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 10,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              if (userLevel != null)
                Text(
                  'Вы: ${userLevel!.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: tournament.isInLevelRange(userLevel)
                        ? AppTheme.accent
                        : AppTheme.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              const Spacer(),
              Text(
                tournament.maxLevel.toStringAsFixed(2),
                style: const TextStyle(
                  color: AppTheme.textDim,
                  fontSize: 10,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          LevelBar(
            min: tournament.minLevel,
            max: tournament.maxLevel,
            playerLevel: userLevel,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(bool full, double fraction, int spotsLeft) {
    final amberClose = !full && spotsLeft > 0 && spotsLeft <= 2;
    final barColor = full
        ? AppTheme.error
        : amberClose
            ? AppTheme.amber
            : AppTheme.accent;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 4,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, c) => Container(
                    width: c.maxWidth * fraction.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (full)
          Text(
            '${tournament.participantsCount}/${tournament.maxParticipants} · мест нет',
            style: const TextStyle(
              color: AppTheme.error,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          )
        else
          Text(
            tournament.spotsLeftText(),
            style: TextStyle(
              color: amberClose ? AppTheme.amber : AppTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
      ],
    );
  }

  Widget _chip(String text, Color fg, Color bg,
      {bool uppercase = false, bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        uppercase ? text.toUpperCase() : text,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          letterSpacing: uppercase ? 0.5 : 0,
        ),
      ),
    );
  }
}

class _FmtChipColors {
  final Color bg;
  final Color fg;
  const _FmtChipColors(this.bg, this.fg);
}

_FmtChipColors _formatChipColors(TournamentFormatColor color) {
  switch (color) {
    case TournamentFormatColor.blue:
      return _FmtChipColors(
        AppTheme.blue.withValues(alpha: 0.15),
        const Color(0xFF7AA8F8),
      );
    case TournamentFormatColor.purple:
      return _FmtChipColors(
        AppTheme.purple.withValues(alpha: 0.15),
        const Color(0xFFB3A7F8),
      );
    case TournamentFormatColor.orange:
      return _FmtChipColors(
        AppTheme.orange.withValues(alpha: 0.15),
        const Color(0xFFF5A37A),
      );
  }
}

/// Диагональная декоративная штриховка на фон full-карточки.
class _DiagonalStripes extends StatelessWidget {
  const _DiagonalStripes();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DiagonalStripesPainter());
  }
}

class _DiagonalStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x04FFFFFF)
      ..strokeWidth = 1;
    const step = 11.0;
    final diag = size.width + size.height;
    for (var x = -size.height; x < diag; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _DiagonalStripesPainter oldDelegate) => false;
}
