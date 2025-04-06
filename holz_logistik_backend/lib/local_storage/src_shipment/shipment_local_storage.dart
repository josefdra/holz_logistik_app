import 'package:holz_logistik_backend/api/shipment_api.dart';
import 'package:holz_logistik_backend/local_storage/core_local_storage.dart';
import 'package:holz_logistik_backend/local_storage/shipment_local_storage.dart';
import 'package:rxdart/subjects.dart';
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

    _init();
  }

  final CoreLocalStorage _coreLocalStorage;
  late final _shipmentStreamController = BehaviorSubject<List<Shipment>>.seeded(
    const [],
  );

  /// Migration function for shipment table
  Future<void> _migrateShipmentTable(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Migration logic here if needed
  }

  /// Initialization
  Future<void> _init() async {
    final shipmentsJson = await _coreLocalStorage.getAll(
      ShipmentTable.tableName,
    );
    final shipments = shipmentsJson
        .map(
          (shipment) => Shipment.fromJson(Map<String, dynamic>.from(shipment)),
        )
        .toList();
    _shipmentStreamController.add(shipments);
  }

  /// Get the `shipment`s from the [_shipmentStreamController]
  @override
  Stream<List<Shipment>> getShipments() =>
      _shipmentStreamController.asBroadcastStream();

  /// Insert or Update a `shipment` to the database based on [shipmentData]
  Future<int> _insertOrUpdateShipment(Map<String, dynamic> shipmentData) async {
    return _coreLocalStorage.insertOrUpdate(
      ShipmentTable.tableName,
      shipmentData,
    );
  }

  /// Insert or Update a [shipment]
  @override
  Future<int> saveShipment(Shipment shipment) {
    final shipments = [..._shipmentStreamController.value];
    final shipmentIndex = shipments.indexWhere((t) => t.id == shipment.id);
    if (shipmentIndex >= 0) {
      shipments[shipmentIndex] = shipment;
    } else {
      shipments.add(shipment);
    }

    _shipmentStreamController.add(shipments);
    return _insertOrUpdateShipment(shipment.toJson());
  }

  /// Delete a Shipment from the database based on [id]
  Future<int> _deleteShipment(String id) async {
    return _coreLocalStorage.delete(ShipmentTable.tableName, id);
  }

  /// Delete a Shipment based on [id]
  @override
  Future<int> deleteShipment(String id) async {
    final shipments = [..._shipmentStreamController.value];
    final shipmentIndex = shipments.indexWhere((t) => t.id == id);
    if (shipmentIndex == -1) {
      throw ShipmentNotFoundException();
    } else {
      shipments.removeAt(shipmentIndex);
      _shipmentStreamController.add(shipments);
      return _deleteShipment(id);
    }
  }

  /// Close the [_shipmentStreamController]
  @override
  Future<void> close() {
    return _shipmentStreamController.close();
  }
}
