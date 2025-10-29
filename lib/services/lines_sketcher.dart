import 'package:flutter/material.dart';

import '../data/drawn_line.dart';

class LinesSketcher extends CustomPainter {
  final List<DrawnLine> lines;

  LinesSketcher({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    Paint basePaint =
        Paint()
          ..color = Colors.redAccent
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      final line = lines[i];
      for (int j = 0; j < line.path.length - 1; ++j) {
        final pathJ = line.path[j];
        final pathJJ = line.path[j + 1];
        if (pathJ != null && pathJJ != null) {
          final paint =
              basePaint
                ..color = line.color
                ..strokeWidth = line.width
                ..blendMode = line.blendMode;
          canvas.drawLine(pathJ, pathJJ, paint);
        }
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(LinesSketcher oldDelegate) {
    return true;
  }
}
