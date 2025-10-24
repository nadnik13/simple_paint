import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DrawnLine extends Equatable {
  final List<Offset?> path;
  final Color color;
  final double width;

  const DrawnLine({required this.path, required this.color, this.width = 5.0});

  @override
  List<Object?> get props => [path, color, width];
}
