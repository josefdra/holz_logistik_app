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

  void startAutoSync({Duration interval = const Duration(seconds: 1)}) {
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

      await SyncService.syncChanges();

      await loadLocations();
      await loadArchivedLocations();

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
      final allShipments = await _db.getAllShipments();

      _shipmentsByLocation = {};
      for (var shipment in allShipments) {
        _shipmentsByLocation
            .putIfAbsent(shipment.locationId, () => [])
            .add(shipment);
      }

      await loadLocations();
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
      totalNormalQuantity += shipment.normalQuantity;
      totalOversizeQuantity += shipment.oversizeQuantity;
      totalPieceCount += shipment.pieceCount;
    }

    return {
      'normalQuantity': totalNormalQuantity,
      'oversizeQuantity': totalOversizeQuantity,
      'pieceCount': totalPieceCount,
    };
  }

  Future<void> addShipment(Shipment shipment) async {
    try {
      await _db.insertShipment(shipment);
      await syncData();
    } catch (e) {
      debugPrint('Error adding shipment: $e');
      rethrow;
    }
  }

  Future<void> undoShipment(Shipment shipment) async {
    try {
      await _db.deleteShipment(shipment.id);
      await syncData();
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
      final allShipments = await _db.getAllShipments();
      _shipmentsByLocation = {};
      for (var shipment in allShipments) {
        _shipmentsByLocation
            .putIfAbsent(shipment.locationId, () => [])
            .add(shipment);
      }
    } catch (e) {
      debugPrint('Error loading locations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Location?> addLocation(Location location) async {
    try {
      final id = await _db.insertOrUpdateLocation(location);
      await syncData();

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
      await syncData();

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
      await syncData();
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
