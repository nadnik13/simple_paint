import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:simple_paint/data/stroke_pen.dart';

class DrawnLine extends Equatable {
  final List<Offset?> path;
  final Color color;
  final double width;
  final PenType penType;
  BlendMode get blendMode => _getBlendMode(penType);

  const DrawnLine({
    required this.path,
    required this.color,
    this.width = 5,
    required this.penType,
  });

  factory DrawnLine.getByPathAndPen({
    required List<Offset?> path,
    required StrokePen pen,
  }) {
    return DrawnLine(
      path: path,
      color: pen.color,
      width: pen.width,
      penType: pen.type,
    );
  }

  static _getBlendMode(PenType type) {
    switch (type) {
      case PenType.eraser:
        return BlendMode.clear;
      case PenType.pencil:
        return BlendMode.srcOver;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'path':
          path
              .map(
                (offset) =>
                    offset != null ? {'dx': offset.dx, 'dy': offset.dy} : null,
              )
              .toList(),
      'color': color.toARGB32(),
      'width': width,
      'blendMode': blendMode.index,
    };
  }

  factory DrawnLine.fromJson(Map<String, dynamic> json) {
    return DrawnLine(
      path:
          (json['path'] as List).map((point) {
            if (point == null) return null;
            return Offset(point['dx'], point['dy']);
          }).toList(),
      color: Color(json['color']),
      width: json['width'],
      penType: PenType.values[json['penType']],
    );
  }

  @override
  List<Object?> get props => [path, color, width, penType];
}
