import 'package:flutter/material.dart';
import 'package:simple_paint/ui/widgets/tool_bar_icon_button.dart';

class Toolbar extends StatelessWidget {
  const Toolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ToolBarIconButton(iconData: Icons.save_alt_outlined, onPressed: () {}),
        SizedBox(width: 8),
        ToolBarIconButton(iconData: Icons.image_outlined, onPressed: () {}),
        SizedBox(width: 8),
        ToolBarIconButton(iconData: Icons.draw_outlined, onPressed: () {}),
        SizedBox(width: 8),
        ToolBarIconButton(iconData: Icons.draw_outlined, onPressed: () {}),
        SizedBox(width: 8),
        ToolBarIconButton(iconData: Icons.color_lens, onPressed: () {}),
      ],
    );
  }
}
