import 'dart:async';

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
    _listenToDatabaseSwitches();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _userStreamController = BehaviorSubject<Map<String, User>>.seeded(
    const {},
  );

  late final Stream<Map<String, User>> _users = _userStreamController.stream;

  static const _syncFromServerKey = '__user_sync_from_server_date_key__';

  // Subscription to database switch events
  StreamSubscription<String>? _databaseSwitchSubscription;

  /// Migration function for user table
  Future<void> _migrateUserTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Listen to database switch events and reload caches
  void _listenToDatabaseSwitches() {
    _databaseSwitchSubscription = _coreLocalStorage.onDatabaseSwitch.listen(
      (newDatabaseId) async {
        await _reloadCaches();
      },
    );
  }

  /// Reload all caches after database switch
  Future<void> _reloadCaches() async {
    try {
      _userStreamController.add(const {});
      final users = await _getAllUsers();
      _userStreamController.add(users);
    } catch (e) {
      _userStreamController.add(const {});
    }
  }

  /// Initialization
  Future<void> _init() async {
    final users = await _getAllUsers();
    _userStreamController.add(users);
  }

  /// Get all users from current database
  Future<Map<String, User>> _getAllUsers() async {
    final usersJson = await _coreLocalStorage.getAll(UserTable.tableName);
    final users = <String, User>{};

    for (final userJson in usersJson) {
      final user = User.fromJson(userJson);
      users[user.id] = user;
    }

    return users;
  }

  @override
  Stream<Map<String, User>> get users => _users;

  @override
  String get dbName => _coreLocalStorage.dbName;

  /// Provides the last sync date
  @override
  Future<DateTime> getLastSyncDate() =>
      _coreLocalStorage.getLastSyncDate(_syncFromServerKey);

  /// Sets the last sync date
  @override
  Future<void> setLastSyncDate(String dbName, DateTime date) =>
      _coreLocalStorage.setLastSyncDate(dbName, _syncFromServerKey, date);

  /// Gets unsynced updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() =>
      _coreLocalStorage.getUpdates(UserTable.tableName);

  /// Insert or Update a `user` to the database based on [userData]
  Future<int> _insertOrUpdateUser(
    Map<String, dynamic> userData, {
    String? dbName,
  }) async {
    return _coreLocalStorage.insertOrUpdate(
      UserTable.tableName,
      userData,
      dbName: dbName,
    );
  }

  /// Insert or Update a [user]
  @override
  Future<int> saveUser(
    User user, {
    bool fromServer = false,
    String? dbName,
  }) async {
    if (user.name == '') return 0;
    final userJson = user.toJson();

    if (fromServer) {
      userJson['synced'] = 1;
    } else {
      userJson['synced'] = 0;
      userJson['lastEdit'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    }

    final doNotSkipUser = await _coreLocalStorage.userNeedsUpdate(
      UserTable.tableName,
      user.lastEdit,
      user.id,
      userJson['role'] as int,
    );

    if (!doNotSkipUser) return 0;

    final result = await _insertOrUpdateUser(userJson, dbName: dbName);
    final users = Map<String, User>.from(_userStreamController.value);

    users[user.id] = user;
    _userStreamController.add(users);

    return result;
  }

  /// Delete a User from the database based on [id]
  Future<int> _deleteUser(String id, String dbName) async {
    return _coreLocalStorage.delete(UserTable.tableName, id, dbName);
  }

  /// Marks a User deleted based on [id]
  @override
  Future<void> markUserDeleted({required String id}) async {
    final resultList =
        await _coreLocalStorage.getByIdForDeletion(UserTable.tableName, id);

    if (resultList.isEmpty) return Future<void>.value();

    final json = Map<String, dynamic>.from(resultList.first);
    json['deleted'] = 1;
    json['synced'] = 0;
    await _insertOrUpdateUser(json);

    final users = Map<String, User>.from(_userStreamController.value)
      ..removeWhere((key, _) => key == id);

    _userStreamController.add(users);
  }

  /// Delete a User based on [id]
  @override
  Future<int> deleteUser({required String id, required String dbName}) async {
    final result =
        await _coreLocalStorage.getByIdForDeletion(UserTable.tableName, id);

    if (result.isEmpty) return 0;

    await _deleteUser(id, dbName);

    final users = Map<String, User>.from(_userStreamController.value)
      ..removeWhere((key, _) => key == id);

    _userStreamController.add(users);

    return 0;
  }

  /// Sets synced
  @override
  Future<void> setSynced({required String id, required String dbName}) =>
      _coreLocalStorage.setSynced(UserTable.tableName, id, dbName);

  /// Close the [_userStreamController]
  @override
  Future<void> close() {
    _databaseSwitchSubscription?.cancel();
    return _userStreamController.close();
  }
}
