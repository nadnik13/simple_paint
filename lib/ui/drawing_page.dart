import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/canvas_bloc.dart';
import 'package:simple_paint/bloc/image_bloc.dart';
import 'package:simple_paint/bloc/image_save_event.dart';
import 'package:simple_paint/bloc/image_save_state.dart';
import 'package:simple_paint/bloc/toolbar_bloc.dart';
import 'package:simple_paint/bloc/toolbar_event.dart';
import 'package:simple_paint/bloc/toolbar_state.dart';
import 'package:simple_paint/data/drawn_line.dart';
import 'package:simple_paint/ui/widgets/color_palette.dart';
import 'package:simple_paint/ui/widgets/drawing_area.dart';
import 'package:simple_paint/ui/widgets/scaffold_with_background.dart';
import 'package:simple_paint/ui/widgets/tool_bar.dart';
import 'package:simple_paint/ui/widgets/width_picker.dart';
import 'package:simple_paint/utils/notification_helper.dart';

import '../bloc/canvas_state.dart';
import '../bloc/image_event.dart';
import '../bloc/image_save_bloc.dart';
import '../bloc/image_state.dart';
import '../bloc/line_bloc.dart';

class DrawingPage extends StatefulWidget {
  final String? imageId;

  const DrawingPage({super.key, required this.imageId});

  @override
  State createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  Future<ui.Image> _getImageFromRenderObject(GlobalKey key) async {
    RenderRepaintBoundary boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary;
    return await boundary.toImage();
  }

  @override
  void initState() {
    final imageId = widget.imageId;
    context.read<ImageBloc>().add(
      (imageId != null) ? LoadImageEvent(imageId: imageId) : CreateImageEvent(),
    );
    super.initState();
  }

  Future<void> _onPressedSaveButton(
    String? imageId,
    ui.Image? backgroundImage,
    List<DrawnLine> lines,
    GlobalKey canvasKey,
  ) async {
    final image = await _getImageFromRenderObject(canvasKey);

    if (context.mounted) {
      context.read<ImageSaveBloc>().add(
        ImageSaveEvent(
          imageId: imageId,
          image: image,
          lines: lines,
          background: backgroundImage,
        ),
      );
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithBackground(
      appBar: AppBar(
        backgroundColor: Color(0x1AC4C4C4),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Image.asset('assets/back.png'),
        ),
        title: Text(
          widget.imageId == null ? 'Новое изображение' : 'Редактирование',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          BlocBuilder<CanvasBloc, CanvasState>(
            builder: (context, canvasState) {
              return IconButton(
                onPressed:
                    () => _onPressedSaveButton(
                      widget.imageId,
                      canvasState.backgroundImage,
                      canvasState.lines,
                      canvasState.key,
                    ),
                icon: Image.asset('assets/save.png'),
              );
            },
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(21.0),
        child: BlocBuilder<ToolbarBloc, ToolbarState>(
          builder: (context, toolbarState) {
            return Column(
              children: [
                Toolbar(
                  activePenType: toolbarState.strokePen.type,
                  isPaletteOpen: toolbarState.isPaletteOpen,
                  onPressedExport: () {
                    context.read<ToolbarBloc>().add(ExportImageEvent());
                  },
                  onPressedPen: () {
                    context.read<ToolbarBloc>().add(SelectPencilEvent());
                    context.read<ToolbarBloc>().add(ToggleWidthPickerEvent());
                  },
                  onPressedErase: () {
                    context.read<ToolbarBloc>().add(SelectEraserEvent());
                  },
                  onPressedColorLens: () {
                    context.read<ToolbarBloc>().add(TogglePaletteEvent());
                  },
                ),
                SizedBox(height: 12),
                Expanded(
                  child: Stack(
                    children: [
                      BlocBuilder<ImageBloc, ImageState>(
                        builder: (context, imageState) {
                          if (imageState is ImageError) {
                            return Center(child: Text(imageState.message));
                          }
                          if (imageState is ImageSaved) {
                            return Center(child: Text(imageState.message));
                          }
                          if (imageState is ImageLoaded) {
                            return BlocConsumer<ImageSaveBloc, ImageSaveState>(
                              listener: (context, imageState) {
                                if (imageState is ImageSaveSaved) {
                                  NotificationHelper.showNotification(
                                    'Изображение сохранено успешно',
                                  );
                                  context.pop();
                                }
                              },
                              builder: (context, state) {
                                return Stack(
                                  children: [
                                    BlocProvider(
                                      create: (context) => LineBloc(),
                                      child: DrawingArea(
                                        lines: imageState.lines,
                                        background: imageState.backgroundImage,
                                      ),
                                    ),
                                    if (state is ImageSaveSaving)
                                      ColoredBox(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            );
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      ),
                      if (toolbarState.isPaletteOpen) ColorPalette(),
                      if (toolbarState.isWidthPickerOpen) WidthPicker(),
                    ],
                  ),
                ),
                SizedBox(height: 50),
              ],
            );
          },
        ),
      ),
    );
  }
}
