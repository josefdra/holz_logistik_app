import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:holz_logistik/database/tables.dart';

List<T>? decodeJsonList<T>(String? jsonString) {
  if (jsonString == null) return null;
  try {
    return List<T>.from(jsonDecode(jsonString));
  } catch (_) {
    return null;
  }
}

/// --------------------------------------- Quantity --------------------------------------- ///

class Quantity {
  final int id;
  DateTime lastEdited;
  double? normal;
  double? oversize;
  int pieceCount;

  Quantity(
      {required this.id,
      required this.lastEdited,
      this.normal,
      this.oversize,
      required this.pieceCount});

  static Quantity fromMap(Map<String, dynamic> map) {
    return Quantity(
      id: map[QuantityTable.columnId],
      lastEdited: DateTime.fromMillisecondsSinceEpoch(
          map[QuantityTable.columnLastEdited]),
      normal: map[QuantityTable.columnNormalQuantity],
      oversize: map[QuantityTable.columnOversizeQuantity],
      pieceCount: map[QuantityTable.columnPieceCount],
    );
  }

  static Map<String, dynamic> getValues(Quantity quantity) {
    Map<String, dynamic> values = {
      QuantityTable.columnLastEdited: DateTime.now().millisecondsSinceEpoch,
      QuantityTable.columnNormalQuantity: quantity.normal,
      QuantityTable.columnOversizeQuantity: quantity.oversize,
      QuantityTable.columnPieceCount: quantity.pieceCount
    };

    return values;
  }

  static Map<String, dynamic> getCreateValues(Quantity quantity) {
    Map<String, dynamic> values = getValues(quantity);

    values[QuantityTable.columnId] = DateTime.now().microsecondsSinceEpoch;

    return values;
  }

  static Map<String, dynamic> getUpdateValues(Quantity quantity) {
    Map<String, dynamic> values = getValues(quantity);

    return values;
  }
}

/// --------------------------------------- Location --------------------------------------- ///

class Location {
  final int id;
  DateTime lastEdited;
  final double latitude;
  final double longitude;
  String partieNr;
  Contract? contract;
  String? additionalInfo;
  String? sawmill;
  String? oversizeSawmill;
  final Quantity? initialQuantity;
  final Quantity? currentQuantity;
  final List<int>? photoIds;
  final List<String>? photoUrls;
  final List<Shipment>? shipments;

  Location(
      {required this.id,
      required this.lastEdited,
      required this.latitude,
      required this.longitude,
      required this.partieNr,
      this.contract,
      this.additionalInfo,
      this.sawmill,
      this.oversizeSawmill,
      this.initialQuantity,
      this.currentQuantity,
      this.photoIds,
      this.photoUrls,
      this.shipments});

  static Location fromMap(Map<String, dynamic> map, Contract contract,
      Quantity initialQuantity, Quantity currentQuantity,
      {List<Shipment>? shipments}) {
    final bool isDone = (map[LocationTable.columnDone] ?? 0) == 1;
    final photoIds =
        isDone ? decodeJsonList<int>(map[LocationTable.columnPhotoIds]) : null;
    final photoUrls = isDone
        ? decodeJsonList<String>(map[LocationTable.columnPhotoUrls])
        : null;

    return Location(
        id: map[LocationTable.columnId],
        lastEdited: DateTime.fromMillisecondsSinceEpoch(
            map[LocationTable.columnLastEdited]),
        latitude: map[LocationTable.columnLatitude],
        longitude: map[LocationTable.columnLongitude],
        partieNr: map[LocationTable.columnPartieNr],
        contract: contract,
        additionalInfo: map[LocationTable.columnAdditionalInfo],
        sawmill: map[LocationTable.columnSawmill],
        oversizeSawmill: map[LocationTable.columnOversizeSawmill],
        initialQuantity: initialQuantity,
        currentQuantity: currentQuantity,
        photoIds: photoIds,
        photoUrls: photoUrls,
        shipments: shipments);
  }

  static Future<Map<String, dynamic>> getValues(Location location) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> values = {
      LocationTable.columnUserId: prefs.getString('userId'),
      LocationTable.columnContractId: location.contract!.id,
      LocationTable.columnInitialQuantityId: location.initialQuantity!.id,
      LocationTable.columnCurrentQuantityId: location.currentQuantity!.id,
      LocationTable.columnLastEdited: DateTime.now().millisecondsSinceEpoch,
      LocationTable.columnLatitude: location.latitude,
      LocationTable.columnLongitude: location.longitude,
      LocationTable.columnPartieNr: location.partieNr,
      LocationTable.columnAdditionalInfo: location.additionalInfo,
      LocationTable.columnSawmill: location.sawmill,
      LocationTable.columnOversizeSawmill: location.oversizeSawmill,
      LocationTable.columnPhotoIds: location.photoIds,
      LocationTable.columnPhotoUrls: location.photoUrls
    };

