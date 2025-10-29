import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageService {
  static Uint8List compressAndResize(
    Uint8List bytes, {
    int width = 300,
    int quality = 80,
  }) {
    final decoded = img.decodeImage(bytes)!;
    final resized = img.copyResize(decoded, width: width);

    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  static Future<Uint8List> getBytes(ui.Image? image) async {
    if (image != null) {
      final ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png) as ByteData;
      return byteData.buffer.asUint8List();
    } else {
      return Uint8List(0);
    }
  }

  static Future<ui.Image> xFileToUiImage(XFile xfile) async {
    final Uint8List bytes = await xfile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}
