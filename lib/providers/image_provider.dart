import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageProviderModel extends ChangeNotifier {
  File? _originalImage;
  File? _grayscaleImage;
  bool _isLoading = false;

  File? get originalImage => _originalImage;
  File? get grayscaleImage => _grayscaleImage;
  bool get isLoading => _isLoading;

  Future<void> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        _isLoading = true;
        notifyListeners();

        _originalImage = File(pickedFile.path);
        await _convertToGrayscale();

        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _convertToGrayscale() async {
    try {
      // Read the image file
      final bytes = await _originalImage!.readAsBytes();
      final originalImage = img.decodeImage(bytes);

      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      final grayscaleImage = await compute(_grayscaleConversion, originalImage);

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/grayscale_image.jpg';
      final grayscaleBytes = img.encodeJpg(grayscaleImage);
      await File(tempPath).writeAsBytes(grayscaleBytes);

      _grayscaleImage = File(tempPath);
    } catch (e) {
      debugPrint('Error converting to grayscale: $e');
      throw Exception('Failed to convert image to grayscale');
    }
  }

  static img.Image _grayscaleConversion(img.Image original) {
    return img.grayscale(original);
  }

  void reset() {
    _originalImage = null;
    _grayscaleImage = null;
    notifyListeners();
  }
}