import 'location_table.dart';

class ShipmentTable {
  static const String tableName = 'shipments';

  static const String columnId = 'id';
  static const String columnLocationId = 'location_id';
  static const String columnOversizeQuantity = 'oversize_quantity';
  static const String columnQuantity = 'quantity';
  static const String columnPieceCount = 'piece_count';
  static const String columnTimestamp = 'timestamp';
  static const String columnIsUndone = 'is_undone';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
      $columnLocationId INTEGER NOT NULL,
      $columnOversizeQuantity INTEGER,
      $columnQuantity INTEGER NOT NULL,
      $columnPieceCount INTEGER NOT NULL,
      $columnTimestamp TEXT NOT NULL,
      $columnIsUndone INTEGER NOT NULL DEFAULT 0,
      FOREIGN KEY ($columnLocationId) REFERENCES ${LocationTable.tableName} (${LocationTable.columnId})
    )
  ''';
}
