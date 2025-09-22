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
  Future<List<Map<String, dynamic>>> getUpdates() =>
      _coreLocalStorage.getUpdates(PhotoTable.tableName);

  @override
  Future<bool> checkIfPhotoExists(String photoId) async {
    final db = await _coreLocalStorage.database;
    final res = await db.rawQuery(
      'SELECT ${PhotoTable.columnId} FROM ${PhotoTable.tableName} '
      'WHERE ${PhotoTable.columnDeleted} = 0 AND ${PhotoTable.columnId} = ?',
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
      'SELECT ${PhotoTable.columnId} FROM ${PhotoTable.tableName} '
      'WHERE ${PhotoTable.columnDeleted} = 0 '
      'AND ${PhotoTable.columnLocationId} = ?',
      [locationId],
    );

    return res.isNotEmpty
        ? res.map((element) => element[PhotoTable.columnId]! as String).toList()
        : const [];
  }

  /// Insert or Update a `photo` to the database based on [photoData]
  Future<int> _insertOrUpdatePhoto(
    Map<String, dynamic> photoData, {
    String? dbName,
  }) async {
    return _coreLocalStorage.insertOrUpdate(
      PhotoTable.tableName,
      photoData,
      dbName: dbName,
    );
  }

  /// Insert or Update a [photo]
  @override
  Future<int> savePhoto(
    Photo photo, {
    bool fromServer = false,
    String? dbName,
  }) async {
    final json = photo.toJson();

    if (fromServer) {
      if (!(await _coreLocalStorage.isNewer(
        PhotoTable.tableName,
        photo.lastEdit,
        photo.id,
      ))) {
        return 0;
      }

      json['synced'] = 1;
    } else {
      json['synced'] = 0;
      json['lastEdit'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    }

    final result = await _insertOrUpdatePhoto(json, dbName: dbName);

    _photoUpdatesStreamController.add(photo.locationId);

    return result;
  }

  /// Delete a Photo from the database based on [id]
  Future<int> _deletePhoto(String id, String dbName) async {
    return _coreLocalStorage.delete(PhotoTable.tableName, id, dbName);
  }

  /// Delete a Photo based on [id] and [locationId]
  @override
  Future<void> markPhotoDeleted({
    required String id,
    required String locationId,
  }) async {
    final resultList =
        await _coreLocalStorage.getByIdForDeletion(PhotoTable.tableName, id);

    if (resultList.isEmpty) return Future<void>.value();

    final photo = Photo.fromJson(resultList.first);
    final json = Map<String, dynamic>.from(resultList.first);
    json['deleted'] = 1;
    json['synced'] = 0;
    await _insertOrUpdatePhoto(json);

    _photoUpdatesStreamController.add(photo.locationId);

    return Future<void>.value();
  }

  /// Delete a Photo based on [id]
  @override
  Future<int> deletePhoto({required String id, required String dbName}) async {
    final result =
        await _coreLocalStorage.getByIdForDeletion(PhotoTable.tableName, id);

    if (result.isEmpty) return 0;

    final photo = Photo.fromJson(result.first);
    _photoUpdatesStreamController.add(photo.locationId);

    await _deletePhoto(id, dbName);
    return 0;
  }

  /// Delete Photos based on [locationId]
  @override
  Future<void> deletePhotosByLocationId({
    required String locationId,
  }) async {
    final ids = await getPhotoIdsByLocation(locationId);

    for (final id in ids) {
      await markPhotoDeleted(id: id, locationId: locationId);
    }
  }

  /// Sets synced
  @override
  Future<void> setSynced({required String id, required String dbName}) =>
      _coreLocalStorage.setSynced(PhotoTable.tableName, id, dbName);

  /// Close the [_photoUpdatesStreamController]
  @override
  Future<void> close() {
    return _photoUpdatesStreamController.close();
  }
}
