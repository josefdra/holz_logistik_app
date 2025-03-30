/// ======================================= User ======================================= ///

class UserTable {
  static const String tableName = 'users';

  static const String columnId = 'id';
  static const String columnLastEdited = 'lastEdited';
  static const String columnPrivileged = 'privileged';
  static const String columnName = 'name';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnPrivileged INTEGER NOT NULL,
      $columnName TEXT NOT NULL
    )
  ''';
}

/// ======================================= Contract ======================================= ///

class ContractTable {
  static const String tableName = 'contracts';

  static const String columnId = 'id';
  static const String columnSynced = 'synced';
  static const String columnDone = 'done';
  static const String columnLastEdited = 'lastEdited';
  static const String columnTitle = 'title';
  static const String columnAdditionalInfo = 'additionalInfo';
  static const String columnAvailable = 'available';
  static const String columnBooked = 'booked';
  static const String columnShipped = 'shipped';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnSynced INTEGER NOT NULL DEFAULT 0,
      $columnDone INTEGER NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnTitle TEXT NOT NULL,
      $columnAdditionalInfo TEXT NOT NULL,
      $columnAvailable INTEGER NOT NULL,
      $columnBooked INTEGER NOT NULL,
      $columnShipped INTEGER NOT NULL
    )
  ''';
}

/// ======================================= Quantity ======================================= ///

class QuantityTable {
  static const String tableName = 'quantities';

  static const String columnId = 'id';
  static const String columnSynced = 'synced';
  static const String columnLastEdited = 'lastEdited';
  static const String columnNormal = 'normal';
  static const String columnOversize = 'oversize';
  static const String columnPieceCount = 'pieceCount';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnSynced INTEGER NOT NULL DEFAULT 0,
      $columnLastEdited INTEGER NOT NULL,
      $columnNormal REAL NOT NULL,
      $columnOversize REAL NOT NULL,
      $columnPieceCount INTEGER NOT NULL
    )
''';
}

/// ======================================= Shipment ======================================= ///

class ShipmentTable {
  static const String tableName = 'shipments';

  static const String columnId = 'id';
  static const String columnSynced = 'synced';
  static const String columnLocationId = 'locationId';
  static const String columnSawmill = 'sawmill';
  static const String columnLastEdited = 'lastEdited';
  static const String columnUserId = 'userId';
  static const String columnContractId = 'contractId';
  static const String columnQuantityId = 'quantityId';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnSynced INTEGER NOT NULL DEFAULT 0,
      $columnLocationId INTEGER NOT NULL,
      $columnSawmill TEXT NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnUserId TEXT NOT NULL,
      $columnContractId INTEGER NOT NULL,
      $columnQuantityId INTEGER NOT NULL,
      FOREIGN KEY ($columnLocationId) REFERENCES ${LocationTable.tableName}(${LocationTable.columnId}),
      FOREIGN KEY ($columnUserId) REFERENCES ${UserTable.tableName}(${UserTable.columnId}),
      FOREIGN KEY ($columnContractId) REFERENCES ${ContractTable.tableName}(${ContractTable.columnId}),
      FOREIGN KEY ($columnQuantityId) REFERENCES ${QuantityTable.tableName}(${QuantityTable.columnId})
    )
  ''';
}

/// ======================================= Location ======================================= ///

class LocationTable {
  static const String tableName = 'locations';

  static const String columnId = 'id';
  static const String columnSynced = 'synced';
  static const String columnDone = 'done';
  static const String columnLastEdited = 'lastEdited';
  static const String columnLatitude = 'latitude';
  static const String columnLongitude = 'longitude';
  static const String columnPartieNr = 'partieNr';
  static const String columnAdditionalInfo = 'additionalInfo';
  static const String columnSawmill = 'sawmill';
  static const String columnOversizeSawmill = 'oversizeSawmill';
  static const String columnPhotoUrls = 'photoUrls';
  static const String columnContractId = 'contractId';
  static const String columnInitialQuantityId = 'initialQuantityId';
  static const String columnCurrentQuantityId = 'currentQuantityId';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnSynced INTEGER NOT NULL DEFAULT 0,
      $columnDone INTEGER NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnLatitude REAL NOT NULL,
      $columnLongitude REAL NOT NULL,
      $columnPartieNr TEXT NOT NULL,
      $columnAdditionalInfo TEXT NOT NULL,
      $columnSawmill TEXT NOT NULL,
      $columnOversizeSawmill TEXT NOT NULL,
      $columnPhotoUrls TEXT NOT NULL,
      $columnContractId INTEGER NOT NULL,
      $columnInitialQuantityId INTEGER NOT NULL,
      $columnCurrentQuantityId INTEGER NOT NULL,
      FOREIGN KEY ($columnContractId) REFERENCES ${ContractTable.tableName}(${ContractTable.columnId}),
      FOREIGN KEY ($columnInitialQuantityId) REFERENCES ${QuantityTable.tableName}(${QuantityTable.columnId}),
      FOREIGN KEY ($columnCurrentQuantityId) REFERENCES ${QuantityTable.tableName}(${QuantityTable.columnId})
    )
  ''';
}
