import 'dart:typed_data';

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
  final String userId;
  final Uint8List originalBytes;

  const ImageLoaded({
    required this.imageId,
    required this.userId,
    required this.originalBytes,
  });

  @override
  List<Object?> get props => [imageId, userId, originalBytes];
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
