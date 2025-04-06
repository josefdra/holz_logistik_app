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
    // Register the table with the core database
    _coreLocalStorage
      ..registerTable(LocationTable.createTable)
      ..registerMigration(_migrateLocationTable);

    _init();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _locationStreamController = BehaviorSubject<List<Location>>.seeded(
    const [],
  );

  /// Migration function for location table
  Future<void> _migrateLocationTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Initialization
  Future<void> _init() async {
    final locationsJson =
        await _coreLocalStorage.getAll(LocationTable.tableName);
    final locations = locationsJson
        .map(
          (location) => Location.fromJson(Map<String, dynamic>.from(location)),
        )
        .toList();
    _locationStreamController.add(locations);
  }

  /// Get the `location`s from the [_locationStreamController]
  @override
  Stream<List<Location>> get locations =>
      _locationStreamController.asBroadcastStream();

  /// Insert or Update a `location` to the database based on [locationData]
  Future<int> _insertOrUpdateLocation(Map<String, dynamic> locationData) async {
    return _coreLocalStorage.insertOrUpdate(
      LocationTable.tableName,
      locationData,
    );
  }

  /// Insert or Update a [location]
  @override
  Future<int> saveLocation(Location location) {
    final locations = [..._locationStreamController.value];
    final locationIndex = locations.indexWhere((t) => t.id == location.id);
    if (locationIndex >= 0) {
      locations[locationIndex] = location;
    } else {
      locations.add(location);
    }

    _locationStreamController.add(locations);
    return _insertOrUpdateLocation(location.toJson());
  }

  /// Delete a Location from the database based on [id]
  Future<int> _deleteLocation(String id) async {
    return _coreLocalStorage.delete(LocationTable.tableName, id);
  }

  /// Delete a Location based on [id]
  @override
  Future<int> deleteLocation(String id) async {
    final locations = [..._locationStreamController.value];
    final locationIndex = locations.indexWhere((l) => l.id == id);
    if (locationIndex == -1) {
      throw LocationNotFoundException();
    } else {
      locations.removeAt(locationIndex);
      _locationStreamController.add(locations);
      return _deleteLocation(id);
    }
  }

  /// Close the [_locationStreamController]
  @override
  Future<void> close() {
    return _locationStreamController.close();
  }
}
