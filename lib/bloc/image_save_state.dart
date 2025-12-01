import 'package:equatable/equatable.dart';

abstract class ImageSaveState extends Equatable {
  const ImageSaveState();

  @override
  List<Object> get props => [];
}

class ImageSaveInitial extends ImageSaveState {}

class ImageSaveSaving extends ImageSaveState {}

class ImageSaveSaved extends ImageSaveState {}

class ImageSaveError extends ImageSaveState {
  const ImageSaveError({required this.message});

  final String message;
}
