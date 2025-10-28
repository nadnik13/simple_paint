import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_paint/data/user_repo.dart';

import '../data/fire_image_repo.dart';
import '../data/preview_item.dart';
import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final FireImageRepo _imageRepo;
  final UserRepo _userRepo;

  StreamSubscription<List<ImageInfoItem>>? _imagesSubscription;

  GalleryBloc({required FireImageRepo imageRepo, required UserRepo userRepo})
    : _imageRepo = imageRepo,
      _userRepo = userRepo,
      super(GalleryInitialState()) {
    on<LoadGalleryEvent>(_onLoadUserImages);
    on<RefreshGalleryEvent>(_onRefreshImages);
    on<ClearGalleryEvent>(_onClearImages);
  }

  Future<void> _onLoadUserImages(
    LoadGalleryEvent event,
    Emitter<GalleryState> emit,
  ) async {
    print('_onLoadUserImages started for userId: ${_userRepo.userId}');

    // Проверяем, что userId не пустой
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

    print('Cancelling previous subscription...');
    // Отменяем предыдущую подписку если есть
    await _imagesSubscription?.cancel();
    _imagesSubscription = null;
    print('Previous subscription cancelled');

    print('Creating new stream subscription...');
    // Создаем новую подписку на стрим превью
    try {
      final images = await _imageRepo.previews(_userRepo.userId);

      print('Stream received ${images.length} images');

      if (images.isEmpty) {
        print('No images found - emitting empty state');
        emit(GalleryIsEmpty(userId: _userRepo.userId));
      } else {
        print('Emitting loaded state with ${images.length} images');
        emit(GalleryLoadedState(images: images, userId: _userRepo.userId));
      }
    } catch (error, stackTrace) {
      print('Stream error: $error');
      print('Stack trace: $stackTrace');
      // Проверяем, что emitter еще активен перед вызовом emit
      if (!emit.isDone) {
        emit(
          GalleryLoadingError(message: 'Ошибка загрузки изображений: $error'),
        );
      }
    }
    print('_onLoadUserImages ended for userId: ${_userRepo.userId}');
  }

  Future<void> _onRefreshImages(
    RefreshGalleryEvent event,
    Emitter<GalleryState> emit,
  ) async {
    print('_onRefreshImages for userId: ${_userRepo.userId}');

    // Проверяем, что userId не пустой
    if (_userRepo.userId.isEmpty) {
      if (!emit.isDone) {
        emit(
          GalleryLoadingError(message: 'ID пользователя не может быть пустым'),
        );
      }
      return;
    }

    // Отменяем текущую подписку и создаем новую
    try {
      await _imagesSubscription?.cancel();
      _imagesSubscription = null;

      // Вызываем загрузку напрямую, а не через add() чтобы избежать рекурсии
      await _onLoadUserImages(LoadGalleryEvent(), emit);
    } catch (e) {
      print('Error in _onRefreshImages: $e');
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
