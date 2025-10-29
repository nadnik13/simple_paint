import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_paint/bloc/canvas_bloc.dart';
import 'package:simple_paint/ui/widgets/tool_bar_icon_button.dart';

import '../../bloc/canvas_state.dart';
import '../../services/image_service.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasBloc, CanvasState>(
      builder: (context, canvasState) {
        return ToolBarIconButton(
          icon: Image.asset('assets/download.png'),
          onPressed: () => _onShareWithResult(context, canvasState.key),
        );
      },
    );
  }

  void _onShareWithResult(BuildContext context, GlobalKey repaintKey) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final files = <XFile>[];

    RenderRepaintBoundary? boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      return;
    }

    ui.Image image = await boundary.toImage();

    final Uint8List pngBytes = await ImageService.getBytes(image);

    try {
      final dir = await getTemporaryDirectory();
      final filePath = p.join(
        dir.path,
        'share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      final outFile = File(filePath);
      await outFile.writeAsBytes(pngBytes);

      files.add(XFile(filePath, mimeType: 'image/png'));
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Не удалось сохранить изображение')),
      );
    }
    await SharePlus.instance.share(
      ShareParams(
        files: files,
        sharePositionOrigin:
            boundary.localToGlobal(Offset.zero) & boundary.size,
      ),
    );
  }
}
