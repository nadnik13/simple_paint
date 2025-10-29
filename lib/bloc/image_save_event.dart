import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';

import '../data/drawn_line.dart';

class ImageSaveEvent extends Equatable {
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
  List<Object> get props {
    final bg = background;
    return bg != null ? [image, bg, lines, lines] : [image, lines, lines];
  }
}
