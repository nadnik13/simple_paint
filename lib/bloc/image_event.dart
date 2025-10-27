import 'dart:ui' as ui;

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
  final ui.Image image;

  const SaveOriginalImageEvent({required this.imageId, required this.image});

  @override
  List<Object> get props => [imageId, image];
}

class CreateNewImageEvent extends ImageEvent {
  final ui.Image image;
  final String mime;

  const CreateNewImageEvent({required this.image, required this.mime});

  @override
  List<Object> get props => [image, mime];
}

class ClearImageEvent extends ImageEvent {}
