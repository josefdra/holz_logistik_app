import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// {@template core_database_service}
/// A flutter package that handles core database operations.
/// {@endtemplate}
class CoreDatabase {
  /// Factory constructor
  factory CoreDatabase() {
    return _instance;
  }

  /// Constructor for testing
  @visibleForTesting
  CoreDatabase.test({Database? database}) {
    if (database != null) _database = database;
  }

  /// Private constructor
  CoreDatabase._internal();

  static final CoreDatabase _instance = CoreDatabase._internal();
  static Database? _database;

  /// Map of table creation functions registered by feature packages
  final List<String> _tableCreationScripts = [];

  /// Getter for testing tableCreationScript
  @visibleForTesting
  List<String> get tableCreationScriptsForTest => _tableCreationScripts;

  /// List of migration functions registered by feature packages
  final List<FutureOr<void> Function(Database, int, int)> _migrationCallbacks =
      [];

  /// Getter for testing migrationCallbacks
  @visibleForTesting
  List<Function> get migrationCallbacksForTest => _migrationCallbacks;

  /// Get the database instance, initializing if needed
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Create tables when database is first created
  Future<void> _onCreate(Database db, int version) async {
    for (final script in _tableCreationScripts) {
      await db.execute(script);
    }
  }

  /// _onCreate for testing
  @visibleForTesting
  Future<void> onCreate(Database db, int version) => _onCreate(db, version);

  /// Handle database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (final migration in _migrationCallbacks) {
      await migration(db, oldVersion, newVersion);
    }
  }

  /// _onUpgrade for testing
  @visibleForTesting
  Future<void> onUpgrade(Database db, int oldVersion, int newVersion) =>
      _onUpgrade(db, oldVersion, newVersion);

  /// Initialize the database
  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'holz_logistik.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Register a table creation script from a feature package
  void registerTable(String creationScript) {
    _tableCreationScripts.add(creationScript);
  }

  /// Register a migration callback from a feature package
  void registerMigration(
    FutureOr<void> Function(Database, int, int) migrationCallback,
  ) {
    _migrationCallbacks.add(migrationCallback);
  }

  /// Close the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Inserts [data] into [tableName]
  Future<int> insert(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(
      tableName,
      data,
    );
  }

  /// Updates entity of table [tableName] based on [data]
  Future<int> update(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return db.update(
      tableName,
      data,
      where: 'id = ?',
      whereArgs: [data['id']],
    );
  }

  /// Inserts or Updates entity of table [tableName] based on [data]
  Future<int> insertOrUpdate(
    String tableName,
    Map<String, dynamic> data,
  ) async {
    final db = await database;

    final List<Map<String, dynamic>> existing = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [data['id']],
    );

    if (existing.isNotEmpty) {
      return update(tableName, data);
    }

    return insert(tableName, data);
  }

  /// Deletes entity of table [tableName] based on [id]
  Future<int> delete(String tableName, int id) async {
    final db = await database;
    return db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
