import 'dart:async';

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
    _listenToDatabaseSwitches();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _activeLocationStreamController =
      BehaviorSubject<List<Location>>.seeded(
    const [],
  );
  late final _locationUpdatesStreamController =
      StreamController<Location>.broadcast();

  late final Stream<List<Location>> _activeLocations =
      _activeLocationStreamController.stream;
  late final Stream<Location> _locationUpdates =
      _locationUpdatesStreamController.stream;

  static const _syncFromServerKey = '__location_sync_from_server_date_key__';

  // Subscription to database switch events
  StreamSubscription<String>? _databaseSwitchSubscription;

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
    if (oldVersion < 3 && newVersion >= 3) {
      await db.execute('''
      ALTER TABLE ${LocationTable.tableName} 
      ADD COLUMN ${LocationTable.columnOwnerInformation} TEXT
    ''');
    }
  }

  /// Listen to database switch events and reload caches
  void _listenToDatabaseSwitches() {
    _databaseSwitchSubscription = _coreLocalStorage.onDatabaseSwitch.listen(
      (newDatabaseId) async {
        await _reloadCaches();
      },
    );
  }

  /// Reload all caches after database switch
  Future<void> _reloadCaches() async {
    try {
      _activeLocationStreamController.add(const []);

      final activeLocations = await _getLocationsByCondition(isDone: false);
      _activeLocationStreamController.add(activeLocations);
    } catch (e) {
      _activeLocationStreamController.add(const []);
    }
    _locationUpdatesStreamController.add(Location());
  }

  Future<List<String>> _getSawmillIds({
    required String id,
    required bool isOversize,
  }) async {
    final db = await _coreLocalStorage.database;

    final idsJson = await db.query(
      LocationSawmillJunctionTable.tableName,
      where: '${LocationSawmillJunctionTable.columnLocationId} = ? '
          'AND ${LocationSawmillJunctionTable.columnIsOversize} = ?',
      whereArgs: [id, if (isOversize) 1 else 0],
    );

    if (idsJson.isEmpty) return const <String>[];

    return idsJson
        .map(
          (row) => row[LocationSawmillJunctionTable.columnSawmillId]! as String,
        )
        .toList();
  }

  Future<List<Location>> _addSawmillsToLocations(
    List<Map<String, dynamic>> locationsJson,
  ) async {
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

  Future<List<Location>> _getLocationsByCondition({
    required bool isDone,
  }) async {
    final db = await _coreLocalStorage.database;

    final locationsJson = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnDeleted} = 0 AND '
          '${LocationTable.columnDone} = ?',
      whereArgs: [if (isDone) 1 else 0],
    );

    return _addSawmillsToLocations(locationsJson);
  }

  /// Initialization
  Future<void> _init() async {
    final activeLocations = await _getLocationsByCondition(isDone: false);

    _activeLocationStreamController.add(activeLocations);
  }

  @override
  Stream<List<Location>> get activeLocations => _activeLocations;

  @override
  Stream<Location> get locationUpdates => _locationUpdates;

  @override
  String get dbName => _coreLocalStorage.dbName;

  /// Provides the last sync date
  @override
  Future<DateTime> getLastSyncDate() =>
      _coreLocalStorage.getLastSyncDate(_syncFromServerKey);

  /// Sets the last sync date
  @override
  Future<void> setLastSyncDate(String dbName, DateTime date) =>
      _coreLocalStorage.setLastSyncDate(dbName, _syncFromServerKey, date);

  /// Gets unsynced updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() async {
    final db = await _coreLocalStorage.database;

    final locationsJson = await db.query(
      LocationTable.tableName,
      where: 'synced = 0 ORDER BY lastEdit ASC',
    );

    final locations = await _addSawmillsToLocations(locationsJson);

    return locations.map((location) => location.toJson()).toList();
  }

  @override
  Future<List<Location>> getFinishedLocationsByDate(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _coreLocalStorage.database;

    final locationsJson = await db.query(
      LocationTable.tableName,
      where: '${LocationTable.columnDeleted} = 0 AND '
          '${LocationTable.columnDone} = 1 AND '
          '(${LocationTable.columnDate}'
          ' >= ? AND ${LocationTable.columnDate} <= ?)',
      whereArgs: [
        start.toUtc().millisecondsSinceEpoch,
        end.toUtc().millisecondsSinceEpoch,
      ],
    );

    return _addSawmillsToLocations(locationsJson);
  }

  @override
  Future<String> getPartieNrById(String id) async {
    final db = await _coreLocalStorage.database;

    final result = await db.rawQuery(
      'SELECT partieNr FROM ${LocationTable.tableName} WHERE id = ?',
      [id],
    );

    if (result.isEmpty) return '';

    return result.first['partieNr']! as String;
  }

  @override
  Future<Location> getLocationById(String id) async {
    final locations = await _coreLocalStorage.getById(
      LocationTable.tableName,
      id,
    );

    final location = Location.fromJson(locations.first);

    final sawmillIds = await _getSawmillIds(id: location.id, isOversize: false);
    final oversizeSawmillIds =
        await _getSawmillIds(id: location.id, isOversize: true);

    final updatedLocation = location.copyWith(
      sawmillIds: sawmillIds,
      oversizeSawmillIds: oversizeSawmillIds,
    );

    return updatedLocation;
  }

  /// Insert a junction value to the database based on [junctionData]
  Future<int> _insertLocationSawmillJunction(
    Map<String, dynamic> junctionData, {
    String? dbName,
  }) async {
    return _coreLocalStorage.insert(
      LocationSawmillJunctionTable.tableName,
      junctionData,
      dbName: dbName,
    );
  }

  /// Insert or Update a `location` to the database based on [locationData]
  Future<int> _insertOrUpdateLocation(
    Map<String, dynamic> locationData, {
    String? dbName,
  }) async {
    final locationId = locationData['id'] as String;

    final oldLocation =
        await _coreLocalStorage.getById(LocationTable.tableName, locationId);

    if (oldLocation.isNotEmpty) {
      final oldDate = oldLocation[0][LocationTable.columnLastEdit] as int;
      final newDate = locationData[LocationTable.columnLastEdit] as int;

      if (oldDate > newDate) {
        return 0;
      }
    }

    final sawmillIds = locationData.containsKey('sawmillIds')
        ? locationData.remove('sawmillIds') as List<String>? ?? <String>[]
        : <String>[];

    final oversizeSawmillIds = locationData.containsKey('oversizeSawmillIds')
        ? locationData.remove('oversizeSawmillIds') as List<String>? ??
            <String>[]
        : <String>[];

    await _coreLocalStorage.deleteByColumn(
      LocationSawmillJunctionTable.tableName,
      LocationSawmillJunctionTable.columnLocationId,
      locationId,
      dbName: dbName,
    );

    for (final sawmillId in sawmillIds) {
      final junctionData = {
        LocationSawmillJunctionTable.columnLocationId: locationId,
        LocationSawmillJunctionTable.columnSawmillId: sawmillId,
        LocationSawmillJunctionTable.columnIsOversize: 0,
      };
      await _insertLocationSawmillJunction(junctionData, dbName: dbName);
    }

    for (final oversizeSawmillId in oversizeSawmillIds) {
      final junctionData = {
        LocationSawmillJunctionTable.columnLocationId: locationId,
        LocationSawmillJunctionTable.columnSawmillId: oversizeSawmillId,
        LocationSawmillJunctionTable.columnIsOversize: 1,
      };
      await _insertLocationSawmillJunction(junctionData, dbName: dbName);
    }

    return _coreLocalStorage.insertOrUpdate(
      LocationTable.tableName,
      locationData,
      dbName: dbName,
    );
  }

  /// Insert or Update a [location]
  @override
  Future<int> saveLocation(
    Location location, {
    bool fromServer = false,
    String? dbName,
  }) async {
    final json = location.toJson();

    if (fromServer) {
      if (!(await _coreLocalStorage.isNewer(
        LocationTable.tableName,
        location.lastEdit,
        location.id,
      ))) {
        return 0;
      }

      json['synced'] = 1;
    } else {
      json['synced'] = 0;
      json['lastEdit'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    }

    final result = await _insertOrUpdateLocation(json, dbName: dbName);
    final activeLocations =
        List<Location>.from(_activeLocationStreamController.value);

    if (location.done == false) {
      final index = activeLocations.indexWhere((l) => l.id == location.id);
      if (index > -1) {
        activeLocations[index] = location;
      } else {
        activeLocations.add(location);
      }
    } else {
      activeLocations.removeWhere((l) => l.id == location.id);
    }

    _locationUpdatesStreamController.add(location);
    _activeLocationStreamController.add(activeLocations);

    return result;
  }

  /// Delete a Location from the database based on [id]
  Future<int> _deleteLocation(String id, String dbName) async {
    return _coreLocalStorage.delete(LocationTable.tableName, id, dbName);
  }

  /// Marks a Location as deleted based on [id] and [done] status
  @override
  Future<int> markLocationDeleted({
    required String id,
    required bool done,
  }) async {
    final resultList =
        await _coreLocalStorage.getByIdForDeletion(LocationTable.tableName, id);

    if (resultList.isEmpty) return 0;

    final location = Location.fromJson(resultList.first);
    final json = Map<String, dynamic>.from(resultList.first);
    json['deleted'] = 1;
    json['synced'] = 0;

    final result = await _insertOrUpdateLocation(json);

    if (done == false) {
      final locations =
          List<Location>.from(_activeLocationStreamController.value)
            ..removeWhere((l) => l.id == id);

      _activeLocationStreamController.add(locations);
    }

    _locationUpdatesStreamController.add(location);

    return result;
  }

  /// Delete a Location based on [id]
  @override
  Future<int> deleteLocation({
    required String id,
    required String dbName,
  }) async {
    final result =
        await _coreLocalStorage.getByIdForDeletion(LocationTable.tableName, id);

    if (result.isEmpty) return 0;

    await _deleteLocation(id, dbName);
    final location = Location.fromJson(result.first);

    if (location.done == false) {
      final locations =
          List<Location>.from(_activeLocationStreamController.value)
            ..removeWhere((l) => l.id == id);

      _activeLocationStreamController.add(locations);
    }

    _locationUpdatesStreamController.add(location);

    return 0;
  }

  /// Sets synced
  @override
  Future<void> setSynced({required String id, required String dbName}) =>
      _coreLocalStorage.setSynced(LocationTable.tableName, id, dbName);

  /// Close the both controllers
  @override
  Future<void> close() {
    _databaseSwitchSubscription?.cancel();
    _activeLocationStreamController.close();
    return _locationUpdatesStreamController.close();
  }
}
