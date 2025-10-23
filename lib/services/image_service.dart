import 'dart:typed_data';

import 'package:image/image.dart' as img;

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
}