    return values;
  }

  static Future<Map<String, dynamic>> getCreateValues(Location location) async {
    Map<String, dynamic> values = await getValues(location);

    values[LocationTable.columnId] = DateTime.now().microsecondsSinceEpoch;
    values[LocationTable.columnDeleted] = 0;
    values[LocationTable.columnDone] = 0;

    return values;
  }

  static Future<Map<String, dynamic>> getUpdateValues(Location location) async {
    Map<String, dynamic> values = await getValues(location);

    return values;
  }
}

/// --------------------------------------- Shipment --------------------------------------- ///

class Shipment {
  final int id;
  final int locationId;
  final String? driverName;
  final Contract? contract;
  final String sawmill;
  final Quantity? quantity;

  Shipment(
      {required this.id,
      required this.locationId,
      this.driverName,
      this.contract,
      required this.sawmill,
      this.quantity});

  static Shipment fromMap(Map<String, dynamic> map, Quantity quantity) {
    Contract contract = Contract.fromMap(map);

    return Shipment(
        id: map[ShipmentTable.columnId],
        locationId: map[ShipmentTable.columnLocationId],
        driverName: map[UserTable.columnName],
        contract: contract,
        sawmill: map[ShipmentTable.columnSawmill],
        quantity: quantity);
  }

  static Future<Map<String, dynamic>> getValues(Shipment shipment) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> values = {
      ShipmentTable.columnUserId: prefs.getString('userId'),
      ShipmentTable.columnLocationId: shipment.locationId,
      ShipmentTable.columnContractId: shipment.contract!.id,
      ShipmentTable.columnQuantityId: shipment.quantity!.id,
      ShipmentTable.columnLastEdited: DateTime.now().millisecondsSinceEpoch,
      ShipmentTable.columnSawmill: shipment.sawmill,
    };

    return values;
  }

  static Future<Map<String, dynamic>> getCreateValues(
      Shipment shipment) async {
    Map<String, dynamic> values = await getValues(shipment);

    values[ShipmentTable.columnId] = DateTime.now().microsecondsSinceEpoch;
    values[ShipmentTable.columnDeleted] = 0;

    return values;
  }
}

/// --------------------------------------- Contract --------------------------------------- ///

class Contract {
  final int id;
  String title;
  String? additionalInfo;
  int availableQuantity;
  int bookedQuantity;
  int shippedQuantity;

  Contract({
    required this.id,
    required this.title,
    this.additionalInfo,
    required this.availableQuantity,
    required this.bookedQuantity,
    required this.shippedQuantity,
  });

  static Contract fromMap(Map<String, dynamic> map) {
    return Contract(
      id: map[ContractTable.columnId],
      title: map[ContractTable.columnTitle],
      additionalInfo: map[ContractTable.columnAdditionalInfo],
      availableQuantity: map[ContractTable.columnAvailableQuantity],
      bookedQuantity: map[ContractTable.columnBookedQuantity],
      shippedQuantity: map[ContractTable.columnShippedQuantity],
    );
  }

  static Future<Map<String, dynamic>> getValues(Contract contract) async {
    Map<String, dynamic> values = {
      ContractTable.columnLastEdited: DateTime.now().millisecondsSinceEpoch,
      ContractTable.columnTitle: contract.title,
      ContractTable.columnAdditionalInfo: contract.additionalInfo,
      ContractTable.columnAvailableQuantity: contract.availableQuantity,
      ContractTable.columnBookedQuantity: contract.bookedQuantity,
      ContractTable.columnShippedQuantity: contract.shippedQuantity,
    };

    return values;
  }

  static Future<Map<String, dynamic>> getCreateValues(Contract contract) async {
    Map<String, dynamic> values = await getValues(contract);

    values[ContractTable.columnId] = DateTime.now().microsecondsSinceEpoch;
    values[ContractTable.columnDeleted] = 0;
    values[ContractTable.columnDone] = 0;

    return values;
  }

  static Future<Map<String, dynamic>> getUpdateValues(Contract contract) async {
    Map<String, dynamic> values = await getValues(contract);

    return values;
  }
}

/// --------------------------------------- User --------------------------------------- ///

class User {
  final String id;
  bool privileged;
  DateTime lastEdited;
  String name;

  User(
      {required this.id,
      required this.privileged,
      required this.lastEdited,
      required this.name});

  static User fromMap(Map<String, dynamic> map) {
    return User(
        id: map[UserTable.columnId],
        privileged: map[UserTable.columnPrivileged],
        lastEdited: DateTime.fromMillisecondsSinceEpoch(
            map[UserTable.columnLastEdited]),
        name: map[UserTable.columnName]);
  }
}
