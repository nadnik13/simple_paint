import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BackgroundWidget extends StatelessWidget {
  final Widget child;
  final ui.Image image;

  const BackgroundWidget({super.key, required this.child, required this.image});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _BackgroundPainter(image), child: child);
  }
}

class _BackgroundPainter extends CustomPainter {
  final ui.Image image;
  static const int _linesCount = 27;
  static const _spacing = 12;
  static const double _deltaX = 10;

  const _BackgroundPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(rect, Paint()..color = const Color(0xFF131313));
    final layerPaint = Paint()..color = const Color.fromRGBO(0, 0, 0, 0.4);

    canvas.saveLayer(rect, layerPaint);

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      rect,
      layerPaint,
    );
    final path = _buildPatternPath();
    final bounds = path.getBounds();

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeMiterLimit = _deltaX
          ..shader = ui.Gradient.linear(
            Offset(bounds.left, bounds.top),
            Offset(bounds.right, bounds.bottom),
            const [Color(0x258924E7), Color(0x256A46F9)],
          );

    canvas.saveLayer(rect, paint);

    for (int i = 0; i < _linesCount; i++) {
      final double dx = -40 + i.toDouble() * _spacing;
      canvas.save();
      canvas.translate(dx, -100);

      canvas.drawPath(path, paint);
      canvas.restore();
    }

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BackgroundPainter oldDelegate) =>
      oldDelegate.image != image;

  Path _buildPatternPath() {
    return Path()
      ..moveTo(-136.187, -177.034)
      ..cubicTo(-139.467, -109.131, -154.964, -42.3756, -181.935, 20.0273)
      ..cubicTo(-246.486, 167.498, -341.121, 201.851, -328.1, 260.085)
      ..cubicTo(-307.941, 350.118, -76.2193, 293.089, 43.3612, 441.653)
      ..cubicTo(131.105, 550.644, 115.431, 716.781, 111.784, 755.245)
      ..cubicTo(97.6445, 905.258, 24.6429, 962.571, 64.6471, 1043.76)
      ..cubicTo(93.839, 1103.16, 145.441, 1098.05, 211.664, 1180.15)
      ..cubicTo(257.768, 1237.31, 279.167, 1297.27, 290.116, 1339.53);
  }
}
