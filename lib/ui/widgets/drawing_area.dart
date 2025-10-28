import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_paint/bloc/image_event.dart';
import 'package:simple_paint/bloc/toolbar_bloc.dart';

import '../../bloc/image_bloc.dart';
import '../../bloc/image_state.dart';
import '../../data/drawn_line.dart';
import '../../services/sketcher.dart';

class DrawingArea extends StatefulWidget {
  final GlobalKey canvasKey;

  const DrawingArea({super.key, required this.canvasKey});

  @override
  State<DrawingArea> createState() => _DrawingAreaState();
}

class _DrawingAreaState extends State<DrawingArea> {
  //late List<DrawnLine> lines;
  // late DrawnLine line;
  // late StreamController<List<DrawnLine>> linesStreamController;
  // late StreamController<DrawnLine> currentLineStreamController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageBloc, ImageState>(
      builder: (context, imageState) {
        if (imageState is ImageLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (imageState is ImageError) {
          Center(child: Text(imageState.message));
        }
        final backgroundImage =
            imageState is ImageLoaded ? imageState.backgroundImage : null;

        final lines =
            imageState is ImageLoaded ? imageState.lines : <DrawnLine>[];
        context.read<ImageBloc>().add(AddLineEvent());

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
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: CombinedSketcher(
                      lines: lines,
                      background: backgroundImage,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  RenderBox? get getRenderBox =>
      widget.canvasKey.currentContext?.findRenderObject() as RenderBox?;

  void onPanStart(DragStartDetails details) {
    final strokePen = context.read<ToolbarBloc>().state.strokePen;
    RenderBox? box = getRenderBox;
    if (box != null) {
      Offset point = box.globalToLocal(details.globalPosition);
      final line = DrawnLine.getByPathAndPen(path: [point], pen: strokePen);
      context.read<ImageBloc>().add(UpdateLineEvent(line: line));
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    final strokePen = context.read<ToolbarBloc>().state.strokePen;
    final imageState = context.read<ImageBloc>().state;
    if (imageState is ImageLoaded) {
      final line = imageState.line;
      if (line != null) {
        final RenderBox? box = getRenderBox;
        if (box != null) {
          final Offset point = box.globalToLocal(details.globalPosition);
          final List<Offset> path = List.from(line.path);
          path.add(point);
          final updatedLine = DrawnLine.getByPathAndPen(
            path: path,
            pen: strokePen,
          );
          context.read<ImageBloc>().add(UpdateLineEvent(line: updatedLine));
          context.read<ImageBloc>().add(AddLineEvent());
        }
      }
    }
  }

  void onPanEnd(DragEndDetails details) {
    context.read<ImageBloc>().add(AddLineEvent());
  }
}
