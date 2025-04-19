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

  /// The column name for the timestamp when a contract starts.
  static const String columnStartDate = 'startDate';

  /// The column name for the timestamp when a contract ends.
  static const String columnEndDate = 'endDate';

  /// The column name for storing the available quantity of the contract.
  static const String columnAvailableQuantity = 'availableQuantity';

  /// The column name for storing the booked quantity of the contract.
  static const String columnBookedQuantity = 'bookedQuantity';

  /// The column name for storing the shipped quantity of the contract.
  static const String columnShippedQuantity = 'shippedQuantity';

  /// SQL statement for creating the contracts table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnDone INTEGER NOT NULL,
      $columnLastEdit TEXT NOT NULL,
      $columnTitle TEXT NOT NULL,
      $columnAdditionalInfo TEXT NOT NULL,
      $columnStartDate TEXT NOT NULL,
      $columnEndDate TEXT NOT NULL,
      $columnAvailableQuantity REAL NOT NULL,
      $columnBookedQuantity REAL NOT NULL,
      $columnShippedQuantity REAL NOT NULL
    )
  ''';
}
