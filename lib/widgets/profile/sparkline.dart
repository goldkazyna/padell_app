import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  final List<num> points;
  final Color color;
  final double width;
  final double height;

  const Sparkline({
    super.key,
    required this.points,
    required this.color,
    this.width = 110,
    this.height = 38,
  });

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(width: width, height: height);
    }
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(points: points, color: color),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<num> points;
  final Color color;

  _SparklinePainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final minV = points.reduce((a, b) => a < b ? a : b).toDouble();
    final maxV = points.reduce((a, b) => a > b ? a : b).toDouble();
    final range = (maxV - minV).abs();
    final pad = range < 1 ? 1.0 : range * 0.08;
    final lo = minV - pad;
    final hi = maxV + pad;

    final n = points.length;
    final stepX = size.width / (n - 1);

    Offset pt(int i) {
      final x = i * stepX;
      final norm = (points[i].toDouble() - lo) / (hi - lo);
      final y = size.height - norm * size.height;
      return Offset(x, y);
    }

    // area path
    final area = Path()..moveTo(0, size.height);
    for (var i = 0; i < n; i++) {
      final p = pt(i);
      if (i == 0) {
        area.lineTo(p.dx, p.dy);
      } else {
        area.lineTo(p.dx, p.dy);
      }
    }
    area.lineTo(size.width, size.height);
    area.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(area, areaPaint);

    // line
    final line = Path()..moveTo(0, pt(0).dy);
    for (var i = 1; i < n; i++) {
      final p = pt(i);
      line.lineTo(p.dx, p.dy);
    }
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, linePaint);

    // last point dot
    final last = pt(n - 1);
    canvas.drawCircle(last, 2.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
