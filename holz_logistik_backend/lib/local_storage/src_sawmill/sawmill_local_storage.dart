import 'dart:async';

import 'package:holz_logistik_backend/api/sawmill_api.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/sawmill_local_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

/// {@template sawmill_local_storage}
/// A flutter implementation of the sawmill SawmillLocalStorage that uses
/// CoreLocalStorage and sqflite.
/// {@endtemplate}
class SawmillLocalStorage extends SawmillApi {
  /// {@macro sawmill_local_storage}
  SawmillLocalStorage({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    // Register the table with the core database
    _coreLocalStorage
      ..registerTable(SawmillTable.createTable)
      ..registerMigration(_migrateSawmillTable);

    _init();
    _listenToDatabaseSwitches();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _sawmillStreamController =
      BehaviorSubject<Map<String, Sawmill>>.seeded(
    const {},
  );

  late final Stream<Map<String, Sawmill>> _sawmills =
      _sawmillStreamController.stream;

  static const _syncFromServerKey = '__sawmill_sync_from_server_date_key__';

  // Subscription to database switch events
  StreamSubscription<String>? _databaseSwitchSubscription;

  /// Migration function for sawmill table
  Future<void> _migrateSawmillTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
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
      _sawmillStreamController.add(const {});
      final sawmills = await _getAllSawmills();
      _sawmillStreamController.add(sawmills);
    } catch (e) {
      _sawmillStreamController.add(const {});
    }
  }

  /// Initialization
  Future<void> _init() async {
    final sawmills = await _getAllSawmills();
    _sawmillStreamController.add(sawmills);
  }

  /// Get all sawmills from current database
  Future<Map<String, Sawmill>> _getAllSawmills() async {
    final sawmillsJson = await _coreLocalStorage.getAll(SawmillTable.tableName);

    final sawmills = <String, Sawmill>{};
    for (final sawmillJson in sawmillsJson) {
      final sawmill = Sawmill.fromJson(sawmillJson);
      sawmills[sawmill.id] = sawmill;
    }

    return sawmills;
  }

  @override
  Stream<Map<String, Sawmill>> get sawmills => _sawmills;

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
      _coreLocalStorage.getUpdates(SawmillTable.tableName);

  /// Insert or Update a `sawmill` to the database based on [sawmillData]
  Future<int> _insertOrUpdateSawmill(
    Map<String, dynamic> sawmillData, {
    String? dbName,
  }) async {
    return _coreLocalStorage.insertOrUpdate(
      SawmillTable.tableName,
      sawmillData,
      dbName: dbName,
    );
  }

  /// Insert or Update a [sawmill]
  @override
  Future<int> saveSawmill(
    Sawmill sawmill, {
    bool fromServer = false,
    String? dbName,
  }) async {
    final json = sawmill.toJson();

    if (fromServer) {
      if (!(await _coreLocalStorage.isNewer(
        SawmillTable.tableName,
        sawmill.lastEdit,
        sawmill.id,
      ))) {
        return 0;
      }

      json['synced'] = 1;
    } else {
      json['synced'] = 0;
      json['lastEdit'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    }

    final result = await _insertOrUpdateSawmill(json, dbName: dbName);
    final sawmills = Map<String, Sawmill>.from(_sawmillStreamController.value);

    sawmills[sawmill.id] = sawmill;
    _sawmillStreamController.add(sawmills);

    return result;
  }

  /// Delete a Sawmill from the database based on [id]
  Future<void> _deleteSawmill(String id, String dbName) async {
    await _coreLocalStorage.delete(SawmillTable.tableName, id, dbName);
  }

  /// Delete a Sawmill based on [id]
  @override
  Future<void> markSawmillDeleted({required String id}) async {
    final resultList =
        await _coreLocalStorage.getByIdForDeletion(SawmillTable.tableName, id);

    if (resultList.isEmpty) return Future<void>.value();

    final json = Map<String, dynamic>.from(resultList.first);
    json['deleted'] = 1;
    json['synced'] = 0;
    await _insertOrUpdateSawmill(json);

    final sawmills = Map<String, Sawmill>.from(_sawmillStreamController.value)
      ..removeWhere((key, _) => key == id);

    _sawmillStreamController.add(sawmills);
  }

  /// Delete a Sawmill based on [id]
  @override
  Future<void> deleteSawmill({
    required String id,
    required String dbName,
  }) async {
    final result =
        await _coreLocalStorage.getByIdForDeletion(SawmillTable.tableName, id);

    if (result.isEmpty) return Future<void>.value();

    await _deleteSawmill(id, dbName);

    final sawmills = Map<String, Sawmill>.from(_sawmillStreamController.value)
      ..removeWhere((key, _) => key == id);

    _sawmillStreamController.add(sawmills);
  }

  /// Sets synced
  @override
  Future<void> setSynced({required String id, required String dbName}) =>
      _coreLocalStorage.setSynced(SawmillTable.tableName, id, dbName);

  /// Close the [_sawmillStreamController]
  @override
  Future<void> close() {
    _databaseSwitchSubscription?.cancel();
    return _sawmillStreamController.close();
  }
}
