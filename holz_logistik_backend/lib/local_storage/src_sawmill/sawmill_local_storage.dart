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
  Stream<List<Sawmill>> get sawmills =>
      _sawmillStreamController.asBroadcastStream();

  @override
  List<Sawmill> get currentSawmills => _sawmillStreamController.value;

  /// Insert or Update a `sawmill` to the database based on [sawmillData]
  Future<int> _insertOrUpdateSawmill(Map<String, dynamic> sawmillData) async {
    return _coreLocalStorage.insertOrUpdate(
      SawmillTable.tableName,
      sawmillData,
    );
  }

  /// Insert or Update a [sawmill]
  @override
  Future<int> saveSawmill(Sawmill sawmill) {
    final sawmills = [..._sawmillStreamController.value];
    final sawmillIndex = sawmills.indexWhere((s) => s.id == sawmill.id);
    if (sawmillIndex >= 0) {
      sawmills[sawmillIndex] = sawmill;
    } else {
      sawmills.add(sawmill);
    }

    _sawmillStreamController.add(sawmills);
    return _insertOrUpdateSawmill(sawmill.toJson());
  }

  /// Delete a Sawmill from the database based on [id]
  Future<int> _deleteSawmill(String id) async {
    return _coreLocalStorage.delete(SawmillTable.tableName, id);
  }

  /// Delete a Sawmill based on [id]
  @override
  Future<int> deleteSawmill(String id) async {
    final sawmills = [..._sawmillStreamController.value];
    final sawmillIndex = sawmills.indexWhere((s) => s.id == id);

    sawmills.removeAt(sawmillIndex);
    _sawmillStreamController.add(sawmills);
    return _deleteSawmill(id);
  }

  /// Close the [_sawmillStreamController]
  @override
  Future<void> close() {
    return _sawmillStreamController.close();
  }
}
