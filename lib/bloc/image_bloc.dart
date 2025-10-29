import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_paint/data/drawn_line.dart';

import '../data/fire_image_repo.dart';
import 'image_event.dart';
import 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final FireImageRepo _imageRepo;

  ImageBloc({required FireImageRepo imageRepo})
    : _imageRepo = imageRepo,
      super(ImageInitial()) {
    on<LoadImageEvent>(_onLoadImage);
    on<CreateImageEvent>(_onCreateImage);
  }

  Future<ui.Image?> _loadImageFromBytes(Uint8List? bytes) async {
    if (bytes == null) return null;
    if (bytes.isEmpty) return null;

    try {
      final Completer<ui.Image> completer = Completer();
      ui.decodeImageFromList(bytes, (ui.Image img) {
        completer.complete(img);
      });
      return completer.future;
    } catch (e) {
      return null;
    }
  }

  List<DrawnLine> _loadLinesFromBytes(Uint8List? uint8List) {
    final jsonString = uint8List != null ? utf8.decode(uint8List) : '';
    final decoded = jsonDecode(jsonString) as List;
    return decoded.map((e) => DrawnLine.fromJson(e)).toList();
  }

  Future<void> _onLoadImage(
    LoadImageEvent event,
    Emitter<ImageState> emit,
  ) async {
    emit(ImageLoading());
    try {
      final downloadDataMap = await _imageRepo.downloadData(event.imageId);

      if (downloadDataMap['background'] != null &&
          downloadDataMap['lines'] != null &&
          (downloadDataMap['background']!.isNotEmpty ||
              downloadDataMap['lines']!.isNotEmpty) &&
          downloadDataMap['lines'] != null) {
        final backgroundImage = await _loadImageFromBytes(
          downloadDataMap['background'],
        );
        final lines = _loadLinesFromBytes(downloadDataMap['lines']);
        emit(
          ImageLoaded(
            imageId: event.imageId,
            backgroundImage: backgroundImage,
            lines: lines,
          ),
        );
      }
    } on FormatException catch (a, e) {
      emit(ImageError(message: 'Ошибка загрузки изображения: $e $a'));
    }
  }

  Future<void> _onCreateImage(
    CreateImageEvent event,
    Emitter<ImageState> emit,
  ) async {
    emit(ImageLoading());
    emit(
      ImageLoaded(
        imageId: null,
        backgroundImage: null,
        lines: <DrawnLine>[],
        line: null,
      ),
    );
  }
}
