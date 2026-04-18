import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Полоска диапазона уровня турнира с точкой текущего игрока.
/// Если игрок в диапазоне [min, max] — fill accent зелёный + точка зелёная,
/// иначе — fill приглушённый blue + точка белая (вне диапазона).
class LevelBar extends StatelessWidget {
  final double min;
  final double max;
  final double? playerLevel;
  final double height;
  final double scaleMin;
  final double scaleMax;

  const LevelBar({
    super.key,
    required this.min,
    required this.max,
    this.playerLevel,
    this.height = 6,
    this.scaleMin = 1.0,
    this.scaleMax = 5.0,
  });

  bool get _inRange =>
      playerLevel != null && playerLevel! >= min && playerLevel! <= max;

  double _pct(double v) =>
      ((v - scaleMin) / (scaleMax - scaleMin)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final minPct = _pct(min);
        final maxPct = _pct(max);
        final rangeLeft = w * minPct;
        final rangeWidth = w * (maxPct - minPct);
        final dotSize = 10.0;
        final myPct = playerLevel != null ? _pct(playerLevel!) : null;

        final rangeColor =
            _inRange ? AppTheme.accent : AppTheme.blue.withValues(alpha: 0.5);
        final dotColor = _inRange ? AppTheme.accent : AppTheme.textPrimary;

        return SizedBox(
          width: w,
          height: dotSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // base track
              Positioned(
                left: 0,
                top: (dotSize - height) / 2,
                child: Container(
                  width: w,
                  height: height,
                  decoration: BoxDecoration(
                    color: const Color(0x0DFFFFFF),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
              // range fill
              Positioned(
                left: rangeLeft,
                top: (dotSize - height) / 2,
                child: Container(
                  width: rangeWidth.clamp(0.0, w),
                  height: height,
                  decoration: BoxDecoration(
                    color: rangeColor,
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              ),
              // player dot
              if (myPct != null)
                Positioned(
                  left: (w * myPct) - dotSize / 2,
                  top: 0,
                  child: Container(
                    width: dotSize,
                    height: dotSize,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.background, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
