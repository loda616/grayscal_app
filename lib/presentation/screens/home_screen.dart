import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:grayscal_app/providers/image_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:grayscal_app/core/utils/storage_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) {
    final imageProvider = Provider.of<ImageProviderModel>(context, listen: false);
    imageProvider.pickImage(source);
  }

  void _shareImage() {
    final imageProvider = Provider.of<ImageProviderModel>(context, listen: false);
    if (imageProvider.grayscaleImage != null) {
      Share.shareXFiles(
        [XFile(imageProvider.grayscaleImage!.path)],
        text: 'Check out this grayscale image!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grayscale App'),
        actions: [
          Consumer<ImageProviderModel>(
            builder: (context, imageProvider, child) {
              if (imageProvider.grayscaleImage != null) {
                return IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: _shareImage,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<ImageProviderModel>(
        builder: (context, imageProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: _showImageSourceDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: const Text(
                    'PICK IMAGE',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                if (imageProvider.isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (imageProvider.originalImage != null && imageProvider.grayscaleImage != null)
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
                              imageProvider.originalImage!,
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
                              imageProvider.grayscaleImage!,
                              width: double.infinity,
                              fit: BoxFit.cover,
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
                                  await imageProvider.grayscaleImage!.copy(savedPath);
                                  if (mounted) {
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
                  )
                else
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Pick an image to convert to grayscale',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}