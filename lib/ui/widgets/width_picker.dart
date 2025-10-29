import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_paint/bloc/toolbar_bloc.dart';
import 'package:simple_paint/bloc/toolbar_event.dart';
import 'package:simple_paint/bloc/toolbar_state.dart';

import 'my_color_picker.dart';

class WidthPicker extends StatelessWidget {
  final double _radius;

  const WidthPicker({super.key, double radius = 14.0}) : _radius = radius;

  static const List<double> _widths = [3.0, 7.0, 11.0, 15.0, 19.0];

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    return Positioned(
      right: 95,
      child: BlocBuilder<ToolbarBloc, ToolbarState>(
        builder: (context, toolbarState) {
          return Container(
            alignment: Alignment.topRight,
            child: MyColorPicker(
              arrowOffset: 350,
              radius: _radius,
              child: SizedBox(
                child: Container(
                  color: Colors.transparent,
                  width: orientation == Orientation.portrait ? 40 : 200,
                  child: GridView.count(
                    crossAxisCount: orientation == Orientation.portrait ? 1 : 5,
                    shrinkWrap: true,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    children:
                        _widths.map((width) {
                          final color = toolbarState.strokePen.color;
                          return Container(
                            margin: const EdgeInsets.all(5),
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  context.read<ToolbarBloc>().add(
                                    ChangeWidthEvent(width: width),
                                  );
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Center(
                                  child: Container(
                                    width: width.clamp(2.0, 15.0),
                                    height: width.clamp(2.0, 15.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          toolbarState.strokePen.width == width
                                              ? color
                                              : color.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
