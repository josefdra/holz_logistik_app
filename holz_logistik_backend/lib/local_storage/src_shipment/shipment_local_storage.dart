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
  late final _shipmentStreamController =
      BehaviorSubject<Map<String, List<Shipment>>>.seeded(
    const {},
  );
  late final _allShipemtsStreamController =
      BehaviorSubject<List<Shipment>>.seeded(
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
    final shipmentsJson =
        await _coreLocalStorage.getAll(ShipmentTable.tableName);

    final shipmentsByLocationId = <String, List<Shipment>>{};
    final allShipments = <Shipment>[];

    for (final shipmentData in shipmentsJson) {
      final shipment =
          Shipment.fromJson(Map<String, dynamic>.from(shipmentData));

      if (!shipmentsByLocationId.containsKey(shipment.locationId)) {
        shipmentsByLocationId[shipment.locationId] = [];
      }

      allShipments.add(shipment);
      shipmentsByLocationId[shipment.locationId]!.add(shipment);
    }

    _allShipemtsStreamController.add(allShipments);
    _shipmentStreamController.add(shipmentsByLocationId);
  }

  @override
  Stream<Map<String, List<Shipment>>> get shipmentsByLocation =>
      _shipmentStreamController.asBroadcastStream();

  @override
  Stream<List<Shipment>> get shipments =>
      _allShipemtsStreamController.asBroadcastStream();

  @override
  Map<String, List<Shipment>> get currentShipmentsByLocation =>
      _shipmentStreamController.value;

  @override
  List<Shipment> get currentShipments =>
      _allShipemtsStreamController.value;

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
    final currentShipmentsByLocation = _shipmentStreamController.value;
    if (!currentShipmentsByLocation.containsKey(shipment.locationId)) {
      currentShipmentsByLocation[shipment.locationId] = [];
    }

    currentShipmentsByLocation[shipment.locationId]!.add(shipment);
    _shipmentStreamController.add(currentShipmentsByLocation);

    final allShipments = [..._allShipemtsStreamController.value];
    final shipmentIndex = allShipments.indexWhere((s) => s.id == shipment.id);

    if (shipmentIndex >= 0) {
      allShipments[shipmentIndex] = shipment;
    } else {
      allShipments.add(shipment);
    }

    _allShipemtsStreamController.add(allShipments);
    return _insertOrUpdateShipment(shipment.toJson());
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
    final currentShipmentsByLocation = _shipmentStreamController.value;

    currentShipmentsByLocation[locationId]!.removeWhere((s) => s.id == id);

    if (currentShipmentsByLocation[locationId]!.isEmpty) {
      currentShipmentsByLocation.remove(locationId);
    }

    _shipmentStreamController.add(currentShipmentsByLocation);

    final allShipments = [..._allShipemtsStreamController.value];
    final contractIndex = allShipments.indexWhere((s) => s.id == id);

    allShipments.removeAt(contractIndex);
    _allShipemtsStreamController.add(allShipments);

    return _deleteShipment(id);
  }

  /// Close the [_shipmentStreamController]
  @override
  Future<void> close() {
    return _shipmentStreamController.close();
  }
}
