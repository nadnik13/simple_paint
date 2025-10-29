import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_paint/bloc/line_event.dart';
import 'package:simple_paint/bloc/line_state.dart';

class LineBloc extends Bloc<LineEvent, LineState> {
  LineBloc() : super(LineInitial()) {
    on<UpdateLineEvent>(_onUpdateLine);
    on<ClearLineEvent>(_onClearLine);
  }

  Future<void> _onUpdateLine(
    UpdateLineEvent event,
    Emitter<LineState> emit,
  ) async {
    emit(state.copyWith(line: event.line));
  }

  Future<void> _onClearLine(
    ClearLineEvent event,
    Emitter<LineState> emit,
  ) async {
    emit(LineInitial());
  }
}
