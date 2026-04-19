import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Бейдж «Верифицирован» — компактная галочка. Показывать только
/// когда verified == true.
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
        color: AppTheme.blue,
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

/// Статус верификации для inline-использования:
/// verified → маленький бейдж с галкой,
/// не verified → amber-текст «Не верифицирован».
class LevelVerificationStatus extends StatelessWidget {
  final bool verified;
  final double badgeSize;
  final double fontSize;

  const LevelVerificationStatus({
    super.key,
    required this.verified,
    this.badgeSize = 13,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    if (verified) {
      return VerifiedBadge(size: badgeSize);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.info_outline, size: badgeSize, color: AppTheme.amber),
        const SizedBox(width: 3),
        Text(
          'Не верифицирован',
          style: TextStyle(
            color: AppTheme.amber,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
