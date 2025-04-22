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
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _sawmillStreamController =
      BehaviorSubject<Map<String, Sawmill>>.seeded(
    const {},
  );

  late final Stream<Map<String, Sawmill>> _sawmills =
      _sawmillStreamController.stream;

  static const _syncToServerKey = '__sawmill_sync_to_server_date_key__';
  static const _syncFromServerKey = '__sawmill_sync_from_server_date_key__';

  /// Migration function for sawmill table
  Future<void> _migrateSawmillTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Initialization
  Future<void> _init() async {
    final sawmillsJson = await _coreLocalStorage.getAll(SawmillTable.tableName);

    final sawmills = <String, Sawmill>{};
    for (final sawmillJson in sawmillsJson) {
      final sawmill = Sawmill.fromJson(sawmillJson);
      sawmills[sawmill.id] = sawmill;
    }

    _sawmillStreamController.add(sawmills);
  }

  @override
  Stream<Map<String, Sawmill>> get sawmills => _sawmills;

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

  /// Gets sawmill updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() async {
    final db = await _coreLocalStorage.database;
    final date = await getLastSyncDate('toServer');

    final result = await db.query(
      SawmillTable.tableName,
      where: '${SawmillTable.columnLastEdit} >= ? ORDER BY '
          '${SawmillTable.columnLastEdit} ASC',
      whereArgs: [
        date.toIso8601String(),
      ],
    );

    return result;
  }

  /// Insert or Update a `sawmill` to the database based on [sawmillData]
  Future<int> _insertOrUpdateSawmill(Map<String, dynamic> sawmillData) async {
    return _coreLocalStorage.insertOrUpdate(
      SawmillTable.tableName,
      sawmillData,
    );
  }

  /// Insert or Update a [sawmill]
  @override
  Future<int> saveSawmill(Sawmill sawmill) async {
    final result = await _insertOrUpdateSawmill(sawmill.toJson());
    final sawmills = Map<String, Sawmill>.from(_sawmillStreamController.value);

    sawmills[sawmill.id] = sawmill;
    _sawmillStreamController.add(sawmills);

    return result;
  }

  /// Delete a Sawmill from the database based on [id]
  Future<int> _deleteSawmill(String id) async {
    return _coreLocalStorage.delete(SawmillTable.tableName, id);
  }

  /// Delete a Sawmill based on [id]
  @override
  Future<int> deleteSawmill(String id) async {
    final result = await _deleteSawmill(id);
    final sawmills =
        Map<String, Sawmill>.from(_sawmillStreamController.value)
          ..removeWhere((key, _) => key == id);

    _sawmillStreamController.add(sawmills);

    return result;
  }

  /// Close the [_sawmillStreamController]
  @override
  Future<void> close() {
    return _sawmillStreamController.close();
  }
}
