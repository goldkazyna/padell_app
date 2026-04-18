import 'package:flutter/material.dart';

/// Медаль с двухцветной ленточкой и номером места.
///
/// place: 1 — золото (#E9C46A), 2 — серебро (#C7C9CF), 3 — бронза (#CD8A4B)
class Medal extends StatelessWidget {
  final int place;
  final double size;

  const Medal({super.key, required this.place, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _MedalPainter(place: place),
    );
  }
}

class _MedalPainter extends CustomPainter {
  final int place;

  _MedalPainter({required this.place});

  Color get _discColor {
    switch (place) {
      case 1:
        return const Color(0xFFE9C46A); // gold
      case 2:
        return const Color(0xFFC7C9CF); // silver
      case 3:
        return const Color(0xFFCD8A4B); // bronze
      default:
        return const Color(0xFF9A9CA2);
    }
  }

  Color get _discStroke =>
      place == 3 ? const Color(0xFFA46735) : const Color(0xFF9A9CA2);

  Color get _numberColor =>
      place == 3 ? const Color(0xFF5A3B22) : const Color(0xFF4A4C52);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 32.0; // исходный viewBox 32×32

    // ribbon — красная часть (левая треугольная форма)
    final redPaint = Paint()..color = const Color(0xFFC94B3A).withValues(alpha: 0.65);
    final redPath = Path()
      ..moveTo(10 * s, 2 * s)
      ..lineTo(13 * s, 14 * s)
      ..lineTo(16 * s, 10 * s)
      ..lineTo(19 * s, 14 * s)
      ..lineTo(22 * s, 2 * s)
      ..close();
    canvas.drawPath(redPath, redPaint);

    // ribbon — синяя часть (слой поверх, чуть уже)
    final bluePaint = Paint()..color = const Color(0xFF2E62B6).withValues(alpha: 0.65);
    final bluePath = Path()
      ..moveTo(11 * s, 2 * s)
      ..lineTo(14 * s, 12 * s)
      ..lineTo(16 * s, 10 * s)
      ..lineTo(18 * s, 12 * s)
      ..lineTo(21 * s, 2 * s)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // disc
    final discCenter = Offset(16 * s, 20 * s);
    final discRadius = 9 * s;
    canvas.drawCircle(discCenter, discRadius, Paint()..color = _discColor);
    canvas.drawCircle(
      discCenter,
      discRadius,
      Paint()
        ..color = _discStroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5 * s,
    );

    // number
    final tp = TextPainter(
      text: TextSpan(
        text: '$place',
        style: TextStyle(
          color: _numberColor,
          fontSize: 9 * s,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(discCenter.dx - tp.width / 2, discCenter.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MedalPainter oldDelegate) {
    return oldDelegate.place != place;
  }
}
