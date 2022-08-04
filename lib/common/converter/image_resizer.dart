import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

class ImageResizer {
  Future<Uint8List?> resize(
    Uint8List data, {
    int? width,
    int? height,
    img.Interpolation interpolation = img.Interpolation.linear,
  }) async {
    return await compute(_resize, [data, width, height, interpolation]);
  }

  static Uint8List? _resize(dynamic args) {
    Uint8List data = args[0];
    int? width = args[1];
    int? height = args[2];
    img.Interpolation interpolation = args[3];
    final di = img.decodeImage(data);
    if (di == null) {
      return null;
    }

    final image = img.copyResize(
      di,
      width: width,
      height: height,
      interpolation: interpolation,
    );
    return Uint8List.fromList(img.encodeJpg(image, quality: 85));
  }
}
