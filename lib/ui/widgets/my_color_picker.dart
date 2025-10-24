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
    this.arrowOffset = 24, // смещение носика от левого края
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
        // Добавим паддинги и место для носика сверху
        padding: EdgeInsets.fromLTRB(
          padding.left,
          padding.top + arrowHeight,
          padding.right,
          padding.bottom,
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

    // Основной путь: скруглённый прямоугольник + носик (сверху)
    final path = Path();
    final bodyTop = arrowH; // место под носик
    // Начинаем сверху-слева
    path.moveTo(r, bodyTop);
    // Верхняя кромка до носика
    final arrowLeft = (arrowOffset).clamp(r, w - r - arrowW);
    final arrowRight = arrowLeft + arrowW;

    path.lineTo(arrowLeft, bodyTop);
    // Носик: плавный острый треугольник (можно сделать чуть скруглённым)
    path.lineTo(arrowLeft + arrowW / 2, 0);
    path.lineTo(arrowRight, bodyTop);

    // Верхняя кромка до правого скругления
    path.lineTo(w - r, bodyTop);
    path.quadraticBezierTo(w, bodyTop, w, bodyTop + r);
    // Правая сторона
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);
    // Низ
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);
    // Левая сторона
    path.lineTo(0, bodyTop + r);
    path.quadraticBezierTo(0, bodyTop, r, bodyTop);
    path.close();

    // Тень
    if (elevation > 0) {
      canvas.drawShadow(path, Colors.black.withOpacity(0.6), elevation, true);
    }
    // Заливка
    final fill = Paint()..color = color;
    canvas.drawPath(path, fill);

    // Обводка (тонкая, как на макете)
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
