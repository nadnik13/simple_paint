import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../data/stroke_pen.dart';

abstract class ToolbarEvent extends Equatable {
  const ToolbarEvent();

  @override
  List<Object?> get props => [];
}

// Событие экспорта изображения
class ExportImageEvent extends ToolbarEvent {}

// Событие вставки изображения
class InsertImageEvent extends ToolbarEvent {}

// Событие выбора кисти-карандаша
class SelectPencilEvent extends ToolbarEvent {}

// Событие выбора кисти-ластика
class SelectEraserEvent extends ToolbarEvent {}

// Событие переключения палитры
class TogglePaletteEvent extends ToolbarEvent {}

// Событие изменения цвета кисти
class ChangeColorEvent extends ToolbarEvent {
  final Color color;

  const ChangeColorEvent({required this.color});

  @override
  List<Object?> get props => [color];
}

// Событие изменения толщины кисти
class ChangeWidthEvent extends ToolbarEvent {
  final double width;

  const ChangeWidthEvent({required this.width});

  @override
  List<Object?> get props => [width];
}

// Событие обновления кисти
class ChangeStrokePenTypeEvent extends ToolbarEvent {
  final PenType? penType;

  const ChangeStrokePenTypeEvent({required this.penType});

  @override
  List<Object?> get props => [penType];
}
