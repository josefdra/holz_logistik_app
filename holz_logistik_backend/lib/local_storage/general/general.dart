import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/general/tables/tables.dart';
import 'package:sqflite/sqflite.dart';

/// {@template general_tables}
/// A flutter implementation of the general junction tables that uses
/// CoreLocalStorage and sqflite.
/// {@endtemplate}
class GeneralTables {
  /// {@macro general_tables}
  GeneralTables({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    // Register the table with the core database
    _coreLocalStorage
      ..registerTable(LocationSawmillJunctionTable.createTable)
      ..registerMigration(_migrateLocationSawmillTable);
  }

  final CoreLocalStorage _coreLocalStorage;

  /// Migration function for location table
  Future<void> _migrateLocationSawmillTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }
}
