import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageUtils {
  static Future<Directory> getExternalStorageDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
  
  static String generateImagePath(Directory directory, String prefix) {
    return '${directory.path}/${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }
}