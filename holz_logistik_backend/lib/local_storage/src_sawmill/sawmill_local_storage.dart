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
  Future<DateTime> getLastSyncDate() =>
      _coreLocalStorage.getLastSyncDate(_syncFromServerKey);

  /// Sets the last sync date
  @override
  Future<void> setLastSyncDate(DateTime date) =>
      _coreLocalStorage.setLastSyncDate(_syncFromServerKey, date);

  /// Gets unsynced updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() =>
      _coreLocalStorage.getUpdates(SawmillTable.tableName);

  /// Insert or Update a `sawmill` to the database based on [sawmillData]
  Future<int> _insertOrUpdateSawmill(Map<String, dynamic> sawmillData) async {
    return _coreLocalStorage.insertOrUpdate(
      SawmillTable.tableName,
      sawmillData,
    );
  }

  /// Insert or Update a [sawmill]
  @override
  Future<int> saveSawmill(Sawmill sawmill, {bool fromServer = false}) async {
    final json = sawmill.toJson();

    if (fromServer) {
      json['synced'] = 1;
    } else {
      json['synced'] = 0;
      json['lastEdit'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    }

    final result = await _insertOrUpdateSawmill(json);
    final sawmills = Map<String, Sawmill>.from(_sawmillStreamController.value);

    sawmills[sawmill.id] = sawmill;
    _sawmillStreamController.add(sawmills);

    return result;
  }

  /// Delete a Sawmill from the database based on [id]
  Future<void> _deleteSawmill(String id) async {
    await _coreLocalStorage.delete(SawmillTable.tableName, id);
  }

  /// Delete a Sawmill based on [id]
  @override
  Future<void> markSawmillDeleted({required String id}) async {
    final resultList =
        await _coreLocalStorage.getById(SawmillTable.tableName, id);

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
  Future<void> deleteSawmill({required String id}) async {
    final result = await _coreLocalStorage.getById(SawmillTable.tableName, id);

    if (result.isEmpty) return Future<void>.value();

    await _deleteSawmill(id);

    final sawmills = Map<String, Sawmill>.from(_sawmillStreamController.value)
      ..removeWhere((key, _) => key == id);

    _sawmillStreamController.add(sawmills);
  }

  /// Sets synced
  @override
  Future<void> setSynced({required String id}) =>
      _coreLocalStorage.setSynced(SawmillTable.tableName, id);

  /// Close the [_sawmillStreamController]
  @override
  Future<void> close() {
    return _sawmillStreamController.close();
  }
}
