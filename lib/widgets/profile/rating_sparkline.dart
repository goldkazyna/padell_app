import 'package:flutter/material.dart';

/// График динамики рейтинга: сплайн, заливка под ним и точки-турниры.
///
/// Один и тот же рисунок в карточке профиля (последние десять точек) и на
/// экране всей динамики (все точки, с прокруткой вбок). Рисовать их двумя
/// разными кусками кода значит однажды получить два разных графика.
class RatingSparkline extends StatelessWidget {
  final List<int> trend;
  final int selectedIdx;

  /// Цвет линии и точек.
  final Color green;

  /// Фон, которым обводится точка, чтобы она отрывалась от линии.
  final Color card;

  final Size size;

  /// Тап по графику: отдаёт индекс ближайшей точки.
  final ValueChanged<int>? onPick;

  const RatingSparkline({
    super.key,
    required this.trend,
    required this.selectedIdx,
    required this.green,
    required this.card,
    required this.size,
    this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onPick == null
          ? null
          : (details) => onPick!(nearestPoint(trend, size, details.localPosition.dx)),
      child: CustomPaint(
        size: size,
        painter: RatingSparklinePainter(
          trend: trend,
          selectedIdx: selectedIdx,
          green: green,
          card: card,
        ),
      ),
    );
  }
}

/// Индекс точки, ближайшей к нажатию по горизонтали.
int nearestPoint(List<int> trend, Size size, double dx) {
  final coords = calcPoints(trend, size.width, size.height);
  int nearest = 0;
  double minDist = double.infinity;
  for (int i = 0; i < coords.length; i++) {
    final d = (coords[i].dx - dx).abs();
    if (d < minDist) {
      minDist = d;
      nearest = i;
    }
  }

  return nearest;
}

List<Offset> calcPoints(List<int> trend, double width, double height) {
  if (trend.isEmpty) return const <Offset>[];
  const padL = 8.0, padR = 8.0, padT = 18.0, padB = 4.0;
  final innerW = width - padL - padR;
  final innerH = height - padT - padB;

  int minV = trend.reduce((a, b) => a < b ? a : b);
  int maxV = trend.reduce((a, b) => a > b ? a : b);
  if (maxV == minV) {
    maxV = minV + 1; // защита от деления на 0
  }
  // Добавим небольшой запас по вертикали
  final range = (maxV - minV).toDouble();
  minV = (minV - range * 0.1).round();
  maxV = (maxV + range * 0.1).round();

  return List.generate(trend.length, (i) {
    final x = trend.length == 1
        ? padL + innerW / 2
        : padL + (i / (trend.length - 1)) * innerW;
    final y =
        padT + (1 - (trend[i] - minV) / (maxV - minV)) * innerH;
    return Offset(x, y);
  });
}

class RatingSparklinePainter extends CustomPainter {
  final List<int> trend;
  final int selectedIdx;
  final Color green;
  final Color card;

  RatingSparklinePainter({
    required this.trend,
    required this.selectedIdx,
    required this.green,
    required this.card,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trend.isEmpty) return;
    final points = calcPoints(trend, size.width, size.height);

    if (points.length >= 2) {
      // Сплайн Catmull-Rom через кубические Bezier
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 0; i < points.length - 1; i++) {
        final p0 = i == 0 ? points[i] : points[i - 1];
        final p1 = points[i];
        final p2 = points[i + 1];
        final p3 = i + 2 < points.length ? points[i + 2] : p2;
        final c1 = Offset(
          p1.dx + (p2.dx - p0.dx) / 6,
          p1.dy + (p2.dy - p0.dy) / 6,
        );
        final c2 = Offset(
          p2.dx - (p3.dx - p1.dx) / 6,
          p2.dy - (p3.dy - p1.dy) / 6,
        );
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
      }

      // Area fill (градиент)
      final areaPath = Path.from(path)
        ..lineTo(points.last.dx, size.height - 4)
        ..lineTo(points.first.dx, size.height - 4)
        ..close();
      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [green.withAlpha(77), green.withAlpha(0)],
        ).createShader(Offset.zero & size);
      canvas.drawPath(areaPath, areaPaint);

      // Линия
      final linePaint = Paint()
        ..color = green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(path, linePaint);
    }

    // Вертикальный пунктир под активной точкой
    if (selectedIdx >= 0 && selectedIdx < points.length) {
      final sel = points[selectedIdx];
      final guidePaint = Paint()
        ..color = green.withAlpha(77)
        ..strokeWidth = 1;
      // Пунктир
      double y = sel.dy;
      while (y < size.height - 4) {
        canvas.drawLine(
          Offset(sel.dx, y),
          Offset(sel.dx, (y + 2).clamp(0, size.height - 4)),
          guidePaint,
        );
        y += 5;
      }
    }

    // Точки — крупные, чтобы попадать пальцем
    for (int i = 0; i < points.length; i++) {
      final isSel = i == selectedIdx;
      final p = points[i];
      if (isSel) {
        canvas.drawCircle(
          p,
          14,
          Paint()..color = green.withAlpha(50),
        );
      }
      // Внешний контур-обводка цветом карточки (чтобы точка отрывалась
      // от линии графика).
      canvas.drawCircle(
        p,
        isSel ? 8 : 6,
        Paint()..color = card,
      );
      // Заливка зелёным
      canvas.drawCircle(
        p,
        isSel ? 6.5 : 4.5,
        Paint()..color = green,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RatingSparklinePainter old) {
    return old.selectedIdx != selectedIdx ||
        old.trend.length != trend.length ||
        !_listEq(old.trend, trend);
  }

  static bool _listEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
