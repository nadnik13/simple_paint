import 'package:equatable/equatable.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object> get props => [];
}

class LoadUserImagesEvent extends GalleryEvent {
  const LoadUserImagesEvent();

  @override
  List<Object> get props => [];
}

class RefreshImagesEvent extends GalleryEvent {
  const RefreshImagesEvent();

  @override
  List<Object> get props => [];
}

class ClearImagesEvent extends GalleryEvent {}
