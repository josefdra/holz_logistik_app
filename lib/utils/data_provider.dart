import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:holz_logistik/utils/sync_service.dart';
import 'package:holz_logistik/utils/models.dart';
import 'package:holz_logistik/database/database_helper.dart';

class DataProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  static final _activeLocationsStreamController =
      StreamController<List<Location>>.broadcast();
  static final _archiveLocationsStreamController =
      StreamController<List<Location>>.broadcast();

  static Stream<List<Location>> get activeLocationsStream =>
      _activeLocationsStreamController.stream;
  static Stream<List<Location>> get archivedLocationsStream =>
      _archiveLocationsStreamController.stream;

  void init() {
    SyncService.initializeUser();
  }

  @override
  void dispose() {
    super.dispose();
    _activeLocationsStreamController.close();
    _archiveLocationsStreamController.close();
  }

  Future<List<Location>> getActiveLocations() async {
    return _db.getActiveLocations();
  }

  Future<List<Location>> getArchivedLocations() async {
    return _db.getArchivedLocations();
  }

  Future<void> startObservingLocations() async {
    _updateStreams();

    Timer.periodic(const Duration(seconds: 1), (_) async {
      _updateStreams();
    });
  }

  Future<void> _updateStreams() async {
    await SyncService.syncChanges();
    final locations = await getActiveLocations();
    if (!_activeLocationsStreamController.isClosed) {
      _activeLocationsStreamController.add(locations);
    }

    final archiveLocations = await getArchivedLocations();
    if (!_archiveLocationsStreamController.isClosed) {
      _archiveLocationsStreamController.add(archiveLocations);
    }
  }

  Future<int> addOrUpdateLocation(Location location) async {
    try {
      final id = await _db.insertOrUpdateLocation(location);
      await _updateStreams();

      return id;
    } catch (e) {
      debugPrint('Error adding/ updating location: $e');
      rethrow;
    }
  }

  Future<void> deleteLocation(int id) async {
    try {
      await _db.deleteLocation(id);
      await _updateStreams();
    } catch (e) {
      debugPrint('Error deleting location: $e');
      rethrow;
    }
  }

  Future<void> addShipment(Shipment shipment) async {
    try {
      await _db.insertShipment(shipment);
      await _updateStreams();
    } catch (e) {
      debugPrint('Error adding shipment: $e');
      rethrow;
    }
  }

  Future<void> printAllData() async {
    _db.printDatabaseContents();
  }
}

/*
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

  */
