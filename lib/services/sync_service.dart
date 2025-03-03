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

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _baseUrl = prefs.getString('server_url') ?? '';
      print("SyncService initialize - Raw URL from prefs: '$_baseUrl'");

      // More robust URL validation
      if (_baseUrl.isNotEmpty) {
        final uri = Uri.parse(_baseUrl);
        if (!uri.isAbsolute) {
          print("Invalid URL: $_baseUrl");
          _baseUrl = ''; // Reset to empty if invalid
        }
      }

      _apiKey = prefs.getString('api_key') ?? '';
      _driverName = prefs.getString('driver_name') ?? '';

      print("SyncService initialized successfully");
    } catch (e) {
      print('Comprehensive error initializing SyncService: $e');
      // Ensure fallback to empty strings
      _baseUrl = '';
      _apiKey = '';
      _driverName = '';
    }
  }

  Future<String> _getApiKey() async {
    if (_apiKey.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      _apiKey = prefs.getString('api_key') ?? '';
    }
    return _apiKey;
  }

  Future<bool> syncAll() async {
    try {
      if (_baseUrl.isEmpty || !await NetworkUtils.isConnected() || _apiKey.isEmpty) {
        return false;
      }

      final lastSync = await _getLastSyncTimestamp();

      await _pushLocationsToServer(lastSync);
      await _pushShipmentsToServer(lastSync);
      await _pullLocationsFromServer(lastSync);
      await _pullShipmentsFromServer(lastSync);
      await _updateLastSyncTimestamp();

      return true;
    } catch (e) {
      print('Sync error: $e');
      return false;
    }
  }

  Future<void> _pushLocationsToServer(DateTime lastSync) async {
    final locations = await _db.getLocationsUpdatedSince(lastSync);

    for (var location in locations) {
      try {
        if (location.isSynced && location.serverId != null) {
          continue;
        }

        final fullLocation = await _db.getLocation(location.id!);
        if (fullLocation == null) {
          continue;
        }

        final locationJson = _locationToJson(fullLocation);
        await _uploadPhotosForLocation(fullLocation);

        final response = await http.post(
          Uri.parse('$_baseUrl/locations_api.php'),
          headers: {
            'Content-Type': 'application/json',
            'X-API-Key': await _getApiKey(),
          },
          body: jsonEncode(locationJson),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          if (responseData['server_id'] != null) {
            await _db.updateLocation(fullLocation.copyWith(
                serverId: responseData['server_id'],
                isSynced: true
            ));
          }
        }
      } catch (e) {
        print('Error pushing location ${location.id}: $e');
      }
    }
  }

  Future<void> _pushShipmentsToServer(DateTime lastSync) async {
    if (_baseUrl.isEmpty) {
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

  Future<void> _pullLocationsFromServer(DateTime lastSync) async {
    try {
      if (_baseUrl.isEmpty) {
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
          final photoUrls = await _downloadPhotos(locationData['photo_urls'] ?? []);
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

  Future<void> _pullShipmentsFromServer(DateTime lastSync) async {
    try {
      if (_baseUrl.isEmpty) {
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

  Future<List<String>> _downloadPhotos(List<dynamic> photoUrls) async {
    final List<String> localPhotoUrls = [];

    for (var url in photoUrls) {
      try {
        if (url.toString().startsWith('/') ||
            (url.toString().contains('://') && !url.toString().startsWith('http'))) {
          localPhotoUrls.add(url.toString());
          continue;
        }

        if (url.toString().startsWith('http')) {
          final response = await http.get(Uri.parse(url));

          if (response.statusCode == 200) {
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

  Future<DateTime> _getLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncStr = prefs.getString(_lastSyncKey);
    return lastSyncStr != null ? DateTime.parse(lastSyncStr) : DateTime(2000);
  }

  Future<void> _updateLastSyncTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<String?> uploadPhoto(File photo) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload_api.php'));
      request.headers['X-API-Key'] = await _getApiKey();
      request.headers['X-Driver-Name'] = _driverName;
      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        return data['url'];
      }
    } catch (e) {
      print('Error uploading photo: $e');
    }
    return null;
  }

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
      'driver_name': shipment.driverName,
    };
  }

  Future<Shipment> _shipmentFromJson(Map<String, dynamic> json) async {
    int locationId = 0;
    if (json['location_server_id'] != null) {
      final location = await _db.getLocationByServerId(json['location_server_id']);
      if (location != null) {
        locationId = location.id!;
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

  String generateUuid() {
    return _uuid.v4();
  }

  Future<void> _uploadPhotosForLocation(Location location) async {
    if (location.photoUrls.isEmpty) return;

    List<String> uploadedUrls = [];
    List<String> localPaths = [];

    for (var photoUrl in location.photoUrls) {
      try {
        if (photoUrl.startsWith('/')) {
          final file = File(photoUrl);
          if (await file.exists()) {
            final uploadedUrl = await uploadPhoto(file);
            if (uploadedUrl != null) {
              uploadedUrls.add(uploadedUrl);
              localPaths.add(photoUrl);
            }
          }
        } else if (photoUrl.startsWith('http')) {
          uploadedUrls.add(photoUrl);
        }
      } catch (e) {
        print('Error processing photo $photoUrl: $e');
      }
    }

    if (uploadedUrls.isNotEmpty) {
      List<String> updatedPhotoUrls = List.from(location.photoUrls);
      for (int i = 0; i < localPaths.length; i++) {
        final index = updatedPhotoUrls.indexOf(localPaths[i]);
        if (index >= 0) {
          updatedPhotoUrls[index] = uploadedUrls[i];
        }
      }

      await _db.updateLocation(location.copyWith(
        photoUrls: updatedPhotoUrls,
      ));
    }
  }
}