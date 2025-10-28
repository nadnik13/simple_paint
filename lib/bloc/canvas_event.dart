import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';

import '../data/drawn_line.dart';

abstract class CanvasEvent extends Equatable {
  const CanvasEvent();

  @override
  List<Object> get props => [];
}

class SaveCanvasEvent extends CanvasEvent {
  final ui.Image? background;
  final List<DrawnLine> lines;

  const SaveCanvasEvent({required this.background, required this.lines});

  @override
  List<Object> get props {
    final bg = background;
    return (bg != null) ? [bg, lines] : [lines];
  }
}

class AddLinesEvent extends CanvasEvent {
  final List<DrawnLine> lines;
  const AddLinesEvent({required this.lines});

  @override
  List<Object> get props => [lines];
}

class AddLineEvent extends CanvasEvent {
  const AddLineEvent();

  @override
  List<Object> get props => [];
}

class UpdateLineEvent extends CanvasEvent {
  final DrawnLine line;
  const UpdateLineEvent({required this.line});

  @override
  List<Object> get props => [line];
}

class AddBackgroundEvent extends CanvasEvent {
  final ui.Image background;

  const AddBackgroundEvent({required this.background});

  @override
  List<Object> get props => [background];
}
