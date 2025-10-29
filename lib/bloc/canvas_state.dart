import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

import '../data/drawn_line.dart';

class CanvasState extends Equatable {
  final ui.Image? backgroundImage;
  final List<DrawnLine> lines;
  final GlobalKey key;

  const CanvasState({
    this.backgroundImage,
    required this.lines,
    required this.key,
  });

  CanvasState copyWith({
    List<DrawnLine>? lines,
    ui.Image? backgroundImage,
    DrawnLine? line,
  }) {
    return CanvasState(
      key: key,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      lines: lines ?? this.lines,
    );
  }

  @override
  List<Object?> get props => [key, backgroundImage, lines];
}

class CanvasInitial extends CanvasState {
  CanvasInitial()
    : super(key: GlobalKey(), backgroundImage: null, lines: <DrawnLine>[]);
}
