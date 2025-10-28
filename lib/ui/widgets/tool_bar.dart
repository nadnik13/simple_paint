import 'package:flutter/material.dart';
import 'package:simple_paint/ui/widgets/tool_bar_icon_button.dart';

import '../../data/stroke_pen.dart';
import '../../services/image_picker_button.dart';

class Toolbar extends StatelessWidget {
  final VoidCallback onPressedExport;
  final VoidCallback onPressedPen;
  final VoidCallback onPressedErase;
  final VoidCallback onPressedColorLens;
  final PenType? activePenType;
  final bool isPaletteOpen;

  const Toolbar({
    super.key,
    required this.onPressedExport,
    required this.onPressedPen,
    required this.onPressedErase,
    required this.onPressedColorLens,
    this.activePenType,
    this.isPaletteOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 8,
      children: [
        ToolBarIconButton(
          icon: Image.asset('assets/download.png'),
          onPressed: onPressedExport,
        ),

        ImagePickerButton(),

        ToolBarIconButton(
          icon: Image.asset('assets/pen.png'),
          onPressed: onPressedPen,
          isActive: activePenType == PenType.pencil,
        ),

        ToolBarIconButton(
          icon: Image.asset('assets/eraser.png'),
          onPressed: onPressedErase,
          isActive: activePenType == PenType.eraser,
        ),

        ToolBarIconButton(
          icon: Image.asset('assets/palette.png'),
          onPressed: onPressedColorLens,
          isActive: isPaletteOpen,
        ),
      ],
    );
  }
}
