import 'dart:async';

import 'package:holz_logistik_backend/api/shipment_api.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/shipment_local_storage.dart';
import 'package:sqflite/sqflite.dart';

/// {@template shipment_local_storage}
/// A flutter implementation of the shipment ShipmentLocalStorage that uses
/// CoreLocalStorage and sqflite.
/// {@endtemplate}
class ShipmentLocalStorage extends ShipmentApi {
  /// {@macro shipment_local_storage}
  ShipmentLocalStorage({required CoreLocalStorage coreLocalStorage})
      : _coreLocalStorage = coreLocalStorage {
    // Register the table with the core database
    _coreLocalStorage
      ..registerTable(ShipmentTable.createTable)
      ..registerMigration(_migrateShipmentTable);

    _listenToDatabaseSwitches();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _shipmentUpdatesStreamController =
      StreamController<Shipment>.broadcast();

  late final Stream<Shipment> _shipmentUpdates =
      _shipmentUpdatesStreamController.stream;

  static const _syncFromServerKey = '__shipment_sync_from_server_date_key__';

  // Subscription to database switch events
  StreamSubscription<String>? _databaseSwitchSubscription;

  /// Migration function for shipment table
  Future<void> _migrateShipmentTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2 && newVersion >= 2) {
      await db.execute('''
      ALTER TABLE ${ShipmentTable.tableName} 
      ADD COLUMN ${ShipmentTable.columnAdditionalInfo} TEXT
    ''');
    }
  }

  /// Listen to database switch events and reload caches
  void _listenToDatabaseSwitches() {
    _databaseSwitchSubscription = _coreLocalStorage.onDatabaseSwitch.listen(
      (newDatabaseId) async {
        await _reloadCaches();
      },
    );
  }

  /// Reload all caches after database switch
  Future<void> _reloadCaches() async {
    _shipmentUpdatesStreamController.add(Shipment());
  }

  @override
  Stream<Shipment> get shipmentUpdates => _shipmentUpdates;

  @override
  String get dbName => _coreLocalStorage.dbName;

  /// Provides the last sync date
  @override
  Future<DateTime> getLastSyncDate() =>
      _coreLocalStorage.getLastSyncDate(_syncFromServerKey);

  /// Sets the last sync date
  @override
  Future<void> setLastSyncDate(String dbName, DateTime date) =>
      _coreLocalStorage.setLastSyncDate(dbName, _syncFromServerKey, date);

  /// Gets unsynced updates
  @override
  Future<List<Map<String, dynamic>>> getUpdates() =>
      _coreLocalStorage.getUpdates(ShipmentTable.tableName);

  @override
  Future<List<Shipment>> getShipmentsByLocation(String locationId) async {
    final shipmentsJson = await _coreLocalStorage.getByColumn(
      ShipmentTable.tableName,
      ShipmentTable.columnLocationId,
      locationId,
    );

    final shipments = <Shipment>[];
    for (final shipmentJson in shipmentsJson) {
      final shipment = Shipment.fromJson(shipmentJson);
      shipments.add(shipment);
    }

    return shipments;
  }

  @override
  Future<List<Shipment>> getShipmentsByDate(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _coreLocalStorage.database;

    final shipmentsJson = await db.query(
      ShipmentTable.tableName,
      where: '${ShipmentTable.columnDeleted} = 0 AND '
          '${ShipmentTable.columnLastEdit} >= ? AND '
          '${ShipmentTable.columnLastEdit} <= ?',
      whereArgs: [
        start.toUtc().millisecondsSinceEpoch,
        end.toUtc().millisecondsSinceEpoch,
      ],
    );

    final shipments = <Shipment>[];
    for (final shipmentJson in shipmentsJson) {
      final shipment = Shipment.fromJson(shipmentJson);
      shipments.add(shipment);
    }

    return shipments;
  }

  /// Get shipment by id
  @override
  Future<Shipment> getShipmentById(String id) async {
    final shipments = await _coreLocalStorage.getById(
      ShipmentTable.tableName,
      id,
    );

    return Shipment.fromJson(shipments.first);
  }

  /// Insert or Update a `shipment` to the database based on [shipmentData]
  Future<int> _insertOrUpdateShipment(
    Map<String, dynamic> shipmentData, {
    String? dbName,
  }) async {
    return _coreLocalStorage.insertOrUpdate(
      ShipmentTable.tableName,
      shipmentData,
      dbName: dbName,
    );
  }

  /// Insert or Update a [shipment]
  @override
  Future<int> saveShipment(
    Shipment shipment, {
    bool fromServer = false,
    String? dbName,
  }) async {
    final json = shipment.toJson();

    if (fromServer) {
      if (!(await _coreLocalStorage.isNewer(
        ShipmentTable.tableName,
        shipment.lastEdit,
        shipment.id,
      ))) {
        return 0;
      }

      json['synced'] = 1;
    } else {
      json['synced'] = 0;
      json['lastEdit'] = DateTime.now().toUtc().millisecondsSinceEpoch;
    }

    final result = await _insertOrUpdateShipment(json, dbName: dbName);

    _shipmentUpdatesStreamController.add(shipment);

    return result;
  }

  /// Delete a Shipment from the database based on [id]
  Future<int> _deleteShipment(String id, String dbName) async {
    return _coreLocalStorage.delete(ShipmentTable.tableName, id, dbName);
  }

  /// Marks a Shipment deleted based on [id] and [locationId]
  @override
  Future<int> markShipmentDeleted({
    required String id,
    required String locationId,
  }) async {
    final resultList =
        await _coreLocalStorage.getByIdForDeletion(ShipmentTable.tableName, id);

    if (resultList.isEmpty) return 0;

    final shipment = Shipment.fromJson(resultList.first);
    final json = Map<String, dynamic>.from(resultList.first);
    json['deleted'] = 1;
    json['synced'] = 0;
    final result = await _insertOrUpdateShipment(json);

    _shipmentUpdatesStreamController.add(shipment);
    return result;
  }

  /// Delete a Shipment based on [id]
  @override
  Future<void> deleteShipment({
    required String id,
    required String dbName,
  }) async {
    final result =
        await _coreLocalStorage.getByIdForDeletion(ShipmentTable.tableName, id);

    if (result.isEmpty) return Future<void>.value();

    final shipment = Shipment.fromJson(result.first);

    await _deleteShipment(id, dbName);
    _shipmentUpdatesStreamController.add(shipment);
  }

  /// Sets synced
  @override
  Future<void> setSynced({required String id, required String dbName}) =>
      _coreLocalStorage.setSynced(ShipmentTable.tableName, id, dbName);

  /// Close the [_shipmentUpdatesStreamController]
  @override
  Future<void> close() {
    _databaseSwitchSubscription?.cancel();
    _shipmentUpdatesStreamController.close();
    return Future.value();
  }
}
