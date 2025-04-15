/// Provides constants and utilities for working with
/// the "contracts" database table.
class ContractTable {
  /// The name of the database table
  static const String tableName = 'contracts';

  /// The column name for the primary key identifier of a contract.
  static const String columnId = 'id';

  /// The column name for the done status of the contract.
  static const String columnDone = 'done';

  /// The column name for the timestamp when a contract was last modified.
  static const String columnLastEdit = 'lastEdit';

  /// The column name for the title of the contract.
  static const String columnTitle = 'title';

  /// The column name for storing the additional info of the contract.
  static const String columnAdditionalInfo = 'additionalInfo';

  /// SQL statement for creating the contracts table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnDone INTEGER NOT NULL,
      $columnLastEdit TEXT NOT NULL,
      $columnTitle TEXT NOT NULL,
      $columnAdditionalInfo TEXT NOT NULL
    )
  ''';
}
