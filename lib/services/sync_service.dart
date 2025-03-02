import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location.dart';
import '../models/shipment.dart';
import '../database/database_helper.dart';
import '../utils/network_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class SyncService {
  static const String _lastSyncKey = 'last_sync_timestamp';
  final DatabaseHelper _db = DatabaseHelper.instance;
  late String _baseUrl;
  late String _apiKey;
  late String _driverName;
  final _uuid = const Uuid();

  // Initialize with API key or auth token
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get the server URL
      _baseUrl = prefs.getString('server_url') ?? '';
      print("SyncService initialize - Raw URL from prefs: '$_baseUrl'");

      // Ensure URL is properly formatted without trailing slash
      if (_baseUrl.endsWith('/')) {
        _baseUrl = _baseUrl.substring(0, _baseUrl.length - 1);
      }

      // Validate URL format
      if (_baseUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(_baseUrl);
          if (!uri.isAbsolute) {
            print("SyncService initialize - URL is not absolute: '$_baseUrl'");
            _baseUrl = ''; // Reset invalid URL
          } else {
            print("SyncService initialize - Valid URL: ${uri.toString()}");
          }
        } catch (e) {
          print("SyncService initialize - Invalid URL format: '$_baseUrl', Error: $e");
          _baseUrl = ''; // Reset invalid URL
        }
      }

      _apiKey = prefs.getString('api_key') ?? '';
      _driverName = prefs.getString('driver_name') ?? '';

      print("SyncService initialized with URL: '$_baseUrl', API key: ${_apiKey.isNotEmpty ? 'present' : 'empty'}");
    } catch (e) {
      print('Error initializing SyncService: $e');
    }
  }

  // Get API key from preferences
  Future<String> _getApiKey() async {
    if (_apiKey.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString('api_key') ?? '';
    }
    return _apiKey;
  }

  // Synchronize all data with the server
  Future<bool> syncAll() async {
    try {
      print("SYNC DEBUG - baseUrl: '$_baseUrl', apiKey exists: ${_apiKey.isNotEmpty}");

      if (_baseUrl.isEmpty) {
        print("SYNC ABORT - No server URL configured");
        return false;
      }

      if (!await NetworkUtils.isConnected()) {
        return false;
      }

      if (_baseUrl.isEmpty || _apiKey.isEmpty) {
        print("Cannot sync: Server URL or API key not configured");
        return false;
      }

      final lastSync = await _getLastSyncTimestamp();

      // First push local changes to server
      await _pushLocationsToServer(lastSync);
      await _pushShipmentsToServer(lastSync);

      // Then pull changes from server
      await _pullLocationsFromServer(lastSync);
      await _pullShipmentsFromServer(lastSync);

      // Update last sync timestamp
      await _updateLastSyncTimestamp();

      return true;
    } catch (e) {
      print('Sync error: $e');
      return false;
    }
  }

  // Push locally updated locations to the server
  Future<void> _pushLocationsToServer(DateTime lastSync) async {
    final locations = await _db.getLocationsUpdatedSince(lastSync);
    print('Found ${locations.length} locations to push to server');

    for (var location in locations) {
      try {
        // Skip already synced locations
        if (location.isSynced && location.serverId != null) {
          print('Skipping already synced location ${location.id} (${location.name})');
          continue;
        }

        print('Pushing location ${location.id} (${location.name}) to server');

        // Get the full location data including server ID
        final fullLocation = await _db.getLocation(location.id!);
        if (fullLocation == null) {
          print('Could not find full location data for ID ${location.id}');
          continue;
        }

        final locationJson = _locationToJson(fullLocation);
        print('Location data: ${jsonEncode(locationJson)}');

        await _uploadPhotosForLocation(fullLocation);

        final response = await http.post(
          Uri.parse('$_baseUrl/locations_api.php'),
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': await _getApiKey(),
          },
          body: jsonEncode(locationJson),
        );

        print('Server response for location ${location.id}: ${response.statusCode} - ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          // Update local record with server ID and mark as synced
          if (responseData['server_id'] != null) {
            print('Updating location ${location.id} with server ID ${responseData['server_id']}');
            await _db.updateLocation(fullLocation.copyWith(
                serverId: responseData['server_id'],
                isSynced: true
            ));
          }
        } else {
          print('Error from server: ${response.body}');
        }
      } catch (e) {
        print('Error pushing location ${location.id}: $e');
      }
    }
  }

  // Push locally updated shipments to the server
  Future<void> _pushShipmentsToServer(DateTime lastSync) async {
    if (_baseUrl.isEmpty) {
      print("Cannot push locations - server URL not configured");
      return;
    }

    final shipments = await _db.getShipmentsUpdatedSince(lastSync);

    for (var shipment in shipments) {
      try {
        final response = await http.post(
          Uri.parse('$_baseUrl/shipments_api.php'),
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': await _getApiKey(),
            'X-Driver-Name': shipment.driverName,
          },
          body: jsonEncode(_shipmentToJson(shipment)),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          // Update local record with server ID if needed
          if (responseData['server_id'] != null) {
            await _db.updateShipmentServerId(
                shipment.id!,
                responseData['server_id']
            );
          }
        }
      } catch (e) {
        print('Error pushing shipment ${shipment.id}: $e');
      }
    }
  }

  // Pull locations from server that were updated since last sync
  Future<void> _pullLocationsFromServer(DateTime lastSync) async {
    try {
      if (_baseUrl.isEmpty) {
        print("Cannot push locations - server URL not configured");
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/locations_api.php?updated_since=${lastSync.toIso8601String()}'),
        headers: {'X-API-Key': await _getApiKey()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> locationsData = jsonDecode(response.body);

        for (var locationData in locationsData) {
          final location = _locationFromJson(locationData);

          // Check if photo URLs need to be downloaded
          final photoUrls = await _downloadPhotos(locationData['photo_urls'] ?? []);

          // Update or insert location in local DB
          final existingLocation = await _db.getLocationByServerId(locationData['server_id']);

          if (existingLocation != null) {
            await _db.updateLocation(location.copyWith(
              id: existingLocation.id,
              photoUrls: photoUrls,
            ));
          } else {
            await _db.insertLocation(location.copyWith(
              photoUrls: photoUrls,
            ));
          }
        }
      }
    } catch (e) {
      print('Error pulling locations: $e');
    }
  }

  // Pull shipments from server that were updated since last sync
  Future<void> _pullShipmentsFromServer(DateTime lastSync) async {
    try {
      if (_baseUrl.isEmpty) {
        print("Cannot push locations - server URL not configured");
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/shipments_api.php?updated_since=${lastSync.toIso8601String()}'),
        headers: {'X-API-Key': await _getApiKey()},
      );

      if (response.statusCode == 200) {
        final List<dynamic> shipmentsData = jsonDecode(response.body);

        for (var shipmentData in shipmentsData) {
          final shipment = await _shipmentFromJson(shipmentData);

          // Update or insert shipment in local DB
          final existingShipment = await _db.getShipmentByServerId(shipmentData['server_id']);

          if (existingShipment != null) {
            await _db.updateShipment(shipment.copyWith(
              id: existingShipment.id,
            ));
          } else {
            await _db.insertShipment(shipment);
          }
        }
      }
    } catch (e) {
      print('Error pulling shipments: $e');
    }
  }

  // Download photos from server URLs and save them locally
  Future<List<String>> _downloadPhotos(List<dynamic> photoUrls) async {
    final List<String> localPhotoUrls = [];

    for (var url in photoUrls) {
      try {
        // Check if this is already a local file path (starts with / or contains ://)
        if (url.toString().startsWith('/') ||
            url.toString().contains('://') && !url.toString().startsWith('http')) {
          print('Photo $url appears to be a local path already, skipping download');
          localPhotoUrls.add(url.toString());
          continue;
        }

        // Only download if it's a web URL
        if (url.toString().startsWith('http')) {
          // Download the photo
          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
            // Save the photo locally
            final appDir = await getApplicationDocumentsDirectory();
            final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(url.toString())}';
            final photoDir = Directory('${appDir.path}/photos');

            if (!await photoDir.exists()) {
              await photoDir.create(recursive: true);
            }

            final file = File('${photoDir.path}/$fileName');
            await file.writeAsBytes(response.bodyBytes);

            localPhotoUrls.add(file.path);
          }
        }
      } catch (e) {
        print('Error downloading photo $url: $e');
      }
    }

    return localPhotoUrls;
  }

  // Get the timestamp of the last successful sync
  Future<DateTime> _getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);

    if (lastSyncStr != null) {
      return DateTime.parse(lastSyncStr);
    }

    // If no previous sync, use a very old date
    return DateTime(2000);
  }

  // Update the last sync timestamp to now
  Future<void> _updateLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  // Upload a photo to the server and get back the URL
  Future<String?> uploadPhoto(File photo) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload_api.php'));

      // Set API key
      request.headers['X-API-Key'] = await _getApiKey();
      request.headers['X-Driver-Name'] = _driverName;

      // Add the photo file
      request.files.add(
        await http.MultipartFile.fromPath('photo', photo.path),
      );

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        // If upload successful, parse response to get URL
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        return data['url'];
      }
    } catch (e) {
      print('Error uploading photo: $e');
    }
    return null;
  }

  // Convert Location object to JSON for server
  Map<String, dynamic> _locationToJson(Location location) {
    return {
      'server_id': location.serverId,
      'name': location.name,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'additional_info': location.additionalInfo,
      'access': location.access,
      'part_number': location.partNumber,
      'sawmill': location.sawmill,
      'oversize_quantity': location.oversizeQuantity,
      'quantity': location.quantity,
      'piece_count': location.pieceCount,
      'photo_urls': location.photoUrls,
      'created_at': location.createdAt?.toIso8601String(),
      'updated_at': location.updatedAt?.toIso8601String(),
      'is_deleted': location.isDeleted ? 1 : 0,
    };
  }

  // Convert JSON from server to Location object
  Location _locationFromJson(Map<String, dynamic> json) {
    return Location(
      serverId: json['server_id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      additionalInfo: json['additional_info'] ?? '',
      access: json['access'] ?? '',
      partNumber: json['part_number'] ?? '',
      sawmill: json['sawmill'] ?? '',
      oversizeQuantity: json['oversize_quantity'],
      quantity: json['quantity'],
      pieceCount: json['piece_count'],
      photoUrls: [],  // Will be populated after download
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isSynced: true,
      isDeleted: json['is_deleted'] == 1,
    );
  }

  // Convert Shipment object to JSON for server
  Map<String, dynamic> _shipmentToJson(Shipment shipment) {
    return {
      'server_id': shipment.serverId,
      'location_server_id': shipment.locationServerId,
      'oversize_quantity': shipment.oversizeQuantity,
      'quantity': shipment.quantity,
      'piece_count': shipment.pieceCount,
      'timestamp': shipment.timestamp.toIso8601String(),
      'is_undone': shipment.isUndone ? 1 : 0,
      'is_deleted': shipment.isDeleted ? 1 : 0,
      'driver_name': shipment.driverName,  // Include driver name in JSON
    };
  }

  // Convert JSON from server to Shipment object
  Future<Shipment> _shipmentFromJson(Map<String, dynamic> json) async {
    // Find the local location ID based on server ID
    int locationId = 0;
    if (json['location_server_id'] != null) {
      final location = await _db.getLocationByServerId(json['location_server_id']);
      if (location != null) {
        locationId = location.id!;
        print('Resolved server ID ${json['location_server_id']} to local ID $locationId');
      } else {
        print('Could not resolve server ID ${json['location_server_id']} to a local location');
      }
    }

    return Shipment(
      serverId: json['server_id'],
      locationId: locationId,
      locationServerId: json['location_server_id'],
      oversizeQuantity: json['oversize_quantity'],
      quantity: json['quantity'],
      pieceCount: json['piece_count'],
      timestamp: DateTime.parse(json['timestamp']),
      isUndone: json['is_undone'] == 1,
      isSynced: true,
      isDeleted: json['is_deleted'] == 1,
      driverName: json['driver_name'] ?? '',
    );
  }

  // Helper method to generate UUID if needed
  String generateUuid() {
    return _uuid.v4();
  }

  Future<void> _uploadPhotosForLocation(Location location) async {
    if (location.photoUrls.isEmpty) return;

    List<String> uploadedUrls = [];
    List<String> localPaths = [];

    for (var photoUrl in location.photoUrls) {
      try {
        // Check if this is a local file that hasn't been uploaded yet
        if (photoUrl.startsWith('/')) {
          final file = File(photoUrl);
          if (await file.exists()) {
            print('Uploading photo: $photoUrl');
            final uploadedUrl = await uploadPhoto(file);
            if (uploadedUrl != null) {
              uploadedUrls.add(uploadedUrl);
              localPaths.add(photoUrl); // Keep track of local path for removal later
            }
          }
        } else if (photoUrl.startsWith('http')) {
          // Already a web URL, keep it
          uploadedUrls.add(photoUrl);
        }
      } catch (e) {
        print('Error processing photo $photoUrl: $e');
      }
    }

    // If we uploaded any photos, update the location
    if (uploadedUrls.isNotEmpty) {
      // Replace local paths with server URLs
      List<String> updatedPhotoUrls = List.from(location.photoUrls);
      for (int i = 0; i < localPaths.length; i++) {
        final index = updatedPhotoUrls.indexOf(localPaths[i]);
        if (index >= 0) {
          updatedPhotoUrls[index] = uploadedUrls[i];
        }
      }

      // Update the location with new photo URLs
      await _db.updateLocation(location.copyWith(
        photoUrls: updatedPhotoUrls,
      ));
    }
  }
}