import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_paint/bloc/gallery_bloc.dart';
import 'package:simple_paint/bloc/image_bloc.dart';
import 'package:simple_paint/bloc/toolbar_bloc.dart';
import 'package:simple_paint/bloc/toolbar_event.dart';
import 'package:simple_paint/bloc/toolbar_state.dart';
import 'package:simple_paint/data/drawn_line.dart';
import 'package:simple_paint/ui/widgets/color_palette.dart';
import 'package:simple_paint/ui/widgets/drawing_area.dart';
import 'package:simple_paint/ui/widgets/scaffold_with_background.dart';
import 'package:simple_paint/ui/widgets/tool_bar.dart';

import '../bloc/gallery_event.dart';
import '../bloc/image_event.dart';
import '../bloc/image_state.dart';

class DrawingPageWrapper extends StatelessWidget {
  final String? imageId;

  const DrawingPageWrapper({super.key, required this.imageId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ToolbarBloc>(
      create: (context) => ToolbarBloc(),
      child: DrawingPage(imageId: imageId),
    );
  }
}

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

  Future<void> _onPressSaveButton(
    String? imageId,
    ui.Image background,
    List<DrawnLine> lines,
  ) async {
    print('save image');

    final image = await _getImageFromRenderObject();

    print('lines: ${lines.length}');
    if (context.mounted) {
      context.read<ImageBloc>().add(
        SaveImageEvent(
          imageId: imageId,
          image: image,
          lines: lines,
          background: background,
        ),
      );
      print("saved: ${context.read<ImageBloc>().state}");
      print("saved");
      context.read<GalleryBloc>().add(RefreshGalleryEvent());
      context.go('/gallery');
    }
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
      context.read<GalleryBloc>().add(RefreshGalleryEvent());
      context.go('/gallery');
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    print('imageState: ${context.read<ImageBloc>().state}');
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
          BlocBuilder<ImageBloc, ImageState>(
            builder: (context, imageState) {
              return IconButton(
                onPressed:
                    () =>
                        (imageState is ImageLoaded)
                            ? _onPressedSaveButton(
                              imageState.imageId,
                              imageState.backgroundImage,
                              imageState.lines,
                            )
                            : null,
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
                  onPressedImage: () {
                    context.read<ToolbarBloc>().add(InsertImageEvent());
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
                      DrawingArea(canvasKey: _repainBoundaryGlobalKey),
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
