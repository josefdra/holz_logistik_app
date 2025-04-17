import 'dart:async';

import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// {@template core_local_storage}
/// A flutter package that handles core database operations.
/// {@endtemplate}
class CoreLocalStorage {
  /// Factory constructor
  factory CoreLocalStorage() {
    return _instance;
  }

  /// Private constructor
  CoreLocalStorage._internal();

  static final CoreLocalStorage _instance = CoreLocalStorage._internal();
  static Database? _database;
  static SharedPreferences? _sharedPrefs;

  /// Map of table creation functions registered by feature packages
  final List<String> _tableCreationScripts = [];

  /// List of migration functions registered by feature packages
  final List<FutureOr<void> Function(Database, int, int)> _migrationCallbacks =
      [];

  /// Get the shared preferences instance, initializing if needed
  Future<SharedPreferences> get sharedPreferences async {
    if (_sharedPrefs != null) return _sharedPrefs!;
    _sharedPrefs = await SharedPreferences.getInstance();
    return _sharedPrefs!;
  }

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

  /// Handle database migrations
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    for (final migration in _migrationCallbacks) {
      await migration(db, oldVersion, newVersion);
    }
  }

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

  /// Gets all entities of [tableName]
  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    final db = await database;
    return db.query(
      tableName,
    );
  }

  /// Gets entity of [tableName] by [id]
  Future<List<Map<String, dynamic>>> getById(
    String tableName,
    String id,
  ) async {
    final db = await database;
    return db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Gets entities of table [tableName] based on [id] of [columnName]
  Future<List<Map<String, dynamic>>> getByColumn(
    String tableName,
    String columnName,
    String id,
  ) async {
    final db = await database;
    
    return db.query(
      tableName,
      where: '$columnName = ?',
      whereArgs: [id],
    );
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

  /// Deletes entity of table [tableName] based on [id] of [columnName]
  Future<int> deleteByColumn(
    String tableName,
    String columnName,
    String id,
  ) async {
    final db = await database;
    
    return db.delete(
      tableName,
      where: '$columnName = ?',
      whereArgs: [id],
    );
  }

  /// Deletes entity of table [tableName] based on [id]
  Future<int> delete(String tableName, String id) async {
    final db = await database;
    return db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
