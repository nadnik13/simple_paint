import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/stroke_pen.dart';
import 'toolbar_event.dart';
import 'toolbar_state.dart';

class ToolbarBloc extends Bloc<ToolbarEvent, ToolbarState> {
  ToolbarBloc() : super(ToolbarInitial()) {
    on<SelectPencilEvent>(_onSelectPencil);
    on<SelectEraserEvent>(_onSelectEraser);
    on<TogglePaletteEvent>(_onTogglePalette);
    on<ToggleWidthPickerEvent>(_onToggleWidthPicker);
    on<ChangeColorEvent>(_onChangeColor);
    on<ChangeWidthEvent>(_onChangeWidth);
  }

  void _onSelectPencil(SelectPencilEvent event, Emitter<ToolbarState> emit) {
    final updatedPen = state.strokePen.copyWith(type: PenType.pencil);
    emit(state.copyWith(strokePen: updatedPen));
  }

  void _onSelectEraser(SelectEraserEvent event, Emitter<ToolbarState> emit) {
    final updatedPen = state.strokePen.copyWith(type: PenType.eraser);
    emit(
      state.copyWith(
        strokePen: updatedPen,
        isPaletteOpen: false,
        isWidthPickerOpen: false,
      ),
    );
  }

  void _onToggleWidthPicker(
    ToggleWidthPickerEvent event,
    Emitter<ToolbarState> emit,
  ) {
    emit(
      state.copyWith(
        isWidthPickerOpen: !state.isWidthPickerOpen,
        isPaletteOpen: false,
      ),
    );
  }

  void _onTogglePalette(TogglePaletteEvent event, Emitter<ToolbarState> emit) {
    emit(
      state.copyWith(
        isPaletteOpen: !state.isPaletteOpen,
        isWidthPickerOpen: false,
      ),
    );
  }

  void _onChangeColor(ChangeColorEvent event, Emitter<ToolbarState> emit) {
    final updatedPen = state.strokePen.copyWith(color: event.color);
    emit(state.copyWith(strokePen: updatedPen, isPaletteOpen: false));
  }

  void _onChangeWidth(ChangeWidthEvent event, Emitter<ToolbarState> emit) {
    final updatedPen = state.strokePen.copyWith(width: event.width);
    emit(state.copyWith(strokePen: updatedPen, isWidthPickerOpen: false));
  }
}
