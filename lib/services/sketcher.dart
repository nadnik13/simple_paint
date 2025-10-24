import 'package:flutter/material.dart';

import '../data/drawn_line.dart';

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;

  Sketcher({required this.lines});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint =
        Paint()
          ..color = Colors.redAccent
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 5.0;

    for (int i = 0; i < lines.length; ++i) {
      final line = lines[i];
      //if (line == null) continue;
      for (int j = 0; j < line.path.length - 1; ++j) {
        final pathJ = line.path[j];
        final pathJJ = line.path[j + 1];
        if (pathJ != null && pathJJ != null) {
          paint.color = line.color;
          paint.strokeWidth = line.width;
          canvas.drawLine(pathJ, pathJJ, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(Sketcher oldDelegate) {
    return true;
  }
}
