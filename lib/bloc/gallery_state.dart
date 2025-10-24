import 'package:equatable/equatable.dart';

import '../data/preview_item.dart';

abstract class GalleryState extends Equatable {
  const GalleryState();

  @override
  List<Object?> get props => [];
}

class GalleryInitialState extends GalleryState {}

class GalleryLoadingState extends GalleryState {}

class GalleryLoadedState extends GalleryState {
  final List<ImageInfoItem> images;
  final String userId;

  const GalleryLoadedState({required this.images, required this.userId});

  @override
  List<Object?> get props => [images, userId];
}

class ImageLoaderEmpty extends GalleryState {
  final String userId;

  const ImageLoaderEmpty({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class ImageLoaderError extends GalleryState {
  final String message;

  const ImageLoaderError({required this.message});

  @override
  List<Object?> get props => [message];
}
