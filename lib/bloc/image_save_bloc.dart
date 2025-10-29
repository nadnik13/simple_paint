import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/fire_image_repo.dart';
import '../data/user_repo.dart';
import '../services/image_service.dart';
import 'image_save_event.dart';
import 'image_save_state.dart';

class ImageSaveBloc extends Bloc<ImageSaveEvent, ImageSaveState> {
  ImageSaveBloc({required UserRepo userRepo, required FireImageRepo imageRepo})
    : _userRepo = userRepo,
      _imageRepo = imageRepo,
      super(ImageSaveInitial()) {
    on<ImageSaveEvent>(_onSaveImage);
  }

  final UserRepo _userRepo;
  final FireImageRepo _imageRepo;

  Future<void> _onSaveImage(
    ImageSaveEvent event,
    Emitter<ImageSaveState> emit,
  ) async {
    emit(ImageSaveSaving());
    final Uint8List bytes = await ImageService.getBytes(event.image);
    final Uint8List bgBytes = await ImageService.getBytes(event.background);
    final jsonString = jsonEncode(event.lines.map((l) => l.toJson()).toList());
    final linesBytes = Uint8List.fromList(utf8.encode(jsonString));
    final previewBytes = ImageService.compressAndResize(bytes);
    try {
      await _imageRepo.saveImage(
        imageId: event.imageId,
        userId: _userRepo.userId,
        bgBytes: bgBytes,
        previewBytes: previewBytes,
        linesBytes: linesBytes,
      );

      emit(ImageSaveSaved());
    } catch (e) {
      emit(ImageSaveError(message: 'Ошибка сохранения изображения: $e'));
    }
  }
}
