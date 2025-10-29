import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../data/stroke_pen.dart';

class ToolbarState extends Equatable {
  final StrokePen strokePen;
  final bool isPaletteOpen;
  final bool isWidthPickerOpen;

  const ToolbarState({
    required this.strokePen,
    this.isPaletteOpen = false,
    this.isWidthPickerOpen = false,
  });

  ToolbarState copyWith({
    StrokePen? strokePen,
    bool? isPaletteOpen,
    bool? isWidthPickerOpen,
  }) {
    return ToolbarState(
      strokePen: strokePen ?? this.strokePen,
      isPaletteOpen: isPaletteOpen ?? this.isPaletteOpen,
      isWidthPickerOpen: isWidthPickerOpen ?? this.isWidthPickerOpen,
    );
  }

  @override
  List<Object?> get props => [strokePen, isPaletteOpen, isWidthPickerOpen];
}

class ToolbarInitial extends ToolbarState {
  const ToolbarInitial()
    : super(
        strokePen: const StrokePen(
          color: Colors.black,
          width: 5.0,
          type: PenType.pencil,
        ),
        isPaletteOpen: false,
        isWidthPickerOpen: false,
      );
}
