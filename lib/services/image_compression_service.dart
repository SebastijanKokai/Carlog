import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressionService {
  static ImageCompressionService? _instance;

  ImageCompressionService._();

  static ImageCompressionService getInstance() {
    _instance ??= ImageCompressionService._();
    return _instance!;
  }

  Future<List<int>> compressImageFile(File imageFile) async {
    try {
      int quality = 90;

      var result = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        quality: quality,
      );

      if (result == null) {
        throw Exception('Could not compress image');
      }

      while (result!.length > 4 * 1024 * 1024 && quality > 10) {
        quality -= 10;
        result = await FlutterImageCompress.compressWithFile(
          imageFile.absolute.path,
          quality: quality,
        );

        if (result == null) {
          throw Exception('Could not compress image');
        }
      }

      return result;
    } catch (e) {
      throw Exception('Could not compress image: $e');
    }
  }
}
