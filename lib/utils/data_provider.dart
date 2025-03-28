import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:holz_logistik/utils/sync_service.dart';
import 'package:holz_logistik/utils/models.dart';
import 'package:holz_logistik/database/database_helper.dart';

class AppDataManager {
  static final AppDataManager _instance = AppDataManager._internal();
  factory AppDataManager() => _instance;
  AppDataManager._internal();

  final QuantityRepository _quantityRepo = QuantityRepository();
  final LocationRepository _locationRepo = LocationRepository();
  final ShipmentRepository _shipmentRepo = ShipmentRepository();
  final ContractRepository _contractRepo = ContractRepository();
  final UserRepository _userRepo = UserRepository();

  final Set<int> _modifiedQuantityIds = {};
  final Set<int> _modifiedLocationIds = {};
  final Set<int> _modifiedShipmentIds = {};
  final Set<int> _modifiedContractIds = {};
  final Set<int> _modifiedUserIds = {};

  final Map<int, Quantity> _quantityCache = {};
  final Map<int, Location> _locationCache = {};
  final Map<int, Shipment> _shipmentCache = {};
  final Map<int, Contract> _contractCache = {};
  final Map<int, User> _userCache = {};

  final _quantityStreamController = StreamController<int>.broadcast();
  final _locationStreamController = StreamController<int>.broadcast();
  final _shipmentStreamController = StreamController<int>.broadcast();
  final _contractStreamController = StreamController<int>.broadcast();
  final _userStreamController = StreamController<int>.broadcast();

  Stream<int> get quantityUpdates => _quantityStreamController.stream;
  Stream<int> get locationUpdates => _locationStreamController.stream;
  Stream<int> get shipmentUpdates => _shipmentStreamController.stream;
  Stream<int> get contractUpdates => _contractStreamController.stream;
  Stream<int> get userUpdates => _userStreamController.stream;

  Future<List<Location>> getLocations(
      {bool? hasShipments, bool? isdone}) async {
    final locations = await _locationRepo.getAll(
        hasShipments: hasShipments, isdone: isdone);

    for (final location in locations) {
      _locationCache[location.id] = location;
    }

    return locations;
  }

  Future<Location?> getLocation(int id) async {
    if (_locationCache.containsKey(id)) {
      return _locationCache[id];
    }

    final location = await _locationRepo.getById(id);
    if (location != null) {
      _locationCache[id] = location;
    }
    return location;
  }

  Future<void> updateLocation(Location location) async {
    await _locationRepo.update(location);

    _locationCache[location.id] = location;
    _modifiedLocationIds.add(location.id);
    _locationStreamController.add(location.id);
  }

  Future<void> syncWithServer() async {
    final SyncService syncService = SyncService();

    // Sync modified data to server
    if (_modifiedLocationIds.isNotEmpty) {
      final locationsToSync = _modifiedLocationIds
          .map((id) => _locationCache[id])
          .whereType<Location>()
          .toList();

      await syncService.syncLocations(locationsToSync);
      _modifiedLocationIds.clear();
    }

    // Similar for other entities...

    // Get updates from server
    final serverUpdates = await syncService.getUpdates();

    // Apply server updates locally
    if (serverUpdates.locations.isNotEmpty) {
      for (final location in serverUpdates.locations) {
        await _locationRepo.sync(location);
        _locationCache[location.id] = location;
        _locationStreamController.add(location.id);
      }
    }

    // Similar for other entities...
  }

  void dispose() {
    _locationStreamController.close();
  }
}

class LocationRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;
  
  Future<List<Location>> getAll({bool? done, bool? deleted}) async {
    final locations = await _db.batchLoadLocations(done: done, deleted: deleted);
    return locations ?? [];
  }
  
  Future<Location?> getById(int id) async {
    final db = await _db.database;
    final locationMaps = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnId} = ?',
      whereArgs: [id],
    );
    
    if (locationMaps.isEmpty) return null;
    
    // Load related entities and construct the Location
    // (simplified - you'll need to add the related entity loading)
    final location = Location.fromMap(locationMaps.first, 
      Contract.fromMap({}), Quantity.fromMap({}), Quantity.fromMap({}));
    
    return location;
  }
  
  Future<void> update(Location location) async {
    await _db.locationHandler.update(await Location.getUpdateValues(location));
  }
  
  Future<void> sync(Location location) async {
    await _db.locationHandler.sync(await Location.getUpdateValues(location));
  }
}