import 'package:holz_logistik_backend/local_storage/local_storage.dart';

/// Provides constants and utilities for working with
/// the "shipments" database table.
class ShipmentTable {
  /// The name of the database table
  static const String tableName = 'shipments';

  /// The column name for the primary key identifier of a shipment.
  static const String columnId = 'id';

  /// The column name for storing when a shipment was last modified.
  static const String columnLastEdit = 'lastEdit';

  /// The column name for storing the quantity of the shipment.
  static const String columnQuantity = 'quantity';

  /// The column name for storing the oversize quantity of the shipment.
  static const String columnOversizeQuantity = 'oversizeQuantity';

  /// The column name for storing the piece count of the shipment.
  static const String columnPieceCount = 'pieceCount';

  /// The column name for storing the user id of the shipment.
  static const String columnUserId = 'userId';

  /// The column name for storing the contract id of the shipment.
  static const String columnContractId = 'contractId';

  /// The column name for storing the sawmill id of the shipment.
  static const String columnSawmillId = 'sawmillId';

  /// The column name for storing the location id of the shipment.
  static const String columnLocationId = 'locationId';

  /// SQL statement for creating the shipments table with the defined schema.
  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnLastEdit TEXT NOT NULL,
      $columnQuantity REAL NOT NULL,
      $columnOversizeQuantity REAL NOT NULL,
      $columnPieceCount INTEGER NOT NULL,
      $columnUserId TEXT NOT NULL,
      $columnContractId TEXT NOT NULL,
      $columnSawmillId TEXT NOT NULL,
      $columnLocationId TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES ${UserTable.tableName}(${UserTable.columnId}),
      FOREIGN KEY ($columnContractId) REFERENCES ${ContractTable.tableName}(${ContractTable.columnId}),
      FOREIGN KEY ($columnSawmillId) REFERENCES ${SawmillTable.tableName}(${LocationTable.columnId})
      FOREIGN KEY ($columnLocationId) REFERENCES ${LocationTable.tableName}(${LocationTable.columnId})
    )
  ''';
}
