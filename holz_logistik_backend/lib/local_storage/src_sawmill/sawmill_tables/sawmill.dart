/// Provides constants and utilities for working with
/// the "sawmills" database table.
class SawmillTable {
  /// The name of the database table
  static const String tableName = 'sawmills';

  /// The column name for the primary key identifier of a sawmill.
  static const String columnId = 'id';

  /// The column name for storing when a sawmill was last modified.
  static const String columnLastEdit = 'lastEdit';

  /// The column name for storing the sawmill's name.
  static const String columnName = 'name';

  /// SQL statement for creating the sawmills table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnLastEdit INTEGER NOT NULL,
      $columnName TEXT NOT NULL
    )
  ''';
}
