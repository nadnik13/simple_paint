import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_paint/bloc/canvas_event.dart';
import 'package:simple_paint/services/image_service.dart';

import '../../bloc/canvas_bloc.dart';
import 'tool_bar_icon_button.dart';

class ImagePickerButton extends StatelessWidget {
  ImagePickerButton({super.key});

  final ImagePicker _picker = ImagePicker();
  Future<void> _onImageButtonPressed({required BuildContext context}) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (context.mounted) {
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.gallery,
          maxHeight: 1000,
          maxWidth: 1000,
          imageQuality: 80,
        );
        if (pickedFile != null) {
          final background = await ImageService.xFileToUiImage(pickedFile);
          context.read<CanvasBloc>().add(
            AddBackgroundEvent(background: background),
          );
        }
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Не удалось загрузить изображение')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ToolBarIconButton(
      icon: Image.asset('assets/image.png'),
      onPressed: () {
        _onImageButtonPressed(context: context);
      },
    );
  }
}
