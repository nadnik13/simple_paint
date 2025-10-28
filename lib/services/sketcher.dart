import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/drawn_line.dart';

class BackGroundSketcher extends CustomPainter {
  final ui.Image? background;

  BackGroundSketcher({this.background});

  @override
  void paint(Canvas canvas, Size size) {
    // Отрисовываем фон
    if (background != null) {
      print('background: not null');
      // Если есть изображение фона, рисуем его
      canvas.drawImage(
        background!,
        Offset.zero,
        Paint()..style = PaintingStyle.fill,
      );
    } else {
      // Если нет изображения фона, рисуем белый фон
      print('background: is null ${size.width} ${size.height}');
      final whitePaint =
          Paint()
            ..color = Colors.green
            ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), whitePaint);
    }
  }

  @override
  bool shouldRepaint(BackGroundSketcher oldDelegate) {
    return true;
  }
}

class Sketcher extends CustomPainter {
  final List<DrawnLine> lines;
  final ui.Image? background;

  Sketcher({required this.lines, this.background});

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

class CombinedSketcher extends CustomPainter {
  final List<DrawnLine> lines;
  final DrawnLine? line;
  final ui.Image? background;

  CombinedSketcher({required this.lines, required this.line, this.background});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(Offset(10, 10), Offset(1000, 1000), Paint());
    print('CombinedSketcher lines: ${lines.length} ');
    print('CombinedSketcher line: ${line?.path.length} ');

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    if (background != null) {
      canvas.drawImage(
        background!,
        Offset.zero,
        Paint()..style = PaintingStyle.fill,
      );
    } else {
      final whitePaint =
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(20)),
        whitePaint,
      );
    }
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Затем рисуем все линии
    Paint basePaint =
        Paint()
          ..color = Colors.redAccent
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = 5.0;

    final lastLine = line;
    if (lastLine != null && lastLine.path.isNotEmpty) {
      if (lines.isNotEmpty) lines.removeLast();
      lines.add(lastLine);
    }

    for (int i = 0; i < lines.length; ++i) {
      final line = lines[i];
      print('pathi $i line.path.length ${line.path.length}');
      for (int j = 0; j < line.path.length - 1; ++j) {
        print('pathi $i line.path.length ${line.path.length}');
        final pathJ = line.path[j];
        final pathJJ = line.path[j + 1];
        if (pathJ != null && pathJJ != null) {
          print('pathJ ${pathJ} pathJJ ${pathJJ}');
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
    canvas.restore();
  }

  @override
  bool shouldRepaint(CombinedSketcher oldDelegate) {
    return true;
  }
}
