import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'canvas_event.dart';
import 'canvas_state.dart';

class CanvasBloc extends Bloc<CanvasEvent, CanvasState> {
  CanvasBloc() : super(CanvasInitial()) {
    on<AddLineEvent>(_onAddLine);
    on<AddLinesEvent>(_onAddLines);
    on<AddBackgroundEvent>(_onAddBackground);
  }

  Future<void> _onAddLine(AddLineEvent event, Emitter<CanvasState> emit) async {
    final curLine = event.line;
    final updatedLines = List.of(state.lines);
    updatedLines.add(curLine);
    emit(state.copyWith(lines: updatedLines));
  }

  Future<void> _onAddLines(
    AddLinesEvent event,
    Emitter<CanvasState> emit,
  ) async {
    if (event.lines.isNotEmpty) {
      final updatedLines = List.of(state.lines);
      updatedLines.addAll(event.lines);
      emit(state.copyWith(lines: updatedLines));
    }
  }

  Future<void> _onAddBackground(
    AddBackgroundEvent event,
    Emitter<CanvasState> emit,
  ) async {
    emit(state.copyWith(backgroundImage: event.background));
  }
}
