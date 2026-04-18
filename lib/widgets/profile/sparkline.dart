import 'package:flutter/material.dart';

class Sparkline extends StatelessWidget {
  final List<num> points;
  final Color color;
  final double width;
  final double height;
  final bool showLabels;

  const Sparkline({
    super.key,
    required this.points,
    required this.color,
    this.width = 110,
    this.height = 38,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) {
      return SizedBox(width: width, height: height);
    }
    final doubles = points.map((e) => e.toDouble()).toList();
    return CustomPaint(
      size: Size(width, height),
      painter: _SparklinePainter(
        points: doubles,
        color: color,
        showLabels: showLabels,
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final bool showLabels;

  _SparklinePainter({
    required this.points,
    required this.color,
    required this.showLabels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final minV = points.reduce((a, b) => a < b ? a : b);
    final maxV = points.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs();
    final pad = range < 1 ? 1.0 : range * 0.08;
    final lo = minV - pad;
    final hi = maxV + pad;

    final n = points.length;
    final stepX = n > 1 ? size.width / (n - 1) : 0.0;

    // Резервируем место под подписи сверху и снизу если они включены
    final labelSpaceTop = showLabels ? 12.0 : 0.0;
    final labelSpaceBottom = showLabels ? 12.0 : 0.0;
    final chartHeight = size.height - labelSpaceTop - labelSpaceBottom;

    Offset pt(int i) {
      final x = i * stepX;
      final norm = (points[i] - lo) / (hi - lo);
      final y = labelSpaceTop + chartHeight - norm * chartHeight;
      return Offset(x, y);
    }

    // area path
    final area = Path()..moveTo(0, labelSpaceTop + chartHeight);
    for (var i = 0; i < n; i++) {
      final p = pt(i);
      area.lineTo(p.dx, p.dy);
    }
    area.lineTo(size.width, labelSpaceTop + chartHeight);
    area.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0)],
      ).createShader(Rect.fromLTWH(labelSpaceTop, 0, size.width, chartHeight));
    canvas.drawPath(area, areaPaint);

    // line
    final line = Path()..moveTo(0, pt(0).dy);
    for (var i = 1; i < n; i++) {
      line.lineTo(pt(i).dx, pt(i).dy);
    }
    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(line, linePaint);

    // Кружки на каждой точке
    final dotPaint = Paint()..color = color;
    final innerDotPaint = Paint()..color = const Color(0xFF1C1C21);
    for (var i = 0; i < n; i++) {
      final p = pt(i);
      canvas.drawCircle(p, 2.8, dotPaint);
      if (i < n - 1) {
        canvas.drawCircle(p, 1.5, innerDotPaint);
      }
    }

    // Подписи с числом рейтинга у каждой точки
    if (showLabels) {
      for (var i = 0; i < n; i++) {
        final p = pt(i);
        final label = points[i].toInt().toString();
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(
              color: i == n - 1 ? color : const Color(0xFFA2A2AB),
              fontSize: 9,
              fontWeight: i == n - 1 ? FontWeight.w700 : FontWeight.w600,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        // Размещаем: если точка в верхней половине — подпись снизу,
        // если в нижней — сверху (чтобы не перекрывала линию)
        final midY = labelSpaceTop + chartHeight / 2;
        final below = p.dy < midY;
        final ty = below ? p.dy + 5 : p.dy - tp.height - 5;

        // Центруем по X и удерживаем внутри ширины
        var tx = p.dx - tp.width / 2;
        if (tx < 0) tx = 0;
        if (tx + tp.width > size.width) tx = size.width - tp.width;

        tp.paint(canvas, Offset(tx, ty));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.color != color ||
        oldDelegate.showLabels != showLabels;
  }
}
