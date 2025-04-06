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
  late final _userStreamController = BehaviorSubject<List<User>>.seeded(
    const [],
  );

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
    final users = usersJson
        .map((user) => User.fromJson(Map<String, dynamic>.from(user)))
        .toList();
    _userStreamController.add(users);
  }

  /// Get the `user`s from the [_userStreamController]
  @override
  Stream<List<User>> get users => _userStreamController.asBroadcastStream();

  /// Insert or Update a `user` to the database based on [userData]
  Future<int> _insertOrUpdateUser(Map<String, dynamic> userData) async {
    return _coreLocalStorage.insertOrUpdate(UserTable.tableName, userData);
  }

  /// Insert or Update a [user]
  @override
  Future<int> saveUser(User user) {
    final users = [..._userStreamController.value];
    final userIndex = users.indexWhere((t) => t.id == user.id);
    if (userIndex >= 0) {
      users[userIndex] = user;
    } else {
      users.add(user);
    }

    _userStreamController.add(users);
    return _insertOrUpdateUser(user.toJson());
  }

  /// Delete a User from the database based on [id]
  Future<int> _deleteUser(String id) async {
    return _coreLocalStorage.delete(UserTable.tableName, id);
  }

  /// Delete a User based on [id]
  @override
  Future<int> deleteUser(String id) async {
    final users = [..._userStreamController.value];
    final userIndex = users.indexWhere((t) => t.id == id);
    if (userIndex == -1) {
      throw UserNotFoundException();
    } else {
      users.removeAt(userIndex);
      _userStreamController.add(users);
      return _deleteUser(id);
    }
  }

  /// Close the [_userStreamController]
  @override
  Future<void> close() {
    return _userStreamController.close();
  }
}
