import 'dart:ui' as ui;

import 'package:equatable/equatable.dart';

abstract class ImageState extends Equatable {
  const ImageState();

  @override
  List<Object?> get props => [];
}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImageSaving extends ImageState {}

class ImageLoaded extends ImageState {
  final String imageId;
  final ui.Image? backgroundImage;

  const ImageLoaded({
    required this.imageId, 
    this.backgroundImage,
  });

  @override
  List<Object?> get props => [imageId, backgroundImage];
}

class ImageSaved extends ImageState {
  final String imageId;
  final String message;

  const ImageSaved({required this.imageId, required this.message});

  @override
  List<Object?> get props => [imageId, message];
}

class ImageCreated extends ImageState {
  final String imageId;
  final String message;

  const ImageCreated({required this.imageId, required this.message});

  @override
  List<Object?> get props => [imageId, message];
}

class ImageError extends ImageState {
  final String message;

  const ImageError({required this.message});

  @override
  List<Object?> get props => [message];
}
