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
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _shipmentUpdatesStreamController =
      StreamController<Shipment>.broadcast();

  late final Stream<Shipment> _shipmentUpdates =
      _shipmentUpdatesStreamController.stream;

  /// Migration function for shipment table
  Future<void> _migrateShipmentTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  @override
  Stream<Shipment> get shipmentUpdates => _shipmentUpdates;

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
      where: '${ShipmentTable.columnLastEdit} >= ? AND '
          '${ShipmentTable.columnLastEdit} <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
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
  Future<int> _insertOrUpdateShipment(Map<String, dynamic> shipmentData) async {
    return _coreLocalStorage.insertOrUpdate(
      ShipmentTable.tableName,
      shipmentData,
    );
  }

  /// Insert or Update a [shipment]
  @override
  Future<int> saveShipment(Shipment shipment) async {
    final result = await _insertOrUpdateShipment(shipment.toJson());

    _shipmentUpdatesStreamController.add(shipment);

    return result;
  }

  /// Delete a Shipment from the database based on [id]
  Future<int> _deleteShipment(String id) async {
    return _coreLocalStorage.delete(ShipmentTable.tableName, id);
  }

  /// Delete a Shipment based on [id] and [locationId]
  @override
  Future<int> deleteShipment({
    required String id,
    required String locationId,
  }) async {
    final shipment = await getShipmentById(id);
    final result = await _deleteShipment(id);

    _shipmentUpdatesStreamController.add(shipment);
    return result;
  }

  /// Close the [_shipmentUpdatesStreamController]
  @override
  Future<void> close() {
    _shipmentUpdatesStreamController.close();
    return Future.value();
  }
}
