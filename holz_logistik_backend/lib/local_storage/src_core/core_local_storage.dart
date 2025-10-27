import 'dart:async';

import 'package:holz_logistik_backend/local_storage/local_storage.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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

  /// Mutex to prevent concurrent database operations during switches
  Completer<void>? _currentOperation;

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

  /// Gets active dbName for server sync
  String get dbName => _currentDatabaseId ?? '';

  /// Acquire lock for database operations
  Future<void> _acquireLock() async {
    while (_currentOperation != null) {
      await _currentOperation!.future;
    }
    _currentOperation = Completer<void>();
  }

  /// Release lock after database operations
  void _releaseLock() {
    if (_currentOperation != null && !_currentOperation!.isCompleted) {
      _currentOperation!.complete();
      _currentOperation = null;
    }
  }

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
  Future<void> switchDatabase(String databaseId) async {
    await _acquireLock();
    try {
      if (_currentDatabaseId == databaseId) {
        return;
      }
      _currentDatabaseId = databaseId;

      if (_databases[databaseId] == null) {
        _databases[databaseId] = await _initDatabase(databaseId);
      }
      _databaseSwitchController.add(databaseId);
    } finally {
      _releaseLock();
    }
  }

  /// Get list of available database IDs
  List<String> getAvailableDatabases() {
    return _databases.keys.toList();
  }

  /// Close a specific database
  Future<void> closeDatabase(String databaseId) async {
    await _acquireLock();
    try {
      if (_databases[databaseId] != null) {
        await _databases[databaseId]!.close();
        _databases.remove(databaseId);

        if (_currentDatabaseId == databaseId) {
          _currentDatabaseId = null;
        }
      }
    } finally {
      _releaseLock();
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

    if (oldVersion < 5 && newVersion >= 5) {
      await _updateContractValues(db);
    }
  }

  /// Update contract values during migration to version 5
  Future<void> _updateContractValues(Database db) async {
    final contractsJson = await db.query(
      ContractTable.tableName,
      where: 'deleted = 0',
    );

    for (final contractJson in contractsJson) {
      final locationsJson = await db.query(
        LocationTable.tableName,
        where: '${LocationTable.columnContractId} = ? AND deleted = 0',
        whereArgs: [contractJson[ContractTable.columnId]],
      );

      final shipmentsJson = await db.query(
        ShipmentTable.tableName,
        where: '${ShipmentTable.columnContractId} = ? AND deleted = 0',
        whereArgs: [contractJson[ContractTable.columnId]],
      );

      double bookedQuantity = 0;
      double shippedQuantity = 0;

      for (final locationJson in locationsJson) {
        bookedQuantity +=
            locationJson[LocationTable.columnInitialQuantity]! as double;
      }

      for (final shipmentJson in shipmentsJson) {
        shippedQuantity +=
            shipmentJson[ShipmentTable.columnQuantity]! as double;
      }

      final updatedContract = Map<String, dynamic>.from(contractJson);
      updatedContract[ContractTable.columnBookedQuantity] = bookedQuantity;
      updatedContract[ContractTable.columnShippedQuantity] = shippedQuantity;
      updatedContract[ContractTable.columnLastEdit] =
          DateTime.now().toUtc().millisecondsSinceEpoch;
      updatedContract['synced'] = 0;

      await db.update(
        ContractTable.tableName,
        updatedContract,
        where: '${ContractTable.columnId} = ?',
        whereArgs: [updatedContract[ContractTable.columnId]],
      );
    }
  }

  /// Initialize a database with the given ID
  Future<Database> _initDatabase(String databaseId) async {
    final dbName = databaseId == 'draexl' ? 'holz_logistik' : databaseId;
    final path = join(await getDatabasesPath(), '$dbName.db');

    return openDatabase(
      path,
      version: 5,
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
    await _acquireLock();
    try {
      for (final db in _databases.values) {
        await db.close();
      }
      _databases.clear();
      _currentDatabaseId = null;
      await _databaseSwitchController.close();
    } finally {
      _releaseLock();
    }
  }

  /// Close the current database
  Future<void> close() async {
    if (_currentDatabaseId != null) {
      await closeDatabase(_currentDatabaseId!);
    }
  }

  /// Gets all entities of [tableName]
  Future<List<Map<String, dynamic>>> getAll(String tableName) async {
    await _acquireLock();
    try {
      final db = await database;
      return db.query(
        tableName,
        where: 'deleted = 0',
      );
    } finally {
      _releaseLock();
    }
  }

  /// Gets entity of [tableName] by [id]
  Future<List<Map<String, dynamic>>> getById(
    String tableName,
    String id,
  ) async {
    await _acquireLock();
    try {
      final db = await database;
      return db.query(
        tableName,
        where: 'deleted = 0 AND id = ?',
        whereArgs: [id],
      );
    } finally {
      _releaseLock();
    }
  }

  /// Gets entity of [tableName] by [id]
  Future<List<Map<String, dynamic>>> getByIdForDeletion(
    String tableName,
    String id,
  ) async {
    await _acquireLock();
    try {
      final db = await database;
      return db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } finally {
      _releaseLock();
    }
  }

  /// Gets entities of table [tableName] based on [id] of [columnName]
  Future<List<Map<String, dynamic>>> getByColumn(
    String tableName,
    String columnName,
    String id,
  ) async {
    await _acquireLock();
    try {
      final db = await database;

      return db.query(
        tableName,
        where: 'deleted = 0 AND $columnName = ?',
        whereArgs: [id],
      );
    } finally {
      _releaseLock();
    }
  }

  /// Inserts [data] into [tableName]
  Future<int> insert(
    String tableName,
    Map<String, dynamic> data, {
    String? dbName,
  }) async {
    await _acquireLock();
    if (dbName != null && dbName != _currentDatabaseId) return 0;

    try {
      final db = await database;
      return db.insert(
        tableName,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } finally {
      _releaseLock();
    }
  }

  /// Updates entity of table [tableName] based on [data]
  Future<int> update(
    String tableName,
    Map<String, dynamic> data, {
    String? dbName,
  }) async {
    await _acquireLock();
    if (dbName != null && dbName != _currentDatabaseId) return 0;

    try {
      final db = await database;
      return db.update(
        tableName,
        data,
        where: 'id = ?',
        whereArgs: [data['id']],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } finally {
      _releaseLock();
    }
  }

  /// Inserts or Updates entity of table [tableName] based on [data]
  Future<int> insertOrUpdate(
    String tableName,
    Map<String, dynamic> data, {
    String? dbName,
  }) async {
    await _acquireLock();
    if (dbName != null && dbName != _currentDatabaseId) return 0;

    try {
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

        return update(tableName, data, dbName: dbName);
      }

      return insert(tableName, data, dbName: dbName);
    } finally {
      _releaseLock();
    }
  }

  /// Deletes entity of table [tableName] based on [id] of [columnName]
  Future<int> deleteByColumn(
    String tableName,
    String columnName,
    String id, {
    String? dbName,
  }) async {
    await _acquireLock();
    if (dbName != null && dbName != _currentDatabaseId) return 0;

    try {
      final db = await database;

      return db.delete(
        tableName,
        where: '$columnName = ?',
        whereArgs: [id],
      );
    } finally {
      _releaseLock();
    }
  }

  /// Deletes entity of table [tableName] based on [id]
  Future<int> delete(String tableName, String id, String dbName) async {
    await _acquireLock();
    if (dbName != _currentDatabaseId) return 0;

    try {
      final db = await database;
      return db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    } finally {
      _releaseLock();
    }
  }

  /// Provides the last sync date
  Future<DateTime> getLastSyncDate(String key) async {
    final prefs = await sharedPreferences;
    final accessKey = _currentDatabaseId == 'draexl'
        ? key
        : (key + (_currentDatabaseId ?? '_'));

    final dateMillis = prefs.getInt(accessKey);
    final date = dateMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(dateMillis, isUtc: true)
        : DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

    return date;
  }

  /// Sets the last sync date
  Future<void> setLastSyncDate(String dbName, String key, DateTime date) async {
    if (dbName != _currentDatabaseId) return;

    final prefs = await sharedPreferences;
    final accessKey = _currentDatabaseId == 'draexl'
        ? key
        : (key + (_currentDatabaseId ?? '_'));
    final dateInt = date.millisecondsSinceEpoch;
    final lastDate = await getLastSyncDate(key);

    if (dateInt > lastDate.millisecondsSinceEpoch) {
      await prefs.setInt(accessKey, dateInt);
    }
  }

  /// Gets unsynced updates
  Future<List<Map<String, dynamic>>> getUpdates(String tableName) async {
    await _acquireLock();
    try {
      final db = await database;

      final result = await db.query(
        tableName,
        where: 'synced = 0 ORDER BY lastEdit ASC',
      );

      return result;
    } finally {
      _releaseLock();
    }
  }

  /// Sets as synced
  Future<void> setSynced(String tableName, String id, String dbName) async {
    await _acquireLock();
    if (dbName != _currentDatabaseId) return;

    try {
      final db = await database;

      final result =
          await db.query(tableName, where: 'id = ?', whereArgs: [id]);

      if (result.isNotEmpty) {
        await db.update(
          tableName,
          {'synced': 1},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    } finally {
      _releaseLock();
    }
  }

  /// Checks if server update is newer
  Future<bool> isNewer(String tableName, DateTime lastEdit, String id) async {
    await _acquireLock();
    try {
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
    } finally {
      _releaseLock();
    }
  }

  /// Checks if the user should be updated
  Future<bool> userNeedsUpdate(
    String tableName,
    DateTime lastEdit,
    String id,
    int role,
  ) async {
    await _acquireLock();
    try {
      final db = await database;

      final result = await db.query(
        tableName,
        columns: ['lastEdit'],
        where: 'id = ? AND role != ?',
        whereArgs: [id, role],
      );

      var userNeedsUpdate = true;
      if (result.isNotEmpty) {
        final oldLastEdit = result.first['lastEdit']! as int;

        if (oldLastEdit >= lastEdit.millisecondsSinceEpoch) {
          userNeedsUpdate = false;
        }
      }

      return userNeedsUpdate;
    } finally {
      _releaseLock();
    }
  }
}
