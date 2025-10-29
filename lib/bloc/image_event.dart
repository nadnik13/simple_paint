import 'package:equatable/equatable.dart';

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

class CreateImageEvent extends ImageEvent {
  const CreateImageEvent();
}
