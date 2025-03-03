import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../database/database_helper.dart';
import '../models/location.dart';
import '../models/shipment.dart';
import '../providers/sync_provider.dart';

class LocationProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Location> _locations = [];
  bool _isLoading = false;
  SyncProvider? _syncProvider;
  List<Location> _archivedLocations = [];
  Map<int, List<Shipment>> _shipmentsByLocation = {};

  void setSyncProvider(SyncProvider syncProvider) {
    _syncProvider = syncProvider;
  }

  List<Location> get locations => _locations;
  bool get isLoading => _isLoading;
  List<Location> get archivedLocations => _archivedLocations;

  Future<void> loadArchivedLocations() async {
    try {
      final allShipments = await _db.getAllShipments();

      _shipmentsByLocation = {};
      for (var shipment in allShipments) {
        _shipmentsByLocation.putIfAbsent(shipment.locationId, () => []).add(shipment);
      }

      await loadLocations();
      _updateArchivedStatus();
    } catch (e) {
      debugPrint('Error loading archived locations: $e');
    }
    notifyListeners();
  }

  List<Location> get locationsWithShipments {
    final Set<int> locationIdsWithShipments = {};

    for (var entry in _shipmentsByLocation.entries) {
      if (entry.value.any((s) => !s.isUndone)) {
        locationIdsWithShipments.add(entry.key);
      }
    }

    return _locations.where((location) =>
        locationIdsWithShipments.contains(location.id)
    ).toList();
  }

  Map<String, int> getShippedTotals(int locationId) {
    if (!_shipmentsByLocation.containsKey(locationId)) {
      return {'quantity': 0, 'pieceCount': 0, 'oversizeQuantity': 0};
    }

    final shipments = _shipmentsByLocation[locationId]!
        .where((s) => !s.isUndone)
        .toList();

    int totalQuantity = 0;
    int totalPieceCount = 0;
    int totalOversize = 0;

    for (var shipment in shipments) {
      totalQuantity += shipment.quantity;
      totalPieceCount += shipment.pieceCount;
      if (shipment.oversizeQuantity != null) {
        totalOversize += shipment.oversizeQuantity!;
      }
    }

    return {
      'quantity': totalQuantity,
      'pieceCount': totalPieceCount,
      'oversizeQuantity': totalOversize,
    };
  }

  void _updateArchivedStatus() {
    _archivedLocations = [];
    for (var locationId in _shipmentsByLocation.keys) {
      var location = _locations.firstWhere(
            (location) => location.id == locationId,
        orElse: () => Location(
          id: -1,
          name: '',
          latitude: 0,
          longitude: 0,
        ),
      );
      if (location.id != -1 && _isLocationFullyShipped(location)) {
        _archivedLocations.add(location);
        _locations.removeWhere((location) => location.id == locationId);
      }
    }
  }

  bool _isLocationFullyShipped(Location location) {
    if (!_shipmentsByLocation.containsKey(location.id)) return false;

    final shipments = _shipmentsByLocation[location.id]!
        .where((s) => !s.isUndone)
        .toList();

    int totalQuantityShipped = 0;
    int totalPieceCountShipped = 0;
    int totalOversizeShipped = 0;

    for (var shipment in shipments) {
      totalQuantityShipped += shipment.quantity;
      totalPieceCountShipped += shipment.pieceCount;
      if (shipment.oversizeQuantity != null) {
        totalOversizeShipped += shipment.oversizeQuantity!;
      }
    }

    return totalQuantityShipped >= (location.quantity ?? 0) &&
        totalPieceCountShipped >= (location.pieceCount ?? 0) &&
        (location.oversizeQuantity == null ||
            totalOversizeShipped >= location.oversizeQuantity!);
  }

  Future<List<Shipment>> getShipmentHistory(int locationId) async {
    return await _db.getShipmentsByLocation(locationId);
  }

  void _triggerSync() {
    if (_syncProvider != null) {
      _syncProvider!.syncAfterChange();
    }
  }

  Future<void> addShipment(Shipment shipment) async {
    try {
      await _db.insertShipment(shipment);

      final location = _locations.firstWhere((location) => location.id == shipment.locationId);

      final updatedLocation = location.copyWith(
        quantity: (location.quantity ?? 0) - shipment.quantity,
        pieceCount: (location.pieceCount ?? 0) - shipment.pieceCount,
        oversizeQuantity: location.oversizeQuantity != null && shipment.oversizeQuantity != null
            ? location.oversizeQuantity! - shipment.oversizeQuantity!
            : location.oversizeQuantity,
      );

      await updateLocation(updatedLocation);
      await loadArchivedLocations();
      _triggerSync();
    } catch (e) {
      debugPrint('Error adding shipment: $e');
      rethrow;
    }
  }

  Future<void> undoShipment(Shipment shipment) async {
    try {
      final updatedShipment = shipment.copyWith(isUndone: true);
      await _db.updateShipment(updatedShipment);

      var location = _locations.firstWhere(
            (location) => location.id == shipment.locationId,
        orElse: () => _archivedLocations.firstWhere(
              (location) => location.id == shipment.locationId,
        ),
      );

      final updatedLocation = location.copyWith(
        quantity: (location.quantity ?? 0) + shipment.quantity,
        pieceCount: (location.pieceCount ?? 0) + shipment.pieceCount,
        oversizeQuantity: location.oversizeQuantity != null && shipment.oversizeQuantity != null
            ? location.oversizeQuantity! + shipment.oversizeQuantity!
            : location.oversizeQuantity,
      );

      await updateLocation(updatedLocation);
      await loadArchivedLocations();
      _triggerSync();
    } catch (e) {
      debugPrint('Error undoing shipment: $e');
      rethrow;
    }
  }

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
      final List<String> savedPhotoUrls = await _savePhotosToLocalStorage(location.newPhotos);

      final locationToSave = location.copyWith(
        photoUrls: [...location.photoUrls, ...savedPhotoUrls],
      );

      final id = await _db.insertLocation(locationToSave);
      final savedLocation = await _db.getLocation(id);

      if (savedLocation != null) {
        _locations.add(savedLocation);
        notifyListeners();
        _triggerSync();
      }

      return savedLocation;
    } catch (e) {
      debugPrint('Error adding location: $e');
      return null;
    }
  }

  Future<bool> updateLocation(Location location) async {
    try {
      final List<String> savedPhotoUrls = await _savePhotosToLocalStorage(location.newPhotos);

      final locationToUpdate = location.copyWith(
        photoUrls: [...location.photoUrls, ...savedPhotoUrls],
        isSynced: false,
      );

      final result = await _db.updateLocation(locationToUpdate);

      if (result > 0) {
        final index = _locations.indexWhere((loc) => loc.id == location.id);
        if (index >= 0) {
          _locations[index] = locationToUpdate;
        }
        notifyListeners();
        _triggerSync();
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
        _triggerSync();
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
      if (photoUrl.startsWith('/')) {
        final file = File(photoUrl);
        if (await file.exists()) {
          await file.delete();
        }
      }

      final updatedPhotoUrls = List<String>.from(location.photoUrls)..remove(photoUrl);
      final updatedLocation = location.copyWith(photoUrls: updatedPhotoUrls);

      await updateLocation(updatedLocation);
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
  }
}