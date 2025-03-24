class QuantityTable {
  static const String tableName = 'quantities';

  static const String columnId = 'qId';
  static const String columnDeleted = 'qDeleted';
  static const String columnLastEdited = 'qLastEdited';
  static const String columnNormalQuantity = 'qNormalQuantity';
  static const String columnOversizeQuantity = 'qOversizeQuantity';
  static const String columnPieceCount = 'qPieceCount';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnDeleted INTEGER NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnNormalQuantity REAL,
      $columnOversizeQuantity REAL,
      $columnPieceCount INTEGER NOT NULL
    )
''';
}

class LocationTable {
  static const String tableName = 'locations';

  static const String columnId = 'lId';
  static const String columnUserId = 'lUserId';
  static const String columnContractId = 'lContractId';
  static const String columnInitialQuantityId = 'lInitialQuantityId';
  static const String columnCurrentQuantityId = 'lCurrentQuantityId';
  static const String columnDeleted = 'lDeleted';
  static const String columnDone = 'lDone';
  static const String columnLastEdited = 'lLastEdited';
  static const String columnLatitude = 'lLatitude';
  static const String columnLongitude = 'lLongitude';
  static const String columnPartieNr = 'lPartieNr';
  static const String columnAdditionalInfo = 'lAdditionalInfo';
  static const String columnSawmill = 'lSawmill';
  static const String columnOversizeSawmill = 'lOversizeSawmill';
  static const String columnPhotoIds = 'lPhotoIds';
  static const String columnPhotoUrls = 'lPhotoUrls';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnUserId TEXT NOT NULL,
      $columnContractId INTEGER NOT NULL,
      $columnInitialQuantityId INTEGER NOT NULL,
      $columnCurrentQuantityId INTEGER NOT NULL,
      $columnDeleted INTEGER NOT NULL,
      $columnDone INTEGER NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnLatitude REAL NOT NULL,
      $columnLongitude REAL NOT NULL,
      $columnPartieNr TEXT NOT NULL,
      $columnAdditionalInfo TEXT,
      $columnSawmill TEXT,
      $columnOversizeSawmill TEXT,
      $columnPhotoIds TEXT,
      $columnPhotoUrls TEXT,
      FOREIGN KEY ($columnUserId) REFERENCES ${UserTable.tableName}(${UserTable.columnId}),
      FOREIGN KEY ($columnContractId) REFERENCES ${ContractTable.tableName}(${ContractTable.columnId}),
      FOREIGN KEY ($columnInitialQuantityId) REFERENCES ${QuantityTable.tableName}(${QuantityTable.columnId}),
      FOREIGN KEY ($columnCurrentQuantityId) REFERENCES ${QuantityTable.tableName}(${QuantityTable.columnId})
    )
  ''';
}

class ShipmentTable {
  static const String tableName = 'shipments';

  static const String columnId = 'sId';
  static const String columnUserId = 'sUserId';
  static const String columnLocationId = 'sLocationId';
  static const String columnContractId = 'sContractId';
  static const String columnQuantityId = 'sQuantityId';
  static const String columnDeleted = 'sDeleted';
  static const String columnLastEdited = 'sLastEdited';
  static const String columnSawmill = 'sSawmill';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnUserId TEXT NOT NULL,
      $columnLocationId INTEGER NOT NULL,
      $columnContractId INTEGER NOT NULL,
      $columnQuantityId INTEGER NOT NULL,
      $columnDeleted INTEGER NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnSawmill TEXT NOT NULL,
      FOREIGN KEY ($columnUserId) REFERENCES ${UserTable.tableName}(${UserTable.columnId}),
      FOREIGN KEY ($columnLocationId) REFERENCES ${LocationTable.tableName}(${LocationTable.columnId}),
      FOREIGN KEY ($columnContractId) REFERENCES ${ContractTable.tableName}(${ContractTable.columnId}),
      FOREIGN KEY ($columnQuantityId) REFERENCES ${QuantityTable.tableName}(${QuantityTable.columnId})
    )
  ''';
}

class ContractTable {
  static const String tableName = 'contracts';

  static const String columnId = 'cId';
  static const String columnDeleted = 'cDeleted';
  static const String columnDone = 'cDone';
  static const String columnLastEdited = 'cLastEdited';
  static const String columnTitle = 'cTitle';
  static const String columnAdditionalInfo = 'cAdditionalContractInfo';
  static const String columnAvailableQuantity = 'cAvailableQuantity';
  static const String columnBookedQuantity = 'cBookedQuantity';
  static const String columnShippedQuantity = 'cShippedQuantity';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId INTEGER PRIMARY KEY NOT NULL,
      $columnDeleted INTEGER NOT NULL,
      $columnDone INTEGER NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnTitle TEXT NOT NULL,
      $columnAdditionalInfo TEXT,
      $columnAvailableQuantity INTEGER NOT NULL,
      $columnBookedQuantity INTEGER NOT NULL,
      $columnShippedQuantity INTEGER NOT NULL
    )
  ''';
}

class UserTable {
  static const String tableName = 'users';

  static const String columnId = 'uId';
  static const String columnPrivileged = 'uPrivileged';
  static const String columnLastEdited = 'uLastEdited';
  static const String columnName = 'uName';

  static const String createTable = '''
    CREATE TABLE $tableName (
      $columnId TEXT PRIMARY KEY NOT NULL,
      $columnPrivileged INTEGER NOT NULL,
      $columnLastEdited INTEGER NOT NULL,
      $columnName TEXT NOT NULL
    )
  ''';
}
