import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum PenType {
  pencil, // карандаш
  eraser, // ластик
}

class StrokePen extends Equatable {
  final Color color;
  final double width;
  final PenType type;

  const StrokePen({
    required this.color,
    required this.width,
    required this.type,
  });

  StrokePen copyWith({Color? color, double? width, PenType? type}) {
    return StrokePen(
      color: color ?? this.color,
      width: width ?? this.width,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [color, width, type];
}
