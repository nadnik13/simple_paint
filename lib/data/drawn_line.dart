import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:simple_paint/data/stroke_pen.dart';

class DrawnLine extends Equatable {
  final List<Offset?> path;
  final Color color;
  final double width;
  final BlendMode blendMode;

  const DrawnLine({
    required this.path,
    required this.color,
    this.width = 5,
    required this.blendMode,
  });

  static DrawnLine getByPathAndPen({
    required List<Offset?> path,
    required StrokePen pen,
  }) {
    final penType = pen.type;
    return DrawnLine(
      path: path,
      color: pen.color,
      width: pen.width,
      blendMode: _getBlendMode(penType),
    );
  }

  static _getBlendMode(PenType type) {
    switch (type) {
      case PenType.eraser:
        return BlendMode.dstOut;
      case PenType.pencil:
        return BlendMode.srcOver;
    }
  }

  @override
  List<Object?> get props => [path, color, width, blendMode];
}
