import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_paint/bloc/canvas_bloc.dart';
import 'package:simple_paint/bloc/canvas_state.dart';
import 'package:simple_paint/bloc/line_bloc.dart';
import 'package:simple_paint/bloc/line_state.dart';
import 'package:simple_paint/bloc/toolbar_bloc.dart';
import 'package:simple_paint/services/background_sketcher.dart';
import 'package:simple_paint/services/lines_sketcher.dart';

import '../../bloc/canvas_event.dart';
import '../../bloc/line_event.dart';
import '../../data/drawn_line.dart';

class DrawingArea extends StatefulWidget {
  final List<DrawnLine> lines;
  final ui.Image? background;

  const DrawingArea({super.key, required this.lines, required this.background});

  @override
  State<DrawingArea> createState() => _DrawingAreaState();
}

class _DrawingAreaState extends State<DrawingArea> {
  @override
  void initState() {
    if (widget.lines.isNotEmpty) {
      context.read<CanvasBloc>().add(AddLinesEvent(lines: widget.lines));
    }
    final bg = widget.background;
    if (bg != null) {
      context.read<CanvasBloc>().add(AddBackgroundEvent(background: bg));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasBloc, CanvasState>(
      builder: (context, canvasState) {
        return RepaintBoundary(
          key: canvasState.key,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return BlocBuilder<LineBloc, LineState>(
                  builder: (context, lineState) {
                    final line = lineState.line;
                    return GestureDetector(
                      onPanStart: onPanStart,
                      onPanUpdate: onPanUpdate,
                      onPanEnd: onPanEnd,
                      child: Stack(
                        children: [
                          CustomPaint(
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            painter: BackgroundSketcher(
                              background: canvasState.backgroundImage,
                            ),
                          ),
                          CustomPaint(
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                            painter: LinesSketcher(
                              lines: [
                                ...canvasState.lines,
                                if (line != null) line,
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void onPanStart(DragStartDetails details) {
    final strokePen = context.read<ToolbarBloc>().state.strokePen;
    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset point = box.globalToLocal(details.globalPosition);
      final line = DrawnLine.getByPathAndPen(path: [point], pen: strokePen);
      context.read<LineBloc>().add(UpdateLineEvent(line: line));
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    final strokePen = context.read<ToolbarBloc>().state.strokePen;
    final lineState = context.read<LineBloc>().state;

    final line = lineState.line;
    if (line != null) {
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final Offset point = box.globalToLocal(details.globalPosition);
        final List<Offset> path = List.from(line.path);
        path.add(point);
        final updatedLine = DrawnLine.getByPathAndPen(
          path: path,
          pen: strokePen,
        );
        context.read<LineBloc>().add(UpdateLineEvent(line: updatedLine));
      }
    }
  }

  void onPanEnd(DragEndDetails details) {
    final line = context.read<LineBloc>().state.line;
    if (line != null) {
      context.read<CanvasBloc>().add(AddLineEvent(line: line));
      context.read<LineBloc>().add(ClearLineEvent());
    }
  }
}
