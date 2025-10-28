import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_paint/bloc/canvas_bloc.dart';
import 'package:simple_paint/bloc/canvas_state.dart';
import 'package:simple_paint/bloc/toolbar_bloc.dart';

import '../../bloc/canvas_event.dart';
import '../../data/drawn_line.dart';
import '../../services/sketcher.dart';

class DrawingArea extends StatefulWidget {
  final GlobalKey canvasKey;
  final List<DrawnLine> lines;
  final ui.Image? background;

  const DrawingArea({
    super.key,
    required this.canvasKey,
    required this.lines,
    required this.background,
  });

  @override
  State<DrawingArea> createState() => _DrawingAreaState();
}

class _DrawingAreaState extends State<DrawingArea> {
  @override
  void initState() {
    print('initeState: ${widget.lines.isNotEmpty}');
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
    return RepaintBoundary(
      key: widget.canvasKey,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onPanStart: onPanStart,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
              child: BlocBuilder<CanvasBloc, CanvasState>(
                builder: (context, canvasState) {
                  print('CanvasState lines: ${canvasState.lines.length} ');
                  print('CanvasState line: ${canvasState.line?.path.length} ');
                  return CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: CombinedSketcher(
                      lines: canvasState.lines,
                      line: canvasState.line,
                      background: canvasState.backgroundImage,
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  //RenderBox? get getRenderBox => context.findRenderObject() as RenderBox?;

  void onPanStart(DragStartDetails details) {
    final strokePen = context.read<ToolbarBloc>().state.strokePen;
    RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box != null) {
      print('onPanStart: box != null');
      Offset point = box.globalToLocal(details.globalPosition);
      final line = DrawnLine.getByPathAndPen(path: [point], pen: strokePen);
      context.read<CanvasBloc>().add(UpdateLineEvent(line: line));
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    final strokePen = context.read<ToolbarBloc>().state.strokePen;
    final canvasState = context.read<CanvasBloc>().state;

    final line = canvasState.line;
    print('onPanUpdate imageState line: ${line}');
    if (line != null) {
      print('onPanUpdate line: != null');
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        print('onPanUpdate box: != null');
        final Offset point = box.globalToLocal(details.globalPosition);
        final List<Offset> path = List.from(line.path);
        path.add(point);
        final updatedLine = DrawnLine.getByPathAndPen(
          path: path,
          pen: strokePen,
        );
        print('onPanUpdate updatedLine: ${updatedLine.path.length}');
        context.read<CanvasBloc>().add(UpdateLineEvent(line: updatedLine));
        context.read<CanvasBloc>().add(AddLineEvent());
      }
    }
  }

  void onPanEnd(DragEndDetails details) {
    context.read<CanvasBloc>().add(AddLineEvent());
  }
}
