import 'package:collection/collection.dart';
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
  late final _sawmillStreamController = BehaviorSubject<List<Sawmill>>.seeded(
    const [],
  );

  late final Stream<List<Sawmill>> _broadcastSawmills =
      _sawmillStreamController.stream;

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
    final sawmills = sawmillsJson
        .map((sawmill) => Sawmill.fromJson(Map<String, dynamic>.from(sawmill)))
        .toList();
    _sawmillStreamController.add(sawmills);
  }

  @override
  Stream<List<Sawmill>> get sawmills => _broadcastSawmills;

  @override
  Future<Sawmill> getSawmillById(String id) async {
    final sawmills = [..._sawmillStreamController.value];
    final sawmill = sawmills.firstWhereOrNull((s) => s.id == id);

    if (sawmill != null) {
      return sawmill;
    }

    final result = await _coreLocalStorage.getById(SawmillTable.tableName, id);

    return Sawmill.fromJson(result.first);
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
    final sawmills = [..._sawmillStreamController.value];
    final sawmillIndex = sawmills.indexWhere((s) => s.id == sawmill.id);
    if (sawmillIndex > -1) {
      sawmills[sawmillIndex] = sawmill;
    } else {
      sawmills.add(sawmill);
    }

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
    final sawmills = [..._sawmillStreamController.value];
    final sawmillIndex = sawmills.indexWhere((s) => s.id == id);

    sawmills.removeAt(sawmillIndex);
    _sawmillStreamController.add(sawmills);
    return result;
  }

  /// Close the [_sawmillStreamController]
  @override
  Future<void> close() {
    return _sawmillStreamController.close();
  }
}
