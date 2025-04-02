import 'package:core_database_service/core_database_service.dart';
import 'package:rxdart/subjects.dart';
import 'package:sqflite/sqflite.dart';
import 'package:user_api/user_api.dart';
import 'package:user_database_service/user_database_service.dart';

/// {@template user_database_service}
/// A flutter implementation of the user UserDatabaseService that uses
/// CoreDatabaseService and sqflite.
/// {@endtemplate}
class UserDatabaseService extends UserApi {
  /// {@macro user_database_service}
  UserDatabaseService({required CoreDatabaseService coreDatabaseService})
      : _coreDatabaseService = coreDatabaseService {
    // Register the table with the core database
    _coreDatabaseService
      ..registerTable(UserTable.createTable)
      ..registerMigration(_migrateUserTable);

    _init();
  }

  late final CoreDatabaseService _coreDatabaseService;
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
    final usersJson = await _coreDatabaseService.getAll(UserTable.tableName);
    final users = usersJson
        .map((user) => User.fromJson(Map<String, dynamic>.from(user)))
        .toList();
    _userStreamController.add(users);
  }

  /// Get the `user`s from the [_userStreamController]
  @override
  Stream<List<User>> getUsers() => _userStreamController.asBroadcastStream();

  /// Insert or Update a `user` to the database based on [userData]
  Future<int> _insertOrUpdateUser(Map<String, dynamic> userData) async {
    return _coreDatabaseService.insertOrUpdate(UserTable.tableName, userData);
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
  Future<int> _deleteUser(int id) async {
    return _coreDatabaseService.delete(UserTable.tableName, id);
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

  /// Close the [_userStreamController]
  @override
  Future<void> close() {
    return _userStreamController.close();
  }
}
