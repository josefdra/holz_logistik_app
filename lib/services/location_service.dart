import 'dart:io';

import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/services/api_service.dart';
import 'package:holz_logistik/services/image_service.dart';
import 'package:holz_logistik/utils/offline_sync_manager.dart';

class LocationService {
  final ApiService _apiService;
  final ImageService _imageService;
  final OfflineSyncManager _offlineSyncManager;

  LocationService(
      this._apiService, this._imageService, this._offlineSyncManager);

  Future<List<Location>> getLocations() async {
    try {
      final response = await _apiService.get('/locations');
      final locations = (response['locations'] as List)
          .map((json) => Location.fromJson(json))
          .toList();

      // // Update local database with fetched locations
      // for (var location in locations) {
      //   await _offlineSyncManager.saveLocation(location);
      // }

      return locations;
    } catch (e) {
      // If API call fails, return offline data
      return _offlineSyncManager.getOfflineLocations();
    }
  }

  Future<Location> addLocation(Location location) async {
    try {
      // Upload new photos
      List<String> uploadedPhotoUrls =
          await _imageService.uploadImages(location.newPhotos);

      // Prepare location data
      var locationData = location.toJson();
      locationData['photo_urls'] = [
        ...location.photoUrls,
        ...uploadedPhotoUrls
      ];

      // Send to API
      final response = await _apiService.post('/locations', locationData);
      final newLocation = Location.fromJson(response);

      // // Save locally
      // await _offlineSyncManager.saveLocation(newLocation);

      // // Save uploaded photos locally
      // for (var photo in location.newPhotos) {
      //   await _imageService.saveImageLocally(photo);
      // }

      return newLocation;
    } catch (e) {
      print('Error adding location: $e');
      // If API call fails, save offline
      // await _offlineSyncManager.saveLocation(location);
      throw Exception('Failed to add location: $e');
    }
  }

  Future<Location> updateLocation(Location location) async {
    try {
      // Upload new photos
      List<String> uploadedPhotoUrls =
          await _imageService.uploadImages(location.newPhotos);

      // Prepare location data
      var locationData = location.toJson();
      locationData['photo_urls'] = [
        ...location.photoUrls,
        ...uploadedPhotoUrls
      ];

      // Send to API
      final response =
          await _apiService.put('/locations/${location.id}', locationData);
      final updatedLocation = Location.fromJson(response);

      // // Update locally
      // await _offlineSyncManager.updateLocation(updatedLocation);

      // // Save uploaded photos locally
      // for (var photo in location.newPhotos) {
      //   await _imageService.saveImageLocally(photo);
      // }

      return updatedLocation;
    } catch (e) {
      // If API call fails, update offline
      // await _offlineSyncManager.updateLocation(location);
      return location;
    }
  }

  Future<void> deleteLocation(int id) async {
    try {
      await _apiService.delete('/locations/$id');
      // await _offlineSyncManager.deleteLocation(id);
    } catch (e) {
      // If API call fails, mark for deletion offline
      // await _offlineSyncManager.markForDeletion(id);
    }
  }

  Future<File> getPhotoFile(String photoUrl) async {
    try {
      return await _imageService.downloadImage(photoUrl);
    } catch (e) {
      // If download fails, try to get the local file
      return File(photoUrl);
    }
  }
}
