import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'background_loader_state.dart';

class BackgroundLoaderCubit extends Cubit<BackgroundLoaderState> {
  final String path;

  BackgroundLoaderCubit(this.path) : super(InitialBackgroundState()) {
    _load();
  }

  Future<void> _load() async {
    print('_load');
    emit(LoadingBackgroundState());
    try {
      print('LoadedBackgroundState');
      final data = await rootBundle.load(path);
      print('data');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      print('codec');
      final frame = await codec.getNextFrame();

      //print('frame ${frame.image.width} ${frame.image.height}');
      emit(LoadedBackgroundState(image: frame.image));
    } catch (e) {
      print('ErrorBackgroundState');
      emit(ErrorBackgroundState(message: e.toString()));
    }
  }
}
