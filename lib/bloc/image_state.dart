import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';
import 'package:simple_paint/data/drawn_line.dart';

abstract class ImageState extends Equatable {
  const ImageState();

  @override
  List<Object?> get props => [];
}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImageSaving extends ImageState {}

class ImageLoaded extends ImageState {
  final String? imageId;
  final ui.Image? backgroundImage;
  final List<DrawnLine> lines;
  final DrawnLine? line;

  const ImageLoaded({
    required this.imageId,
    this.backgroundImage,
    required this.lines,
    this.line,
  });

  ImageLoaded copyWith({
    List<DrawnLine>? lines,
    ui.Image? backgroundImage,
    DrawnLine? line,
  }) {
    final state = ImageLoaded(
      imageId: imageId,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      lines: lines ?? this.lines,
      line: line ?? this.line,
    );
    return state;
  }

  @override
  List<Object?> get props => [imageId, backgroundImage, lines, line];
}

class ImageSaved extends ImageState {
  final String imageId;
  final String message;

  const ImageSaved({required this.imageId, required this.message});

  @override
  List<Object?> get props => [imageId, message];
}

class ImageError extends ImageState {
  final String message;

  const ImageError({required this.message});

  @override
  List<Object?> get props => [message];
}
