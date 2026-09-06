import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Разметка корта, уходящая вдаль — фирменная фактура приложения.
///
/// Используется фоном блоков: меню профиля, «кто сейчас на корте» в амигос.
///
/// Рисуется кодом, а не картинкой: у части клубов нормальных фото нет, а
/// блюр и большие изображения роняют прокрутку на слабых Android.
///
/// Линии живут только в верхней части блока и растворяются к середине:
/// внизу расположены самые длинные подписи, и там фон должен быть чистым.
class CourtGridBackground extends StatelessWidget {
  /// Какую долю высоты занимают линии (0.52 — чуть больше половины).
  final double coverage;

  const CourtGridBackground({super.key, this.coverage = 0.52});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Линии: маска гасит их к низу, чтобы текст читался.
          Align(
            alignment: Alignment.topCenter,
            child: FractionallySizedBox(
              heightFactor: coverage,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.white, Colors.transparent],
                  stops: [0.0, 0.45, 1.0],
                ).createShader(rect),
                // Без size CustomPaint без ребёнка занимает нулевую площадь
                // и не рисует ничего.
                child: CustomPaint(
                  painter: _CourtGridPainter(),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          // Свет вдалеке — будто прожекторы за дальней стенкой.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -1.12),
                radius: 0.85,
                colors: [
                  AppTheme.accent.withValues(alpha: 0.30),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.6],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Сетка в перспективе: продольные линии сходятся к точке схода,
/// поперечные сгущаются к горизонту.
class _CourtGridPainter extends CustomPainter {
  /// Где лежит горизонт по высоте блока (0 — самый верх).
  static const _horizon = -0.34;

  /// Насколько широк корт у нижнего края: 1.6 = уходит за края блока.
  static const _nearWidth = 1.6;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFFA0FFCD).withValues(alpha: 0.17);

    final vanishing = Offset(size.width / 2, size.height * _horizon);

    // Продольные линии: от нижнего края к точке схода.
    for (var i = 0; i <= 8; i++) {
      final t = i / 8;
      final x = size.width * (0.5 + (t - 0.5) * _nearWidth);
      canvas.drawLine(Offset(x, size.height), vanishing, paint);
    }

    // Поперечные: чем дальше, тем чаще — так работает перспектива.
    final crossPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFFA0FFCD).withValues(alpha: 0.13);

    for (var i = 1; i <= 7; i++) {
      final t = i / 8;
      // Квадратичное сжатие даёт ощущение уходящей вдаль плоскости.
      final y = size.height - size.height * (t * t);
      final spread = _nearWidth * (y - vanishing.dy) / (size.height - vanishing.dy);
      final half = size.width * spread / 2;

      canvas.drawLine(
        Offset(size.width / 2 - half, y),
        Offset(size.width / 2 + half, y),
        crossPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CourtGridPainter oldDelegate) => false;
}
