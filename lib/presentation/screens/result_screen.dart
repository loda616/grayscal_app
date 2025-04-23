import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:grayscal_app/core/utils/storage_utils.dart';

class ResultScreen extends StatelessWidget {
  final File originalImage;
  final File grayscaleImage;

  const ResultScreen({
    super.key,
    required this.originalImage,
    required this.grayscaleImage,
  });

  void _shareImage() {
    Share.shareXFiles(
      [XFile(grayscaleImage.path)],
      text: 'Check out this grayscale image!',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grayscale Result'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareImage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Original:',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        originalImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Greyscale:',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        grayscaleImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final directory = await StorageUtils.getExternalStorageDirectory();
                    final savedPath = StorageUtils.generateImagePath(directory, 'grayscale');
                    await grayscaleImage.copy(savedPath);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Image saved successfully')),
                      );
                    }
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
                ElevatedButton.icon(
                  onPressed: _shareImage,
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}