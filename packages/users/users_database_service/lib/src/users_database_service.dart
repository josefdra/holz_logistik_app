import 'package:core_database_service/core_database_service.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';
import 'package:users_api/users_api.dart';
import 'package:users_database_service/users_database_service.dart';

/// {@template users_database_service}
/// A flutter implementation of the user UserDatabaseService that uses
/// CoreDatabaseService and sqflite.
/// {@endtemplate}
class UsersDatabaseService extends UsersApi {
  /// {@macro users_database_service}
  UsersDatabaseService() {
    // Register the table with the core database
    _coreDatabase
      ..registerTable(UserTable.createTable)
      ..registerMigration(_migrateUserTable);

    _init();
  }

  final CoreDatabase _coreDatabase = CoreDatabase();
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

  Future<void> _init() async {
    final usersJson = await _coreDatabase.getAll(UserTable.tableName);
    final users = usersJson
        .map((user) => User.fromJson(Map<String, dynamic>.from(user)))
        .toList();
    _userStreamController.add(users);
  }

  @override
  Stream<List<User>> getUsers() => _userStreamController.asBroadcastStream();

  Future<int> _insertOrUpdateUser(Map<String, dynamic> userData) async {
    return _coreDatabase.insertOrUpdate(UserTable.tableName, userData);
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

  Future<int> _deleteUser(int id) async {
    return _coreDatabase.delete(UserTable.tableName, id);
  }

  /// Delete a User based on [id]
  @override
  Future<int> deleteUser(int id) async {
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

  @override
  Future<void> close() {
    return _userStreamController.close();
  }
}
