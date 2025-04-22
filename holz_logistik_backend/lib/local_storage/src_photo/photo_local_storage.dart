import 'dart:async';

import 'package:holz_logistik_backend/api/photo_api.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/photo_local_storage.dart';
import 'package:sqflite/sqflite.dart';

/// {@template photo_local_storage}
/// A flutter implementation of the photo PhotoLocalStorage that uses
/// CoreLocalStorage and sqflite.
/// {@endtemplate}
class PhotoLocalStorage extends PhotoApi {
  /// {@macro photo_local_storage}
  PhotoLocalStorage({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    // Register the table with the core database
    _coreLocalStorage
      ..registerTable(PhotoTable.createTable)
      ..registerMigration(_migratePhotoTable);
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _photoUpdatesStreamController =
      StreamController<String>.broadcast();

  late final Stream<String> _photoUpdates =
      _photoUpdatesStreamController.stream;

  static const _syncToServerKey = '__photo_sync_to_server_date_key__';
  static const _syncFromServerKey = '__photo_sync_from_server_date_key__';

  /// Migration function for photo table
  Future<void> _migratePhotoTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  @override
  Stream<String> get photoUpdates => _photoUpdates;

  /// Provides the last sync date
  @override
  Future<DateTime> getLastSyncDate(String type) async {
    final prefs = await _coreLocalStorage.sharedPreferences;
    final key = type == 'toServer' ? _syncToServerKey : _syncFromServerKey;

    final dateString = prefs.getString(key);
    final date = dateString != null
        ? DateTime.parse(dateString)
        : DateTime.fromMillisecondsSinceEpoch(0).toUtc();

    return date;
  }

  /// Sets the last sync date
  @override
  Future<void> setLastSyncDate(String type, DateTime date) async {
    final prefs = await _coreLocalStorage.sharedPreferences;
    final key = type == 'toServer' ? _syncToServerKey : _syncFromServerKey;

    await prefs.setString(key, date.toUtc().toIso8601String());
  }

  /// Gets photo updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() async {
    final db = await _coreLocalStorage.database;
    final date = await getLastSyncDate('toServer');

    final result = await db.query(
      PhotoTable.tableName,
      where: '${PhotoTable.columnLastEdit} >= ? ORDER BY '
          '${PhotoTable.columnLastEdit} ASC',
      whereArgs: [
        date.toIso8601String(),
      ],
    );

    return result;
  }

  @override
  Future<bool> checkIfPhotoExists(String photoId) async {
    final db = await _coreLocalStorage.database;
    final res = await db.rawQuery(
      '''
    SELECT ${PhotoTable.columnId} FROM ${PhotoTable.tableName} WHERE ${PhotoTable.columnId} = ?
  ''',
      [photoId],
    );

    return res.isNotEmpty;
  }

  @override
  Future<List<Photo>> getPhotosByLocation(String locationId) async {
    final photos = await _coreLocalStorage.getByColumn(
      PhotoTable.tableName,
      PhotoTable.columnLocationId,
      locationId,
    );

    return photos.map(Photo.fromJson).toList();
  }

  @override
  Future<List<String>> getPhotoIdsByLocation(String locationId) async {
    final db = await _coreLocalStorage.database;
    final res = await db.rawQuery(
      '''
    SELECT ${PhotoTable.columnId} FROM ${PhotoTable.tableName} WHERE ${PhotoTable.columnLocationId} = ?
  ''',
      [locationId],
    );

    return res.isNotEmpty
        ? res.map((element) => element[PhotoTable.columnId]! as String).toList()
        : const [];
  }

  /// Insert or Update a `photo` to the database based on [photoData]
  Future<int> _insertOrUpdatePhoto(Map<String, dynamic> photoData) async {
    return _coreLocalStorage.insertOrUpdate(
      PhotoTable.tableName,
      photoData,
    );
  }

  /// Insert or Update a [photo]
  @override
  Future<int> savePhoto(Photo photo) async {
    final result = await _insertOrUpdatePhoto(photo.toJson());

    _photoUpdatesStreamController.add(photo.locationId);

    return result;
  }

  /// Delete a Photo from the database based on [id]
  Future<int> _deletePhoto(String id) async {
    return _coreLocalStorage.delete(PhotoTable.tableName, id);
  }

  /// Delete a Photo based on [id] and [locationId]
  @override
  Future<int> deletePhoto({
    required String id,
    required String locationId,
  }) async {
    final result = await _deletePhoto(id);
    _photoUpdatesStreamController.add(locationId);

    return result;
  }

  /// Delete a Photos based on [locationId]
  @override
  Future<int> deletePhotosByLocationId({
    required String locationId,
  }) async {
    return _coreLocalStorage.deleteByColumn(
      PhotoTable.tableName,
      PhotoTable.columnLocationId,
      locationId,
    );
  }

  /// Close the [_photoUpdatesStreamController]
  @override
  Future<void> close() {
    return _photoUpdatesStreamController.close();
  }
}
