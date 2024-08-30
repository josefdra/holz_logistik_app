import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location.dart';
import '../utils/network_utils.dart';

class LocationResult {
  final List<Location> locations;
  final int currentPage;
  final int totalPages;
  final int totalCount;

  LocationResult({
    required this.locations,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
  });
}

class LocationService {
  static const String baseUrl = 'https://192.168.2.109:3000';
  static const int pageSize = 20;

  static Future<LocationResult> getLocations({int page = 1}) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('locations_page_$page');

    if (cachedData != null) {
      final Map<String, dynamic> decodedData = json.decode(cachedData);
      final List<Location> locations = (decodedData['locations'] as List)
          .map((item) => Location.fromJson(item))
          .toList();
      return LocationResult(
        locations: locations,
        currentPage: decodedData['currentPage'],
        totalPages: decodedData['totalPages'],
        totalCount: decodedData['totalCount'],
      );
    }

    final response = await NetworkUtils.authenticatedGet(
        '$baseUrl/locations?page=$page&limit=$pageSize');

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Location> locations = (data['locations'] as List)
          .map((item) => Location.fromJson(item))
          .toList();

      // Cache the data
      await prefs.setString('locations_page_$page', json.encode(data));

      return LocationResult(
        locations: locations,
        currentPage: data['currentPage'],
        totalPages: data['totalPages'],
        totalCount: data['totalCount'],
      );
    } else {
      throw Exception('Failed to load locations');
    }
  }

  static Future<Location> addLocation(Location location) async {
    var uri = Uri.parse('$baseUrl/locations');
    var request = http.MultipartRequest('POST', uri);

    _addLocationFieldsToRequest(request, location);

    // Add new photos
    for (var photo in location.newPhotos) {
      var stream = http.ByteStream(photo.openRead());
      var length = await photo.length();
      var multipartFile = http.MultipartFile(
        'photos',
        stream,
        length,
        filename: photo.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    }

    final streamedResponse =
        await NetworkUtils.authenticatedMultipartRequest(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return Location.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add location');
    }
  }

  static Future<Location> updateLocation(Location location) async {
    var uri = Uri.parse('$baseUrl/locations/${location.id}');
    var request = http.MultipartRequest('PUT', uri);

    _addLocationFieldsToRequest(request, location);

    // Add new photos
    for (var photo in location.newPhotos) {
      var stream = http.ByteStream(photo.openRead());
      var length = await photo.length();
      var multipartFile = http.MultipartFile(
        'photos',
        stream,
        length,
        filename: photo.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
    }

    final streamedResponse =
        await NetworkUtils.authenticatedMultipartRequest(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Location.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update location');
    }
  }

  static void _addLocationFieldsToRequest(
      http.MultipartRequest request, Location location) {
    request.fields['name'] = location.name;
    request.fields['latitude'] = location.latitude.toString();
    request.fields['longitude'] = location.longitude.toString();
    request.fields['description'] = location.description;
    request.fields['part_number'] = location.partNumber;
    request.fields['sawmill'] = location.sawmill;
    request.fields['quantity'] = location.quantity.toString();
    request.fields['piece_count'] = location.pieceCount?.toString() ?? '';
  }
}
