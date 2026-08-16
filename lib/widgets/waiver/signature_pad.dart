import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Управление холстом подписи снаружи: очистка, проверка на пустоту, PNG.
class SignaturePadController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  Size _size = Size.zero;

  bool get isEmpty => _strokes.every((stroke) => stroke.length < 2);

  void clear() {
    _strokes.clear();
    notifyListeners();
  }

  /// PNG на белом фоне: подпись потом печатают и подшивают к документам.
  Future<Uint8List?> toPng() async {
    if (isEmpty || _size.isEmpty) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(Offset.zero & _size, Paint()..color = Colors.white);
    paintStrokes(canvas, Colors.black);

    final image = await recorder
        .endRecording()
        .toImage(_size.width.round(), _size.height.round());
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    return data?.buffer.asUint8List();
  }

  /// Рисует накопленные штрихи — и на экране, и при выгрузке в PNG.
  void paintStrokes(Canvas canvas, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (final point in stroke.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _startStroke(Offset point) {
    _strokes.add([point]);
    notifyListeners();
  }

  void _addPoint(Offset point) {
    if (_strokes.isEmpty) return;
    _strokes.last.add(point);
    notifyListeners();
  }

  void _setSize(Size size) => _size = size;
}

/// Поле для подписи пальцем.
class SignaturePad extends StatelessWidget {
  const SignaturePad({
    super.key,
    required this.controller,
    this.height = 180,
    this.background = Colors.white,
    this.ink = Colors.black,
  });

  final SignaturePadController controller;
  final double height;
  final Color background;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          controller._setSize(Size(constraints.maxWidth, height));

          return ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: background,
              child: GestureDetector(
                onPanStart: (d) => controller._startStroke(d.localPosition),
                onPanUpdate: (d) => controller._addPoint(d.localPosition),
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) => CustomPaint(
                    size: Size(constraints.maxWidth, height),
                    painter: _SignaturePainter(controller, ink),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.controller, this.ink);

  final SignaturePadController controller;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) => controller.paintStrokes(canvas, ink);

  // Перерисовку запускает AnimatedBuilder на каждое уведомление контроллера.
  @override
  bool shouldRepaint(_SignaturePainter old) => true;
}
