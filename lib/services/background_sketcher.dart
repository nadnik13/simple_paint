import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class BackgroundSketcher extends CustomPainter {
  final ui.Image? background;

  BackgroundSketcher({this.background});

  @override
  void paint(Canvas canvas, Size size) {
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
  }

  @override
  bool shouldRepaint(BackgroundSketcher oldDelegate) {
    return true;
  }
}
