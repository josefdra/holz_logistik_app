import 'package:holz_logistik/models/location.dart';
import 'package:holz_logistik/services/api_service.dart';

class LocationService {
  final ApiService _apiService;

  LocationService(this._apiService);

  Future<List<Location>> getLocations() async {
    try {
      final response = await _apiService.get('/locations');
      final locations = (response['locations'] as List)
          .map((json) => Location.fromJson(json))
          .toList();

      // Update local database with fetched locations

      return locations;
    } catch (e) {
      // If API call fails, return offline data
      throw Exception('Failed to return locations: $e');
    }
  }

  Future<Location> addLocation(Location location) async {
    try {
      // Upload new photos

      // Prepare location data
      var locationData = location.toJson();
      locationData['photo_urls'] = [
        ...location.photoUrls,
      ];

      // Send to API
      final response = await _apiService.post('/locations', locationData);
      final newLocation = Location.fromJson(response);

      // Save locally

      // Save uploaded photos locally

      return newLocation;
    } catch (e) {
      print('Error adding location: $e');
      // If API call fails, save offline
      throw Exception('Failed to add location: $e');
    }
  }

  Future<Location> updateLocation(Location location) async {
    try {
      // Upload new photos

      // Prepare location data
      var locationData = location.toJson();
      locationData['photo_urls'] = [
        ...location.photoUrls,
      ];

      // Send to API
      final response =
          await _apiService.put('/locations/${location.id}', locationData);
      final newLocation = Location.fromJson(response);

      // Save locally

      // Save uploaded photos locally

      return newLocation;
    } catch (e) {
      print('Error updating location: $e');
      // If API call fails, save offline
      throw Exception('Failed to update location: $e');
    }
  }

  Future<void> deleteLocation(int id) async {
    try {
      await _apiService.delete('/locations/$id');
    } catch (e) {
      // If API call fails, mark for deletion offline
    }
  }
}
