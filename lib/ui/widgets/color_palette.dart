import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:simple_paint/bloc/toolbar_bloc.dart';
import 'package:simple_paint/bloc/toolbar_state.dart';

import '../../bloc/toolbar_event.dart';
import 'my_color_picker.dart';

class ColorPalette extends StatelessWidget {
  final double _radius;
  const ColorPalette({super.key, double radius = 14.0}) : _radius = radius;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToolbarBloc, ToolbarState>(
      builder: (context, toolbarState) {
        return Container(
          alignment: Alignment.topRight,
          child: MyColorPicker(
            arrowOffset: 430,
            radius: _radius,
            child: SizedBox(
              child: BlockPicker(
                pickerColor: toolbarState.strokePen.color,
                layoutBuilder: _layoutBuilder,
                itemBuilder: _itemBuilder,
                onColorChanged:
                    (color) => context.read<ToolbarBloc>().add(
                      ChangeColorEvent(color: color),
                    ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _layoutBuilder(
    BuildContext context,
    List<Color> colors,
    PickerItem child,
  ) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return Container(
      color: Colors.transparent,
      width: orientation == Orientation.portrait ? 40 : 200,
      height: orientation == Orientation.portrait ? 170 : 120,
      child: GridView.count(
        crossAxisCount: orientation == Orientation.portrait ? 1 : 5,
        shrinkWrap: true,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        children: [for (Color color in colors) child(color)],
      ),
    );
  }

  Widget _itemBuilder(
    Color color,
    bool isCurrentColor,
    void Function() changeColor,
  ) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(204),
            offset: const Offset(1, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeColor,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 210),
            opacity: isCurrentColor ? 1 : 0,
            child: Icon(
              Icons.done,
              size: 20,
              color: useWhiteForeground(color) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
