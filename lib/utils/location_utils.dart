/*
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../config/constants.dart';

class LocationUtils {
  static Future<String> getPhotoDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${appDir.path}/${Constants.photoDirectory}');

    if (!await photoDir.exists()) {
      await photoDir.create(recursive: true);
    }

    return photoDir.path;
  }

  static Future<String> savePhotoToLocalStorage(File photo) async {
    final photoDir = await getPhotoDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(photo.path)}';
    final savedFile = await photo.copy('$photoDir/$fileName');
    return savedFile.path;
  }

  static Future<void> deletePhotoFromStorage(String photoPath) async {
    final file = File(photoPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  static String formatQuantity(int? quantity) {
    return quantity != null ? '$quantity fm' : '-';
  }
}
*/