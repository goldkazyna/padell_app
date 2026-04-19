import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Бейдж «Верифицирован» — компактная галочка рядом с именем.
/// Показывается только если level_verified == true.
class VerifiedBadge extends StatelessWidget {
  final double size;
  final bool withTooltip;

  const VerifiedBadge({
    super.key,
    this.size = 14,
    this.withTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size + 2,
      height: size + 2,
      decoration: const BoxDecoration(
        color: AppTheme.accent,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.check, color: Colors.white, size: size * 0.7),
    );

    if (!withTooltip) return badge;

    return Tooltip(
      message: 'Уровень подтверждён клубом',
      child: badge,
    );
  }
}
