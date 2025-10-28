import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/stroke_pen.dart';
import 'toolbar_event.dart';
import 'toolbar_state.dart';

class ToolbarBloc extends Bloc<ToolbarEvent, ToolbarState> {
  ToolbarBloc() : super(ToolbarInitial()) {
    on<ExportImageEvent>(_onExportImage);
    on<SelectPencilEvent>(_onSelectPencil);
    on<SelectEraserEvent>(_onSelectEraser);
    on<TogglePaletteEvent>(_onTogglePalette);
    on<ChangeColorEvent>(_onChangeColor);
    on<ChangeWidthEvent>(_onChangeWidth);
    on<ChangeStrokePenTypeEvent>(_onUpdateStrokePenType);
  }

  void _onExportImage(ExportImageEvent event, Emitter<ToolbarState> emit) {
    // Логика экспорта изображения будет обрабатываться в UI
    // Здесь можно добавить дополнительную логику если нужно
    print('Экспорт изображения');
  }

  void _onSelectPencil(SelectPencilEvent event, Emitter<ToolbarState> emit) {
    final updatedPen = state.strokePen.copyWith(type: PenType.pencil);
    emit(state.copyWith(strokePen: updatedPen));
  }

  void _onSelectEraser(SelectEraserEvent event, Emitter<ToolbarState> emit) {
    final updatedPen = state.strokePen.copyWith(type: PenType.eraser);
    emit(state.copyWith(strokePen: updatedPen));
  }

  void _onTogglePalette(TogglePaletteEvent event, Emitter<ToolbarState> emit) {
    emit(state.copyWith(isPaletteOpen: !state.isPaletteOpen));
  }

  void _onChangeColor(ChangeColorEvent event, Emitter<ToolbarState> emit) {
    print('_onChangeColor: ${event.color}');
    final updatedPen = state.strokePen.copyWith(color: event.color);
    emit(state.copyWith(strokePen: updatedPen));
  }

  void _onChangeWidth(ChangeWidthEvent event, Emitter<ToolbarState> emit) {
    final updatedPen = state.strokePen.copyWith(width: event.width);
    emit(state.copyWith(strokePen: updatedPen));
  }

  void _onUpdateStrokePenType(
    ChangeStrokePenTypeEvent event,
    Emitter<ToolbarState> emit,
  ) {
    final updatedPen = state.strokePen.copyWith(type: event.penType);
    emit(state.copyWith(strokePen: updatedPen));
  }
}
