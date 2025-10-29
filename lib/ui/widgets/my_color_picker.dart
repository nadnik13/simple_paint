import 'package:flutter/material.dart';

class MyColorPicker extends StatelessWidget {
  const MyColorPicker({
    super.key,
    required this.child,
    this.color = const Color(0xFFF5F5F5),
    this.borderColor = const Color(0x33000000),
    this.elevation = 6,
    this.radius = 16,
    this.arrowWidth = 18,
    this.arrowHeight = 12,
    this.arrowOffset = 24,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final Color color;
  final Color borderColor;
  final double elevation;
  final double radius;
  final double arrowWidth;
  final double arrowHeight;
  final double arrowOffset;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BubblePainter(
        color: color,
        borderColor: borderColor,
        elevation: elevation,
        radius: radius,
        arrowW: arrowWidth,
        arrowH: arrowHeight,
        arrowOffset: arrowOffset,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          2 + arrowHeight,
          padding.right,
          0,
        ),
        child: child,
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  _BubblePainter({
    required this.color,
    required this.borderColor,
    required this.elevation,
    required this.radius,
    required this.arrowW,
    required this.arrowH,
    required this.arrowOffset,
  });

  final Color color;
  final Color borderColor;
  final double elevation;
  final double radius;
  final double arrowW;
  final double arrowH;
  final double arrowOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final r = radius;
    final w = size.width;
    final h = size.height;

    final path = Path();
    final bodyTop = arrowH;

    path.moveTo(r, bodyTop);
    final arrowLeft = (arrowOffset).clamp(r, w - r - arrowW);
    final arrowRight = arrowLeft + arrowW;

    path.lineTo(arrowLeft, bodyTop);
    path.lineTo(arrowLeft + arrowW / 2, 0);
    path.lineTo(arrowRight, bodyTop);

    path.lineTo(w - r, bodyTop);
    path.quadraticBezierTo(w, bodyTop, w, bodyTop + r);
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);

    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);

    path.lineTo(0, bodyTop + r);
    path.quadraticBezierTo(0, bodyTop, r, bodyTop);
    path.close();

    if (elevation > 0) {
      canvas.drawShadow(path, Colors.black.withAlpha(153), elevation, true);
    }

    final fill = Paint()..color = color;
    canvas.drawPath(path, fill);

    final stroke =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = borderColor;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) =>
      color != old.color ||
      borderColor != old.borderColor ||
      elevation != old.elevation ||
      radius != old.radius ||
      arrowW != old.arrowW ||
      arrowH != old.arrowH ||
      arrowOffset != old.arrowOffset;
}
