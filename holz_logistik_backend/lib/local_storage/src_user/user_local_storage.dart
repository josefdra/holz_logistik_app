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
  Future<DateTime> getLastSyncDate() =>
      _coreLocalStorage.getLastSyncDate(_syncFromServerKey);

  /// Sets the last sync date
  @override
  Future<void> setLastSyncDate(DateTime date) =>
      _coreLocalStorage.setLastSyncDate(_syncFromServerKey, date);

  /// Gets unsynced updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() =>
      _coreLocalStorage.getUpdates(UserTable.tableName);

  /// Insert or Update a `user` to the database based on [userData]
  Future<int> _insertOrUpdateUser(Map<String, dynamic> userData) async {
    return _coreLocalStorage.insertOrUpdate(UserTable.tableName, userData);
  }

  /// Insert or Update a [user]
  @override
  Future<int> saveUser(User user, {bool fromServer = false}) async {
    if (user.name == '') return 0;
    final json = user.toJson();

    if (fromServer) {
      if (!(await _coreLocalStorage.isNewer(
        UserTable.tableName,
        user.lastEdit,
        user.id,
      ))) {
        return 0;
      }

      json['synced'] = 1;
    } else {
      json['synced'] = 0;
      json['lastEdit'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    }

    final result = await _insertOrUpdateUser(json);
    final users = Map<String, User>.from(_userStreamController.value);

    users[user.id] = user;
    _userStreamController.add(users);

    return result;
  }

  /// Delete a User from the database based on [id]
  Future<int> _deleteUser(String id) async {
    return _coreLocalStorage.delete(UserTable.tableName, id);
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
  Future<int> deleteUser({required String id}) async {
    final result =
        await _coreLocalStorage.getByIdForDeletion(UserTable.tableName, id);

    if (result.isEmpty) return 0;

    await _deleteUser(id);

    final users = Map<String, User>.from(_userStreamController.value)
      ..removeWhere((key, _) => key == id);

    _userStreamController.add(users);

    return 0;
  }

  /// Sets synced
  @override
  Future<void> setSynced({required String id}) =>
      _coreLocalStorage.setSynced(UserTable.tableName, id);

  /// Close the [_userStreamController]
  @override
  Future<void> close() {
    return _userStreamController.close();
  }
}
