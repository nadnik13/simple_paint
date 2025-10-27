import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_paint/data/user_repo.dart';

import '../data/fire_image_repo.dart';
import '../services/image_service.dart';
import 'image_event.dart';
import 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final FireImageRepo _imageRepo;
  final UserRepo _userRepo;

  ImageBloc({required FireImageRepo imageRepo, required UserRepo userRepo})
    : _imageRepo = imageRepo,
      _userRepo = userRepo,
      super(ImageInitial()) {
    on<LoadOriginalImageEvent>(_onLoadOriginalImage);
    on<SaveOriginalImageEvent>(_onSaveOriginalImage);
    on<CreateNewImageEvent>(_onCreateNewImage);
    on<ClearImageEvent>(_onClearImage);
  }

  Future<ui.Image?> _loadImageFromBytes(Uint8List? bytes) async {
    if (bytes == null) return null;
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  Future<void> _onLoadOriginalImage(
    LoadOriginalImageEvent event,
    Emitter<ImageState> emit,
  ) async {
    emit(ImageLoading());

    try {
      final originalBytes = await _imageRepo.downloadOriginal(event.imageId);
      final backgroundImage = await _loadImageFromBytes(originalBytes);
      emit(
        ImageLoaded(imageId: event.imageId, backgroundImage: backgroundImage),
      );
    } catch (e) {
      emit(ImageError(message: 'Ошибка загрузки изображения: $e'));
    }
  }

  Future<void> _onSaveOriginalImage(
    SaveOriginalImageEvent event,
    Emitter<ImageState> emit,
  ) async {
    print('_onSaveOriginalImage');
    emit(ImageSaving());

    final Uint8List bytes = await ImageService.getBytes(event.image);

    try {
      await _imageRepo.replaceImage(
        imageId: event.imageId,
        userId: _userRepo.userId,
        originalBytes: bytes,
        previewBytes: ImageService.compressAndResize(bytes),
        mime: 'image/png',
      );

      emit(
        ImageSaved(
          imageId: event.imageId,
          message: 'Изображение успешно сохранено',
        ),
      );
    } catch (e) {
      emit(ImageError(message: 'Ошибка сохранения изображения: $e'));
    }
  }

  Future<void> _onCreateNewImage(
    CreateNewImageEvent event,
    Emitter<ImageState> emit,
  ) async {
    print('_onCreateNewImage');
    print('UserRepo userId: ${_userRepo.userId}');

    // Проверим текущего пользователя Firebase Auth
    final currentUser = FirebaseAuth.instance.currentUser;
    print('Firebase Auth currentUser: ${currentUser?.uid}');
    print('Firebase Auth isSignedIn: ${currentUser != null}');

    if (currentUser == null) {
      print('ОШИБКА: Пользователь не аутентифицирован!');
      emit(ImageError(message: 'Ошибка: пользователь не аутентифицирован'));
      return;
    }

    if (_userRepo.userId != currentUser.uid) {
      print(
        'ПРЕДУПРЕЖДЕНИЕ: userId в UserRepo (${_userRepo.userId}) не совпадает с Firebase Auth (${currentUser.uid})',
      );
    }

    emit(ImageSaving());
    final bytes = await ImageService.getBytes(event.image);
    try {
      print('uploadOriginalWithPreview с userId: ${_userRepo.userId}');
      final imageId = await _imageRepo.uploadOriginalWithPreview(
        userId: _userRepo.userId,
        originalBytes: bytes,
        previewBytes: ImageService.compressAndResize(bytes),
        mime: event.mime,
      );
      emit(
        ImageCreated(imageId: imageId, message: 'Новое изображение создано'),
      );
      print('ImageCreated');
    } catch (e) {
      print('Ошибка создания изображения: $e');
      emit(ImageError(message: 'Ошибка создания изображения: $e'));
    }
  }

  void _onClearImage(ClearImageEvent event, Emitter<ImageState> emit) {
    emit(ImageInitial());
  }
}
