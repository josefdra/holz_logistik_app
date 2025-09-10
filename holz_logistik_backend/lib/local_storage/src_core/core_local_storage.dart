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

  static const _activeDbKey = '__active_db_key__';

  static final CoreLocalStorage _instance = CoreLocalStorage._internal();
  static final Map<String, Database> _databases = {};
  static SharedPreferences? _sharedPrefs;

  String? _currentDatabaseId;

  /// Map of table creation functions registered by feature packages
  final List<String> _tableCreationScripts = [];

  /// List of migration functions registered by feature packages
  final List<FutureOr<void> Function(Database, int, int)> _migrationCallbacks =
      [];

  /// Stream controller to notify about database switches
  final StreamController<String> _databaseSwitchController =
      StreamController<String>.broadcast();

  /// Stream that notifies when database is switched
  Stream<String> get onDatabaseSwitch => _databaseSwitchController.stream;

  /// Get current database ID
  String? get currentDatabaseId => _currentDatabaseId;

  /// Get the shared preferences instance, initializing if needed
  Future<SharedPreferences> get sharedPreferences async {
    if (_sharedPrefs != null) return _sharedPrefs!;
    _sharedPrefs = await SharedPreferences.getInstance();
    return _sharedPrefs!;
  }

  /// Get the current database instance, initializing if needed
  Future<Database> get database async {
    if (_currentDatabaseId == null) {
      final prefs = await sharedPreferences;
      _currentDatabaseId = prefs.getString(_activeDbKey) ?? 'draexl';
    }
    if (_databases[_currentDatabaseId!] != null) {
      return _databases[_currentDatabaseId!]!;
    }

    _databases[_currentDatabaseId!] = await _initDatabase(_currentDatabaseId!);
    return _databases[_currentDatabaseId!]!;
  }

  /// Switch to a different database
  /// [databaseId] - unique identifier for the database
  /// [clearCaches] - whether to clear all in-memory caches (default: true)
  Future<void> switchDatabase(
    String databaseId, {
    bool clearCaches = true,
  }) async {
    if (_currentDatabaseId == databaseId) {
      return; // Already using this database
    }

    final previousDatabaseId = _currentDatabaseId;
    _currentDatabaseId = databaseId;

    // Initialize the new database if it doesn't exist
    if (_databases[databaseId] == null) {
      _databases[databaseId] = await _initDatabase(databaseId);
    }

    // Notify listeners about the database switch
    _databaseSwitchController.add(databaseId);

    print('Switched from database "$previousDatabaseId" to "$databaseId"');
  }

  /// Get list of available database IDs
  List<String> getAvailableDatabases() {
    return _databases.keys.toList();
  }

  /// Close a specific database
  Future<void> closeDatabase(String databaseId) async {
    if (_databases[databaseId] != null) {
      await _databases[databaseId]!.close();
      _databases.remove(databaseId);

      if (_currentDatabaseId == databaseId) {
        _currentDatabaseId = null;
      }
    }
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

  /// Initialize a database with the given ID
  Future<Database> _initDatabase(String databaseId) async {
    final dbName = databaseId == 'draexl' ? 'holz_logistik' : databaseId;
    final path = join(await getDatabasesPath(), '$dbName.db');

    return openDatabase(
      path,
      version: 2,
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

  /// Close all databases
  Future<void> closeAll() async {
    for (final db in _databases.values) {
      await db.close();
    }
    _databases.clear();
    _currentDatabaseId = null;
    await _databaseSwitchController.close();
  }

  /// Close the current database
  Future<void> close() async {
    if (_currentDatabaseId != null) {
      await closeDatabase(_currentDatabaseId!);
    }
  }

  /// Gets all entities of [tableName]
  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    final db = await database;
    return db.query(
      tableName,
      where: 'deleted = 0',
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
      where: 'deleted = 0 AND id = ?',
      whereArgs: [id],
    );
  }

  /// Gets entity of [tableName] by [id]
  Future<List<Map<String, dynamic>>> getByIdForDeletion(
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
      where: 'deleted = 0 AND $columnName = ?',
      whereArgs: [id],
    );
  }

  /// Inserts [data] into [tableName]
  Future<int> insert(String tableName, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(
      tableName,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
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
      conflictAlgorithm: ConflictAlgorithm.replace,
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
      final oldDate = existing.first['lastEdit'] as int;
      final newDate = data['lastEdit'] as int;

      if (oldDate > newDate) {
        return 0;
      }

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

  /// Provides the last sync date
  Future<DateTime> getLastSyncDate(String key) async {
    final prefs = await sharedPreferences;

    final dateMillis = prefs.getInt(key);
    final date = dateMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(dateMillis, isUtc: true)
        : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    return date;
  }

  /// Sets the last sync date
  Future<void> setLastSyncDate(String key, DateTime date) async {
    final prefs = await sharedPreferences;
    final dateInt = date.millisecondsSinceEpoch;
    final lastDate = await getLastSyncDate(key);

    if (dateInt > lastDate.millisecondsSinceEpoch) {
      await prefs.setInt(key, dateInt);
    }
  }

  /// Gets unsynced updates
  Future<List<Map<String, dynamic>>> getUpdates(String tableName) async {
    final db = await database;

    final result = await db.query(
      tableName,
      where: 'synced = 0 ORDER BY lastEdit ASC',
    );

    return result;
  }

  /// Sets as synced
  Future<void> setSynced(String tableName, String id) async {
    final db = await database;

    final result = await db.query(tableName, where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      await db.update(
        tableName,
        {'synced': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  /// Checks if server update is newer
  Future<bool> isNewer(String tableName, DateTime lastEdit, String id) async {
    final db = await database;

    final result = await db.query(
      tableName,
      columns: ['lastEdit'],
      where: 'id = ?',
      whereArgs: [id],
    );

    var isNewer = false;
    if (result.isNotEmpty) {
      final oldLastEdit = result.first['lastEdit']! as int;

      if (oldLastEdit < lastEdit.millisecondsSinceEpoch) isNewer = true;
    } else {
      isNewer = true;
    }

    return isNewer;
  }
}
