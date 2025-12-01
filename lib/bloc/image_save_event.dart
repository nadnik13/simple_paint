import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';

import '../data/drawn_line.dart';

abstract class ImageEvent extends Equatable {
  const ImageEvent();

  @override
  List<Object?> get props => [];
}

class ImageSaveEvent extends ImageEvent {
  final String? imageId;
  final ui.Image image;
  final ui.Image? background;
  final List<DrawnLine> lines;

  const ImageSaveEvent({
    required this.imageId,
    required this.image,
    required this.background,
    required this.lines,
  });

  @override
  List<Object?> get props => [image, background, lines, lines];
}
