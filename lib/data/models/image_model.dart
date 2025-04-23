import 'dart:io';

class ImageModel {
  final File originalImage;
  final File grayscaleImage;
  final DateTime createdAt;
  final String? savedPath;

  ImageModel({
    required this.originalImage,
    required this.grayscaleImage,
    DateTime? createdAt,
    this.savedPath,
  }) : createdAt = createdAt ?? DateTime.now();

  ImageModel copyWith({
    File? originalImage,
    File? grayscaleImage,
    DateTime? createdAt,
    String? savedPath,
  }) {
    return ImageModel(
      originalImage: originalImage ?? this.originalImage,
      grayscaleImage: grayscaleImage ?? this.grayscaleImage,
      createdAt: createdAt ?? this.createdAt,
      savedPath: savedPath ?? this.savedPath,
    );
  }
}