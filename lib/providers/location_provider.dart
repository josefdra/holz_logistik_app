import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../database/database_helper.dart';
import '../models/location.dart';

class LocationProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Location> _locations = [];
  bool _isLoading = false;

  List<Location> get locations => _locations;
  bool get isLoading => _isLoading;

  Future<void> loadLocations() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _locations = await _db.getAllLocations();
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Location?> addLocation(Location location) async {
    try {
      // First, save any new photos to local storage
      final List<String> savedPhotoUrls = await _savePhotosToLocalStorage(location.newPhotos);

      // Create a new location with all photo URLs
      final locationToSave = location.copyWith(
        photoUrls: [...location.photoUrls, ...savedPhotoUrls],
      );

      // Insert into database
      final id = await _db.insertLocation(locationToSave);
      final savedLocation = await _db.getLocation(id);

      if (savedLocation != null) {
        _locations.add(savedLocation);
        notifyListeners();
      }

      return savedLocation;
    } catch (e) {
      debugPrint('Error adding location: $e');
      return null;
    }
  }

  Future<bool> updateLocation(Location location) async {
    try {
      // Save any new photos
      final List<String> savedPhotoUrls = await _savePhotosToLocalStorage(location.newPhotos);

      // Update location with new photo URLs
      final locationToUpdate = location.copyWith(
        photoUrls: [...location.photoUrls, ...savedPhotoUrls],
      );

      // Update in database
      final result = await _db.updateLocation(locationToUpdate);

      if (result > 0) {
        final index = _locations.indexWhere((loc) => loc.id == location.id);
        if (index >= 0) {
          _locations[index] = locationToUpdate;
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating location: $e');
      return false;
    }
  }

  Future<bool> deleteLocation(int id) async {
    try {
      final result = await _db.deleteLocation(id);
      if (result > 0) {
        _locations.removeWhere((location) => location.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting location: $e');
      return false;
    }
  }

  Future<List<String>> _savePhotosToLocalStorage(List<File> photos) async {
    final List<String> savedPaths = [];

    if (photos.isEmpty) return savedPaths;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/photos');

      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      for (final photo in photos) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(photo.path)}';
        final savedFile = await photo.copy('${photosDir.path}/$fileName');
        savedPaths.add(savedFile.path);
      }
    } catch (e) {
      debugPrint('Error saving photos: $e');
    }

    return savedPaths;
  }

  Future<void> deletePhotoFromLocation(Location location, String photoUrl) async {
    try {
      // Remove from storage if it's a local file
      if (photoUrl.startsWith('/')) {
        final file = File(photoUrl);
        if (await file.exists()) {
          await file.delete();
        }
      }

      // Update location with removed photo
      final updatedPhotoUrls = List<String>.from(location.photoUrls)..remove(photoUrl);
      final updatedLocation = location.copyWith(photoUrls: updatedPhotoUrls);

      await updateLocation(updatedLocation);
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }
}