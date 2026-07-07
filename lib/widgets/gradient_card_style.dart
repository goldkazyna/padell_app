import 'dart:ui';
import 'package:flutter/material.dart';

/// Общий «объёмный» стиль карточки (как в меню профиля): цвет получается
/// подмешиванием акцента к тёмной базе, диагональный градиент, светлый гланц
/// и стеклянный чип-иконка. Один источник правды для профиля и главной.
class GradientCardStyle {
  const GradientCardStyle._();

  static Color mix(Color base, Color accent, double t) =>
      Color.lerp(base, accent, t)!;

  static const baseTop = Color(0xFF142019);
  static const baseBot = Color(0xFF0E1714);
  static const baseBorder = Color(0xFF243029);

  static BoxDecoration decoration(
    Color accent, {
    double radius = 16,
    bool glow = true,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [mix(baseTop, accent, 0.56), mix(baseBot, accent, 0.20)],
      ),
      border: Border.all(color: mix(baseBorder, accent, 0.45), width: 1),
      boxShadow: glow
          ? [
              BoxShadow(
                color: accent.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ]
          : null,
    );
  }

  /// Светлый блик поверх верхних 48% карточки (положить в Stack).
  static Widget gloss() => Positioned.fill(
        child: IgnorePointer(
          child: Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: 0.48,
              widthFactor: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// Стеклянный чип-иконка с размытием подложки.
  static Widget glassChip(
    IconData icon, {
    double size = 40,
    double iconSize = 22,
    double radius = 12,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}
