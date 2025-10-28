import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';

import '../data/drawn_line.dart';

class CanvasState extends Equatable {
  final ui.Image? backgroundImage;
  final List<DrawnLine> lines;
  final DrawnLine? line;

  const CanvasState({this.backgroundImage, required this.lines, this.line});

  CanvasState copyWith({
    List<DrawnLine>? lines,
    ui.Image? backgroundImage,
    DrawnLine? line,
  }) {
    print('CanvasState copyWith ${line ?? this.line}');
    return CanvasState(
      backgroundImage: backgroundImage ?? this.backgroundImage,
      lines: lines ?? this.lines,
      line: line ?? this.line,
    );
  }

  @override
  List<Object?> get props => [backgroundImage, lines, line];
}

class CanvasInitial extends CanvasState {
  CanvasInitial()
    : super(backgroundImage: null, lines: <DrawnLine>[], line: null);
}
