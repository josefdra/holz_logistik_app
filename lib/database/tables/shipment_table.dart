import 'location_table.dart';

class ShipmentTable {
  static const String tableName = 'shipments';

  static const String columnId = 'id';
  static const String columnUserId = 'userId';
  static const String columnLocationId = 'locationId';
  static const String columnDate = 'date';
  static const String columnContract = 'contract';
  static const String columnAdditionalInfo = 'additionalInfo';
  static const String columnSawmill = 'sawmill';
  static const String columnNormalQuantity = 'normalQuantity';
  static const String columnOversizeQuantity = 'oversizeQuantity';
  static const String columnPieceCount = 'pieceCount';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnUserId TEXT NOT NULL,
      $columnLocationId INTEGER NOT NULL,
      $columnDate INTEGER NOT NULL,
      $columnContract TEXT,
      $columnAdditionalInfo TEXT,
      $columnSawmill TEXT,
      $columnNormalQuantity REAL,
      $columnOversizeQuantity REAL,
      $columnPieceCount INTEGER,
      FOREIGN KEY ($columnLocationId) REFERENCES ${LocationTable.tableName}(${LocationTable.columnId})
    )
  ''';
}