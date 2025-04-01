/// Provides constants and utilities for working with 
/// the "users" database table.
class UserTable {
  /// The name of the database table
  static const String tableName = 'users';

  /// The column name for the primary key identifier of a user.
  static const String columnId = 'id';
  
  /// The column name for storing the timestamp when a user was last modified.
  static const String columnLastEdited = 'lastEdited';
  
  /// The column name for storing a boolean flag indicating if a user has 
  /// privileged access (stored as INTEGER).
  static const String columnPrivileged = 'privileged';
  
  /// The column name for storing the user's name.
  static const String columnName = 'name';

  /// SQL statement for creating the users table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnPrivileged INTEGER NOT NULL,
      $columnName TEXT NOT NULL
    )
  ''';
}
