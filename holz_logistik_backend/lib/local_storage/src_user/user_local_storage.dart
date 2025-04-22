import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/user_local_storage.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';

/// {@template user_local_storage}
/// A flutter implementation of the user UserLocalStorage that uses
/// CoreLocalStorage and sqflite.
/// {@endtemplate}
class UserLocalStorage extends UserApi {
  /// {@macro user_local_storage}
  UserLocalStorage({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    // Register the table with the core database
    _coreLocalStorage
      ..registerTable(UserTable.createTable)
      ..registerMigration(_migrateUserTable);

    _init();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _userStreamController = BehaviorSubject<Map<String, User>>.seeded(
    const {},
  );

  late final Stream<Map<String, User>> _users = _userStreamController.stream;

  static const _syncToServerKey = '__user_sync_to_server_date_key__';
  static const _syncFromServerKey = '__user_sync_from_server_date_key__';

  /// Migration function for user table
  Future<void> _migrateUserTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Initialization
  Future<void> _init() async {
    final usersJson = await _coreLocalStorage.getAll(UserTable.tableName);
    final users = <String, User>{};

    for (final userJson in usersJson) {
      final user = User.fromJson(userJson);

      users[user.id] = user;
    }

    _userStreamController.add(users);
  }

  @override
  Stream<Map<String, User>> get users => _users;

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

  /// Gets user updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() async {
    final db = await _coreLocalStorage.database;
    final date = await getLastSyncDate('toServer');

    final result = await db.query(
      UserTable.tableName,
      where: '${UserTable.columnLastEdit} >= ? ORDER BY '
          '${UserTable.columnLastEdit} ASC',
      whereArgs: [
        date.toIso8601String(),
      ],
    );

    return result;
  }

  /// Insert or Update a `user` to the database based on [userData]
  Future<int> _insertOrUpdateUser(Map<String, dynamic> userData) async {
    return _coreLocalStorage.insertOrUpdate(UserTable.tableName, userData);
  }

  /// Insert or Update a [user]
  @override
  Future<int> saveUser(User user) async {
    if(user.name == '') return 0;

    final result = await _insertOrUpdateUser(user.toJson());
    final users = Map<String, User>.from(_userStreamController.value);

    users[user.id] = user;
    _userStreamController.add(users);

    return result;
  }

  /// Delete a User from the database based on [id]
  Future<int> _deleteUser(String id) async {
    return _coreLocalStorage.delete(UserTable.tableName, id);
  }

  /// Delete a User based on [id]
  @override
  Future<int> deleteUser(String id) async {
    final result = await _deleteUser(id);
    final users = Map<String, User>.from(_userStreamController.value)
      ..removeWhere((key, _) => key == id);

    _userStreamController.add(users);

    return result;
  }

  /// Close the [_userStreamController]
  @override
  Future<void> close() {
    return _userStreamController.close();
  }
}
