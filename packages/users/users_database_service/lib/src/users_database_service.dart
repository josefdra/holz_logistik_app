import 'package:core_database_service/core_database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:users_database_service/users_database_service.dart';

/// {@template users_database_service}
/// A flutter implementation of the user UserDatabaseService that uses
/// CoreDatabaseService and sqflite.
/// {@endtemplate}
class UsersDatabaseService {
  /// {@macro users_database_service}
  UsersDatabaseService() {
    // Register the table with the core database
    _coreDatabase..registerTable(UserTable.createTable)

    // Register migrations if needed
    ..registerMigration(_migrateUserTable);
  }

  final CoreDatabase _coreDatabase = CoreDatabase();

  /// Migration function for user table
  Future<void> _migrateUserTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    //
  }

  /// Insert or Update a User based on [userData]
  Future<int> insertOrUpdateUser(Map<String, dynamic> userData) async {
    return _coreDatabase.insertOrUpdate(UserTable.tableName, userData);
  }

  /// Delete a User based on [id]
  Future<int> deleteUser(int id) async {
    return _coreDatabase.delete(UserTable.tableName, id);
  }
}
