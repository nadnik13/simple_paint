import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_paint/data/user_repo.dart';

import '../data/gallery_repo.dart';
import '../data/preview_item.dart';
import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GalleryRepo _galleryRepo;
  final UserRepo _userRepo;

  StreamSubscription<List<ImageInfoItem>>? _imagesSubscription;

  GalleryBloc({required GalleryRepo galleryRepo, required UserRepo userRepo})
    : _galleryRepo = galleryRepo,
      _userRepo = userRepo,
      super(GalleryInitialState()) {
    on<LoadGalleryEvent>(_onLoadUserImages);
    on<RefreshGalleryEvent>(_onRefreshImages);
    on<ClearGalleryEvent>(_onClearImages);
  }

  Future<void> _loadImages() async {
    await _imagesSubscription?.cancel();
    _imagesSubscription = null;

    final images = await _galleryRepo.getPreviews(_userRepo.userId);

    if (images.isEmpty) {
      emit(GalleryIsEmpty(userId: _userRepo.userId));
    } else {
      emit(GalleryLoadedState(images: images));
    }
  }

  Future<void> _onLoadUserImages(
    LoadGalleryEvent event,
    Emitter<GalleryState> emit,
  ) async {
    if (_userRepo.userId.isEmpty) {
      if (!emit.isDone) {
        emit(
          GalleryLoadingError(message: 'ID пользователя не может быть пустым'),
        );
      }
      return;
    }

    if (!emit.isDone) {
      emit(GalleryLoadingState());
    }

    try {
      await _loadImages();
    } catch (error) {
      if (!emit.isDone) {
        emit(
          GalleryLoadingError(message: 'Ошибка загрузки изображений: $error'),
        );
      }
    }
  }

  Future<void> _onRefreshImages(
    RefreshGalleryEvent event,
    Emitter<GalleryState> emit,
  ) async {
    if (_userRepo.userId.isEmpty) {
      if (!emit.isDone) {
        emit(
          GalleryLoadingError(message: 'ID пользователя не может быть пустым'),
        );
      }
      return;
    }

    try {
      await _imagesSubscription?.cancel();
      _imagesSubscription = null;

      await _loadImages();
      event.completer?.complete();
    } catch (e) {
      if (!emit.isDone) {
        emit(GalleryLoadingError(message: 'Ошибка обновления: $e'));
      }
    }
  }

  void _onClearImages(ClearGalleryEvent event, Emitter<GalleryState> emit) {
    _imagesSubscription?.cancel();
    _imagesSubscription = null;
    if (!emit.isDone) {
      emit(GalleryInitialState());
    }
  }

  @override
  Future<void> close() {
    _imagesSubscription?.cancel();
    return super.close();
  }
}
