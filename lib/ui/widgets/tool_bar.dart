import 'package:flutter/material.dart';
import 'package:simple_paint/ui/widgets/tool_bar_icon_button.dart';

import '../../data/stroke_pen.dart';

class Toolbar extends StatelessWidget {
  final VoidCallback onPressedExport;
  final VoidCallback onPressedImage;
  final VoidCallback onPressedPen;
  final VoidCallback onPressedErase;
  final VoidCallback onPressedColorLens;
  final PenType? activePenType;
  final bool isPaletteOpen;

  const Toolbar({
    super.key,
    required this.onPressedExport,
    required this.onPressedImage,
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
          iconData: Icons.save_alt_outlined,
          onPressed: onPressedExport,
        ),

        IconButton(
          icon: Image.asset('assets/back.png'),
          onPressed: onPressedImage,
        ),

        ToolBarIconButton(
          iconData: Icons.draw_outlined,
          onPressed: onPressedPen,
          isActive: activePenType == PenType.pencil,
        ),

        ToolBarIconButton(
          iconData: Icons.cleaning_services_outlined,
          onPressed: onPressedErase,
          isActive: activePenType == PenType.eraser,
        ),

        IconButton(
          icon: Image.asset('assets/back.png'),
          onPressed: onPressedColorLens,
          color: isPaletteOpen ? Colors.deepPurple : Colors.white,
        ),
      ],
    );
  }
}
