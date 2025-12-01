import 'dart:ui' as ui;

abstract class BackgroundLoaderState {
  const BackgroundLoaderState();
}

class InitialBackgroundState extends BackgroundLoaderState {}

class LoadingBackgroundState extends BackgroundLoaderState {}

class LoadedBackgroundState extends BackgroundLoaderState {
  final ui.Image image;

  LoadedBackgroundState({required this.image});
}

class ErrorBackgroundState extends BackgroundLoaderState {
  const ErrorBackgroundState({required this.message});

  final String message;
}
