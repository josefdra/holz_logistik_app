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
      StreamController<List<Map<Location, List<Shipment>>>>.broadcast();

  final Set<int> _observedLocationIds = {};

  static Stream<List<Location>> get activeLocationsStream =>
      _activeLocationsStreamController.stream;
  static Stream<List<Map<Location, List<Shipment>>>> get archivedLocationsStream =>
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

  Future<List<Map<Location, List<Shipment>>>> getArchivedLocations() async {
    return _db.getArchivedLocationsWithShipments();
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
      _observedLocationIds.remove(id);
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

  Future<void> undoShipment(int shipmentId) async {
    try {
      await _db.deleteShipment(shipmentId);

      await _updateStreams();
    } catch (e) {
      debugPrint('Error undoing shipment: $e');
      rethrow;
    }
  }

  Future<void> printAllData() async {
    _db.printDatabaseContents();
  }
}
