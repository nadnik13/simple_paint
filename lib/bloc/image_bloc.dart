import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_paint/data/drawn_line.dart';
import 'package:simple_paint/data/user_repo.dart';
import 'package:uuid/uuid.dart';

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
    on<LoadImageEvent>(_onLoadImage);
    on<CreateImageEvent>(_onCreateImage);
    on<SaveImageEvent>(_onSaveImage);
    on<AddLineEvent>(_onAddLine);
    on<UpdateLineEvent>(_onUpdateLine);
    on<AddBackgroundEvent>(_onAddBackground);
  }

  Future<ui.Image?> _loadImageFromBytes(Uint8List? bytes) async {
    print(_loadImageFromBytes);
    if (bytes == null || bytes.isEmpty) return null;
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
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

      print(
        'downloadDataMap['
        'background'
        ']=${downloadDataMap['background']}',
      );
      if (downloadDataMap['background'] != null &&
          downloadDataMap['lines'] != null) {
        final backgroundImage = await _loadImageFromBytes(
          downloadDataMap['background'],
        );
        final lines = _loadLinesFromBytes(downloadDataMap['lines']);
        print('_onLoadImage lines: ${lines.length}');
        emit(
          ImageLoaded(
            imageId: event.imageId,
            backgroundImage: backgroundImage,
            lines: lines,
          ),
        );
      }
    } catch (e) {
      emit(ImageError(message: 'Ошибка загрузки изображения: $e'));
    }
  }

  Future<void> _onCreateImage(
    CreateImageEvent event,
    Emitter<ImageState> emit,
  ) async {
    emit(ImageLoading());
    String imageId = Uuid().v4();
    emit(
      ImageLoaded(imageId: null, backgroundImage: null, lines: [], line: null),
    );
  }

  Future<void> _onSaveImage(
    SaveImageEvent event,
    Emitter<ImageState> emit,
  ) async {
    print('_onSaveImage');
    emit(ImageSaving());

    final Uint8List bytes = await ImageService.getBytes(event.image);
    final Uint8List bgBytes = await ImageService.getBytes(event.background);
    final jsonString = jsonEncode(event.lines.map((l) => l.toJson()).toList());
    final linesBytes = Uint8List.fromList(utf8.encode(jsonString));

    print('event.lines ${event.lines.length} linesBytes ${linesBytes.length}');
    try {
      final imageId = await _imageRepo.saveImage(
        imageId: event.imageId,
        userId: _userRepo.userId,
        bgBytes: bgBytes,
        previewBytes: ImageService.compressAndResize(bytes),
        linesBytes: linesBytes,
      );

      emit(ImageSaved(imageId: imageId, message: 'Изображение сохранено'));
    } catch (e) {
      emit(ImageError(message: 'Ошибка сохранения изображения: $e'));
    }
  }

  Future<void> _onAddLine(AddLineEvent event, Emitter<ImageState> emit) async {
    final curState = state;
    if (curState is ImageLoaded) {
      final curLine = curState.line;
      if (curLine != null) {
        final updatedLines = List.of(curState.lines);
        updatedLines.add(curLine);
        emit(curState.copyWith(lines: updatedLines));
      }
    }
  }

  Future<void> _onUpdateLine(
    UpdateLineEvent event,
    Emitter<ImageState> emit,
  ) async {
    final curState = state;
    if (curState is ImageLoaded) {
      emit(curState.copyWith(line: event.line));
    }
  }

  Future<void> _onAddBackground(
    AddBackgroundEvent event,
    Emitter<ImageState> emit,
  ) async {
    final curState = state;
    if (curState is ImageLoaded) {
      emit(curState.copyWith(backgroundImage: event.background));
    }
  }
}
