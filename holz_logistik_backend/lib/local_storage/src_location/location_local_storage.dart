import 'package:holz_logistik_backend/api/location_api.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/location_local_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

/// {@template location_local_storage}
/// A flutter implementation of the location LocationLocalStorage that uses
/// CoreLocalStorage and sqflite.
/// {@endtemplate}
class LocationLocalStorage extends LocationApi {
  /// {@macro location_local_storage}
  LocationLocalStorage({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    // Register the tables with the core database
    _coreLocalStorage
      ..registerTable(LocationTable.createTable)
      ..registerMigration(_migrateLocationTable)
      ..registerTable(LocationSawmillJunctionTable.createTable)
      ..registerMigration(_migrateLocationSawmillTable);

    _init();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _activeLocationStreamController =
      BehaviorSubject<List<Location>>.seeded(
    const [],
  );
  late final _doneLocationStreamController =
      BehaviorSubject<List<Location>>.seeded(
    const [],
  );

  /// Migration function for location table
  Future<void> _migrateLocationSawmillTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Migration function for location table
  Future<void> _migrateLocationTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  Future<List<String>> _getSawmillIds({
    required String id,
    required bool isOversize,
  }) async {
    final db = await _coreLocalStorage.database;

    final idsJson = await db.query(
      LocationSawmillJunctionTable.tableName,
      where:
          '${LocationSawmillJunctionTable.columnLocationId} = ? '
          'AND ${LocationSawmillJunctionTable.columnIsOversize} = ?',
      whereArgs: [id, if (isOversize) 1 else 0],
    );

    return idsJson
        .map(
          (row) => row[LocationSawmillJunctionTable.columnSawmillId]! as String,
        )
        .toList();
  }

  Future<List<Location>> _getLocationsByCondition({
    required bool isDone,
  }) async {
    final db = await _coreLocalStorage.database;

    final locationsJson = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnDone} = ?',
      whereArgs: [if (isDone) 1 else 0],
    );

    final locations = locationsJson
        .map(
          (location) => Location.fromJson(Map<String, dynamic>.from(location)),
        )
        .toList();

    for (var i = 0; i < locations.length; i++) {
      final location = locations[i];
      final sawmillIds =
          await _getSawmillIds(id: location.id, isOversize: false);
      final oversizeSawmillIds =
          await _getSawmillIds(id: location.id, isOversize: true);

      locations[i] = location.copyWith(
        sawmillIds: sawmillIds,
        oversizeSawmillIds: oversizeSawmillIds,
      );
    }

    return locations;
  }

  /// Initialization
  Future<void> _init() async {
    final activeLocations = await _getLocationsByCondition(isDone: false);
    final doneLocations = await _getLocationsByCondition(isDone: true);

    _activeLocationStreamController.add(activeLocations);
    _doneLocationStreamController.add(doneLocations);
  }

  @override
  Stream<List<Location>> get activeLocations =>
      _activeLocationStreamController.asBroadcastStream();

  @override
  Stream<List<Location>> get doneLocations =>
      _doneLocationStreamController.asBroadcastStream();

  @override
  List<Location> get currentActiveLocations =>
      _activeLocationStreamController.value;

  @override
  List<Location> get currentDoneLocations =>
      _doneLocationStreamController.value;

  @override
  Future<Location> getLocationById(String id) async {
    final locations = await _coreLocalStorage.getById(
      LocationTable.tableName,
      id,
    );

    return Location.fromJson(locations.first);
  }

  /// Insert a junction value to the database based on [junctionData]
  Future<int> _insertLocationSawmillJunction(
    Map<String, dynamic> junctionData,
  ) async {
    return _coreLocalStorage.insert(
      LocationSawmillJunctionTable.tableName,
      junctionData,
    );
  }

  /// Insert or Update a `location` to the database based on [locationData]
  Future<int> _insertOrUpdateLocation(Map<String, dynamic> locationData) async {
    final locationId = locationData['id'] as String;
    final sawmillIds = locationData.remove('sawmillIds') as List<String>;
    final oversizeSawmillIds =
        locationData.remove('oversizeSawmillIds') as List<String>;

    await _coreLocalStorage.deleteByColumn(
      LocationSawmillJunctionTable.tableName,
      LocationSawmillJunctionTable.columnLocationId,
      locationId,
    );

    for (final sawmillId in sawmillIds) {
      final junctionData = {
        LocationSawmillJunctionTable.columnLocationId: locationId,
        LocationSawmillJunctionTable.columnSawmillId: sawmillId,
        LocationSawmillJunctionTable.columnIsOversize: 0,
      };
      await _insertLocationSawmillJunction(junctionData);
    }

    for (final oversizeSawmillId in oversizeSawmillIds) {
      final junctionData = {
        LocationSawmillJunctionTable.columnLocationId: locationId,
        LocationSawmillJunctionTable.columnSawmillId: oversizeSawmillId,
        LocationSawmillJunctionTable.columnIsOversize: 1,
      };
      await _insertLocationSawmillJunction(junctionData);
    }

    return _coreLocalStorage.insertOrUpdate(
      LocationTable.tableName,
      locationData,
    );
  }

  /// Insert or Update a [location]
  @override
  Future<int> saveLocation(Location location) {
    late final BehaviorSubject<List<Location>> controller;

    if (location.done == false) {
      controller = _activeLocationStreamController;
    } else {
      controller = _doneLocationStreamController;
    }

    final locations = [...controller.value];
    final locationIndex = locations.indexWhere((l) => l.id == location.id);

    if (locationIndex >= 0) {
      locations[locationIndex] = location;
    } else {
      locations.add(location);
    }

    controller.add(locations);
    return _insertOrUpdateLocation(location.toJson());
  }

  /// Delete a Location from the database based on [id]
  Future<int> _deleteLocation(String id) async {
    return _coreLocalStorage.delete(LocationTable.tableName, id);
  }

  /// Delete a Location based on [id] and [done] status
  @override
  Future<int> deleteLocation({required String id, required bool done}) async {
    late final BehaviorSubject<List<Location>> controller;

    if (done == false) {
      controller = _activeLocationStreamController;
    } else {
      controller = _doneLocationStreamController;
    }

    final locations = [...controller.value];
    final locationIndex = locations.indexWhere((l) => l.id == id);

    locations.removeAt(locationIndex);

    controller.add(locations);
    return _deleteLocation(id);
  }

  /// Close the both controllers
  @override
  Future<void> close() {
    _activeLocationStreamController.close();
    return _doneLocationStreamController.close();
  }
}
