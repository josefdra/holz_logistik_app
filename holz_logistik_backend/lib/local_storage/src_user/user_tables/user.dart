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
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnLastEdit INTEGER NOT NULL,
      $columnRole INTEGER NOT NULL,
      $columnName TEXT NOT NULL
    )
  ''';
}
