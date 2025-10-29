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

  const GalleryLoadedState({required this.images});

  @override
  List<Object?> get props => [images];
}

class GalleryIsEmpty extends GalleryState {
  final String userId;

  const GalleryIsEmpty({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class GalleryLoadingError extends GalleryState {
  final String message;

  const GalleryLoadingError({required this.message});

  @override
  List<Object?> get props => [message];
}
