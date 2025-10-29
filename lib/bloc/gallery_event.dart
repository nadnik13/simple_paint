import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();

  @override
  List<Object> get props => [];
}

class LoadGalleryEvent extends GalleryEvent {
  const LoadGalleryEvent();

  @override
  List<Object> get props => [];
}

class RefreshGalleryEvent extends GalleryEvent {
  final Completer? completer;
  const RefreshGalleryEvent({this.completer});

  @override
  List<Object> get props => [];
}

class ClearGalleryEvent extends GalleryEvent {}
