import 'package:holz_logistik_backend/local_storage/contract_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/sawmill_local_storage.dart';

/// Provides constants and utilities for working with
/// the "locations" database table.
class LocationTable {
  /// The name of the database table
  static const String tableName = 'locations';

  /// The column name for the primary key identifier of a location.
  static const String columnId = 'id';

  /// The column name for the done status of the location.
  static const String columnDone = 'done';

  /// The column name for the started status of the location.
  static const String columnStarted = 'started';

  /// The column name for the timestamp when a location was last modified.
  static const String columnLastEdit = 'lastEdit';

  /// The column name for latitude of the location.
  static const String columnLatitude = 'latitude';

  /// The column name for longitude of the location.
  static const String columnLongitude = 'longitude';

  /// The column name for storing the partie number of the location.
  static const String columnPartieNr = 'partieNr';

  /// The column name for the date of a location.
  static const String columnDate = 'date';

  /// The column name for storing additional information of the location.
  static const String columnAdditionalInfo = 'additionalInfo';

  /// The column name for storing the initial quantity of the location.
  static const String columnInitialQuantity = 'initialQuantity';

  /// The column name for storing the initial oversize quantity of the location.
  static const String columnInitialOversizeQuantity = 'initialOversizeQuantity';

  /// The column name for storing the initial piece count of the location.
  static const String columnInitialPieceCount = 'initialPieceCount';

  /// The column name for storing the current quantity of the location.
  static const String columnCurrentQuantity = 'currentQuantity';

  /// The column name for storing the current oversize quantity of the location.
  static const String columnCurrentOversizeQuantity = 'currentOversizeQuantity';

  /// The column name for storing the current piece count of the location.
  static const String columnCurrentPieceCount = 'currentPieceCount';

  /// The column name for storing the contract id of the location.
  static const String columnContractId = 'contractId';

  /// The column name for storing the sync status.
  static const String columnSynced = 'synced';

  /// The column name for storing the deleted status.
  static const String columnDeleted = 'deleted';

  /// SQL statement for creating the locations table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnDone INTEGER NOT NULL,
      $columnStarted INTEGER NOT NULL,
      $columnLastEdit INTEGER NOT NULL,
      $columnLatitude REAL NOT NULL,
      $columnLongitude REAL NOT NULL,
      $columnPartieNr TEXT NOT NULL,
      $columnDate INTEGER NOT NULL,
      $columnAdditionalInfo TEXT NOT NULL,
      $columnInitialQuantity REAL NOT NULL,
      $columnInitialOversizeQuantity REAL NOT NULL,
      $columnInitialPieceCount INTEGER NOT NULL,
      $columnCurrentQuantity REAL NOT NULL,
      $columnCurrentOversizeQuantity REAL NOT NULL,
      $columnCurrentPieceCount INTEGER NOT NULL,
      $columnContractId TEXT NOT NULL,
      $columnSynced INTEGER DEFAULT 0,
      $columnDeleted INTEGER DEFAULT 0,
      FOREIGN KEY ($columnContractId) REFERENCES ${ContractTable.tableName}(${ContractTable.columnId})
    )
  ''';
}

/// Provides the junction between location and sawmill table
class LocationSawmillJunctionTable {
  /// The name of the database table
  static const String tableName = 'locationSawmillJunction';

  /// The column name for the locationId.
  static const String columnLocationId = 'locationId';

  /// The column name for the sawmillId.
  static const String columnSawmillId = 'sawmillId';

  /// The column that stores if the relation is for oversize sawmills.
  static const String columnIsOversize = 'isOversize';

  /// SQL statement for creating the locationSawmillJunction table with the
  /// defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnLocationId TEXT NOT NULL,
      $columnSawmillId TEXT NOT NULL,
      $columnIsOversize INTEGER NOT NULL,
      PRIMARY KEY ($columnLocationId, $columnSawmillId, $columnIsOversize),
      FOREIGN KEY ($columnLocationId) REFERENCES ${LocationTable.tableName}(${LocationTable.columnId}) ON DELETE CASCADE,
      FOREIGN KEY ($columnSawmillId) REFERENCES ${SawmillTable.tableName}(${SawmillTable.columnId}) ON DELETE CASCADE
    )
  ''';
}
