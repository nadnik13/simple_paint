import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';

import '../data/drawn_line.dart';

abstract class ImageEvent extends Equatable {
  const ImageEvent();

  @override
  List<Object> get props => [];
}

class LoadImageEvent extends ImageEvent {
  final String imageId;

  const LoadImageEvent({required this.imageId});

  @override
  List<Object> get props => [imageId];
}

class SaveImageEvent extends ImageEvent {
  final String? imageId;
  final ui.Image image;
  final ui.Image? background;
  final List<DrawnLine> lines;

  const SaveImageEvent({
    required this.imageId,
    required this.image,
    required this.background,
    required this.lines,
  });

  @override
  List<Object> get props => [image, lines, lines];
}

class CreateImageEvent extends ImageEvent {
  const CreateImageEvent();

  @override
  List<Object> get props => [];
}

class AddLineEvent extends ImageEvent {
  const AddLineEvent();

  @override
  List<Object> get props => [];
}

class AddBackgroundEvent extends ImageEvent {
  final ui.Image background;
  const AddBackgroundEvent({required this.background});

  @override
  List<Object> get props => [background];
}

class UpdateLineEvent extends ImageEvent {
  final DrawnLine line;
  const UpdateLineEvent({required this.line});

  @override
  List<Object> get props => [line];
}
