import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:holz_logistik/utils/sync_service.dart';
import 'package:holz_logistik/utils/models.dart';
import 'package:holz_logistik/database/database_helper.dart';

class DataProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Location> _locations = [];
  List<Location> _archivedLocations = [];
  bool _isLoading = false;
  Map<int, List<Shipment>> _shipmentsByLocation = {};
  Timer? _syncTimer;

  List<Location> get locations => _locations;
  List<Location> get archivedLocations => _archivedLocations;
  Map<int, List<Shipment>> get shipmentsByLocation => _shipmentsByLocation;
  bool get isLoading => _isLoading;

  void init() {
    SyncService.initializeUser();
  }

  @override
  void dispose() {
    stopAutoSync();
    super.dispose();
  }

  void startAutoSync({Duration interval = const Duration(seconds: 10)}) {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(interval, (_) {
      syncData();
    });
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  Future<void> syncData() async {
    try {
      _isLoading = true;
      notifyListeners();
      SyncService.syncChanges();

      final locationsData = _db.getAllLocations();
      final shipmentsData = _db.getAllShipments();

      List<dynamic> results = await Future.wait([locationsData, shipmentsData]);

      _locations = results[0];

      final allShipments = results[1];
      _shipmentsByLocation = {};
      for (var shipment in allShipments) {
        _shipmentsByLocation
            .putIfAbsent(shipment.locationId, () => [])
            .add(shipment);
      }

      updateArchivedStatus();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error syncing data: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArchivedLocations() async {
    try {
      await SyncService.syncChanges();
      final allShipments = await _db.getAllShipments();

      _shipmentsByLocation = {};
      for (var shipment in allShipments) {
        _shipmentsByLocation
            .putIfAbsent(shipment.locationId, () => [])
            .add(shipment);
      }

      await loadLocations();
      updateArchivedStatus();
    } catch (e) {
      debugPrint('Error loading archived locations: $e');
    }
    notifyListeners();
  }

  List<Location> get locationsWithShipments {
    final Set<int> locationIdsWithShipments = {};

    for (var entry in _shipmentsByLocation.entries) {
      locationIdsWithShipments.add(entry.key);
    }

    return _locations
        .where((location) => locationIdsWithShipments.contains(location.id))
        .toList();
  }

  Map<String, dynamic> getShippedTotals(int locationId) {
    if (!_shipmentsByLocation.containsKey(locationId)) {
      return {'normalQuantity': 0.0, 'oversizeQuantity': 0.0, 'pieceCount': 0};
    }

    final shipments = _shipmentsByLocation[locationId]!.toList();

    double totalNormalQuantity = 0.0;
    double totalOversizeQuantity = 0.0;
    int totalPieceCount = 0;

    for (var shipment in shipments) {
      if (shipment.normalQuantity != null) {
        totalNormalQuantity += shipment.normalQuantity!;
      }
      if (shipment.oversizeQuantity != null) {
        totalOversizeQuantity += shipment.oversizeQuantity!;
      }

      totalPieceCount += shipment.pieceCount;
    }

    return {
      'normalQuantity': totalNormalQuantity,
      'oversizeQuantity': totalOversizeQuantity,
      'pieceCount': totalPieceCount,
    };
  }

  void updateArchivedStatus() {
    _archivedLocations = [];
    for (var locationId in _shipmentsByLocation.keys) {
      var location =
          _locations.firstWhere((location) => location.id == locationId);
      if (location.id != -1 && _isLocationFullyShipped(location)) {
        _archivedLocations.add(location);
        _locations.removeWhere((location) => location.id == locationId);
      }
    }
  }

  bool _isLocationFullyShipped(Location location) {
    if (!_shipmentsByLocation.containsKey(location.id)) return false;

    final shipments = _shipmentsByLocation[location.id]!.toList();

    double totalNormalQuantityShipped = 0;
    int totalPieceCountShipped = 0;
    double totalOversizeShipped = 0;

    for (var shipment in shipments) {
      if (shipment.normalQuantity != null) {
        totalNormalQuantityShipped += shipment.normalQuantity!;
      }

      if (shipment.oversizeQuantity != null) {
        totalOversizeShipped += shipment.oversizeQuantity!;
      }

      totalPieceCountShipped += shipment.pieceCount;
    }

    return totalNormalQuantityShipped >= (location.normalQuantity ?? 0) &&
        (totalPieceCountShipped >= location.pieceCount) &&
        (location.oversizeQuantity == null ||
            totalOversizeShipped >= location.oversizeQuantity!);
  }

  Future<List<Shipment>> getShipmentHistory(int locationId) async {
    await SyncService.syncChanges();
    return await _db.getShipmentsByLocation(locationId);
  }

  Future<void> addShipment(Shipment shipment) async {
    try {
      await _db.insertShipment(shipment);
      await SyncService.syncChanges();

      final location = _locations
          .firstWhere((location) => location.id == shipment.locationId);

      double? newNormalQuantity =
          ((location.normalQuantity! - shipment.normalQuantity!) * 10).round() /
              10;
      double? newOversizeQuantity =
          ((location.oversizeQuantity! - shipment.oversizeQuantity!) * 10)
                  .round() /
              10;
      final newPieceCount = location.pieceCount - shipment.pieceCount;

      final updatedLocation = location.copyWith(
        normalQuantity: newNormalQuantity,
        oversizeQuantity: newOversizeQuantity,
        pieceCount: newPieceCount,
      );

      await updateLocation(updatedLocation);

      _shipmentsByLocation
          .putIfAbsent(shipment.locationId, () => [])
          .add(shipment);

      updateArchivedStatus();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding shipment: $e');
      rethrow;
    }
  }

  Future<void> undoShipment(Shipment shipment) async {
    try {
      await _db.deleteShipment(shipment.id);
      await SyncService.syncChanges();

      var location = _locations.firstWhere(
        (location) => location.id == shipment.locationId,
        orElse: () => _archivedLocations.firstWhere(
          (location) => location.id == shipment.locationId,
        ),
      );

      final updatedLocation = location.copyWith(
        normalQuantity:
            (location.normalQuantity ?? 0) + (shipment.normalQuantity ?? 0),
        pieceCount: location.pieceCount + shipment.pieceCount,
        oversizeQuantity: location.oversizeQuantity != null &&
                shipment.oversizeQuantity != null
            ? location.oversizeQuantity! + shipment.oversizeQuantity!
            : location.oversizeQuantity,
      );

      await updateLocation(updatedLocation);
      await loadArchivedLocations();
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
      await SyncService.syncChanges();
      _locations = await _db.getAllLocations();
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Location?> addLocation(Location location) async {
    try {
      final id = await _db.insertOrUpdateLocation(location);
      await SyncService.syncChanges();

      if (id > 0) {
        _locations.add(location);
        notifyListeners();
      }

      return location;
    } catch (e) {
      debugPrint('Error adding location: $e');
      return null;
    }
  }

  Future<bool> updateLocation(Location location) async {
    try {
      await _db.insertOrUpdateLocation(location);
      await SyncService.syncChanges();

      if (location.id > 0) {
        final index = _locations.indexWhere((loc) => loc.id == location.id);
        if (index >= 0) {
          _locations[index] = location;
        }
        notifyListeners();
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
      await SyncService.syncChanges();
      if (result == true) {
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
}
