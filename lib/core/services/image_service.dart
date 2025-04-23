import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageService {
  static Future<File> convertToGrayscale(File originalImage) async {
    try {

      final bytes = await originalImage.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw Exception('Failed to decode image');
      }


      final grayscaleImage = await compute(_grayscaleConversion, decodedImage);

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/grayscale_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final grayscaleBytes = img.encodeJpg(grayscaleImage);
      final file = File(tempPath);
      await file.writeAsBytes(grayscaleBytes);

      return file;
    } catch (e) {
      debugPrint('Error converting to grayscale: $e');
      throw Exception('Failed to convert image to grayscale');
    }
  }


  static img.Image _grayscaleConversion(img.Image original) {
    return img.grayscale(original);
  }

  static Future<String> saveImage(File image, String path) async {
    try {
      await image.copy(path);
      return path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      throw Exception('Failed to save image');
    }
  }

  static Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      for (var file in files) {
        if (file is File && file.path.contains('grayscale_image_')) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temp files: $e');
    }
  }
}