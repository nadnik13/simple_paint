import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/canvas_bloc.dart';
import 'package:simple_paint/bloc/image_bloc.dart';
import 'package:simple_paint/bloc/toolbar_bloc.dart';
import 'package:simple_paint/bloc/toolbar_event.dart';
import 'package:simple_paint/bloc/toolbar_state.dart';
import 'package:simple_paint/data/drawn_line.dart';
import 'package:simple_paint/ui/widgets/color_palette.dart';
import 'package:simple_paint/ui/widgets/drawing_area.dart';
import 'package:simple_paint/ui/widgets/scaffold_with_background.dart';
import 'package:simple_paint/ui/widgets/tool_bar.dart';

import '../bloc/canvas_state.dart';
import '../bloc/image_event.dart';
import '../bloc/image_state.dart';

class DrawingPage extends StatefulWidget {
  final String? imageId;

  const DrawingPage({super.key, required this.imageId});

  @override
  State createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _repainBoundaryGlobalKey = GlobalKey();

  Future<ui.Image> _getImageFromRenderObject() async {
    RenderRepaintBoundary boundary =
        _repainBoundaryGlobalKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary;
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

  // Future<void> export(ImageState imageState) async {
  //   print('save image');
  //   try {
  //     // Используем объединенный boundary для захвата всех элементов
  //     RenderRepaintBoundary boundary =
  //         _repainBoundaryGlobalKey.currentContext?.findRenderObject()
  //             as RenderRepaintBoundary;
  //
  //     final imageId = widget.imageId;
  //     ui.Image image = await boundary.toImage();
  //
  //     final imageId = widget.imageId;
  //
  //     if (imageId != null) {
  //       context.read<ImageBloc>().add(
  //         SaveOriginalImageEvent(imageId: imageId, image: image, lines: []),
  //       );
  //     } else {
  //       context.read<ImageBloc>().add(CreateNewImageEvent(image: image));
  //     }
  //     print("saved: ${context.read<ImageBloc>().state}");
  //     print("saved");
  //     context.read<GalleryBloc>().add(RefreshImagesEvent());
  //     context.go('/gallery');
  //   } catch (e) {
  //     print('Error: ${e}');
  //   }
  // }
  Future<void> _onPressedSaveButton(
    String? imageId,
    ui.Image? backgroundImage,
    List<DrawnLine> lines,
  ) async {
    final image = await _getImageFromRenderObject();

    if (context.mounted) {
      context.read<ImageBloc>().add(
        SaveImageEvent(
          imageId: imageId,
          image: image,
          lines: lines,
          background: backgroundImage,
        ),
      );
      print("saved: ${context.read<ImageBloc>().state}");
      print("saved");
      context.go('/gallery');
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    print('imageState: ${context.watch<ImageBloc>().state}');
    return ScaffoldWithBackground(
      appBar: AppBar(
        backgroundColor: Color(0x1AC4C4C4),
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            context.go('/gallery');
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
                            print('imageState: ${imageState.lines.isNotEmpty}');
                            return DrawingArea(
                              canvasKey: _repainBoundaryGlobalKey,
                              lines: imageState.lines,
                              background: imageState.backgroundImage,
                            );
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      ),
                      if (toolbarState.isPaletteOpen) ColorPalette(),
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
