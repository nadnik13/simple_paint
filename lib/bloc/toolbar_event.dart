import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../data/stroke_pen.dart';

abstract class ToolbarEvent extends Equatable {
  const ToolbarEvent();

  @override
  List<Object?> get props => [];
}

class ExportImageEvent extends ToolbarEvent {}

class SelectPencilEvent extends ToolbarEvent {}

class SelectEraserEvent extends ToolbarEvent {}

class TogglePaletteEvent extends ToolbarEvent {}

class ChangeColorEvent extends ToolbarEvent {
  final Color color;

  const ChangeColorEvent({required this.color});

  @override
  List<Object?> get props => [color];
}

class ChangeWidthEvent extends ToolbarEvent {
  final double width;

  const ChangeWidthEvent({required this.width});

  @override
  List<Object?> get props => [width];
}

class ChangeStrokePenTypeEvent extends ToolbarEvent {
  final PenType? penType;

  const ChangeStrokePenTypeEvent({required this.penType});

  @override
  List<Object?> get props => [penType];
}
