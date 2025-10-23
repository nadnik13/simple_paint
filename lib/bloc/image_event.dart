import 'dart:typed_data';

import 'package:equatable/equatable.dart';

abstract class ImageEvent extends Equatable {
  const ImageEvent();

  @override
  List<Object> get props => [];
}

class LoadOriginalImageEvent extends ImageEvent {
  final String imageId;
  final String userId;

  const LoadOriginalImageEvent({required this.imageId, required this.userId});

  @override
  List<Object> get props => [imageId];
}

class SaveOriginalImageEvent extends ImageEvent {
  final String imageId;
  final Uint8List originalBytes;

  const SaveOriginalImageEvent({
    required this.imageId,
    required this.originalBytes,
  });

  @override
  List<Object> get props => [imageId, originalBytes];
}

class CreateNewImageEvent extends ImageEvent {
  final Uint8List originalBytes;
  final String mime;

  const CreateNewImageEvent({required this.originalBytes, required this.mime});

  @override
  List<Object> get props => [originalBytes, mime];
}

class ClearImageEvent extends ImageEvent {}
