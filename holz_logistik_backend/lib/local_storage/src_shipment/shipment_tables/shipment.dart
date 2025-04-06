import 'package:holz_logistik_backend/local_storage/contract_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/location_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/user_local_storage.dart';

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

  /// The column name for storing the location id of the shipment.
  static const String columnLocationtId = 'locationId';

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
      $columnLocationtId TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES ${UserTable.tableName}(${UserTable.columnId}),
      FOREIGN KEY ($columnContractId) REFERENCES ${ContractTable.tableName}(${ContractTable.columnId}),
      FOREIGN KEY ($columnLocationtId) REFERENCES ${LocationTable.tableName}(${LocationTable.columnId})
    )
  ''';
}
