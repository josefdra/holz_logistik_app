/// Provides constants and utilities for working with
/// the "users" database table.
class UserTable {
  /// The name of the database table
  static const String tableName = 'users';

  /// The column name for the primary key identifier of a user.
  static const String columnId = 'id';

  /// The column name for storing the timestamp when a user was last modified.
  static const String columnLastEdit = 'lastEdit';

  /// The column name for storing the user role (stored as INTEGER).
  static const String columnRole = 'role';

  /// The column name for storing the user's name.
  static const String columnName = 'name';

  /// SQL statement for creating the users table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnLastEdit TEXT NOT NULL,
      $columnRole INTEGER NOT NULL,
      $columnName TEXT NOT NULL
    )
  ''';
}

/// Provides constants and utilities for working with
/// the "authenticated_user" database table.
class AuthenticatedUserTable {
  /// The name of the database table
  static const String tableName = 'authenticatedUser';

  /// The column name for the primary key identifier of a user.
  static const String columnId = 'id';

  /// The column name for storing the timestamp when a user was last modified.
  static const String columnUserId = 'userId';

  /// SQL statement for creating the users table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnUserId INTEGER NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES ${UserTable.tableName}(${UserTable.columnId})
    )
  ''';
}
