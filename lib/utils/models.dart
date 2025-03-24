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

class Quantity {
  final int id;
  final bool deleted;
  DateTime lastEdited;
  double? normal;
  double? oversize;
  int pieceCount;

  Quantity(
      {required this.id,
      required this.deleted,
      required this.lastEdited,
      this.normal,
      this.oversize,
      required this.pieceCount});

  static Quantity fromMap(Map<String, dynamic> map) {
    return Quantity(
      id: map[QuantityTable.columnId],
      deleted: map[QuantityTable.columnDeleted],
      lastEdited: DateTime.fromMillisecondsSinceEpoch(
          map[QuantityTable.columnLastEdited]),
      normal: map[QuantityTable.columnNormalQuantity],
      oversize: map[QuantityTable.columnOversizeQuantity],
      pieceCount: map[QuantityTable.columnPieceCount],
    );
  }

  static Map<String, dynamic> getValues(Quantity quantity) {
    Map<String, dynamic> values = {
      QuantityTable.columnDeleted: 0,
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

    values[QuantityTable.columnId] = quantity.id;

    return values;
  }
}

class DisplayLocation {
  final int id;
  DateTime lastEdited;
  final double latitude;
  final double longitude;
  String partieNr;
  DisplayContract? contract;
  String? additionalInfo;
  String? sawmill;
  String? oversizeSawmill;
  final Quantity? initialQuantity;
  final Quantity? currentQuantity;
  final List<int>? photoIds;
  final List<String>? photoUrls;
  final List<DisplayShipment>? shipments;

  DisplayLocation(
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

  static DisplayLocation fromMap(
      Map<String, dynamic> map,
      DisplayContract contract,
      Quantity initialQuantity,
      Quantity currentQuantity,
      {List<DisplayShipment>? shipments}) {
    final bool isDone = (map[LocationTable.columnDone] ?? 0) == 1;
    final photoIds =
        isDone ? decodeJsonList<int>(map[LocationTable.columnPhotoIds]) : null;
    final photoUrls = isDone
        ? decodeJsonList<String>(map[LocationTable.columnPhotoUrls])
        : null;

    return DisplayLocation(
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

  static bool isDone(DisplayLocation location) {
    return (location.currentQuantity!.normal == 0 &&
        location.currentQuantity!.oversize! == 0 &&
        location.currentQuantity!.pieceCount == 0);
  }

  static Future<Map<String, dynamic>> getValues(
      DisplayLocation location) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> values = {
      LocationTable.columnUserId: prefs.getString('apiKey'),
      LocationTable.columnContractId: location.contract!.id,
      LocationTable.columnInitialQuantityId: location.initialQuantity!.id,
      LocationTable.columnCurrentQuantityId: location.currentQuantity!.id,
      LocationTable.columnDeleted: 0,
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

  static Future<Map<String, dynamic>> getCreateValues(
      DisplayLocation location) async {
    Map<String, dynamic> values = await getValues(location);

    values[LocationTable.columnId] = DateTime.now().microsecondsSinceEpoch;
    values[LocationTable.columnDone] = 0;

    return values;
  }

  static Future<Map<String, dynamic>> getUpdateValues(
      DisplayLocation location) async {
    Map<String, dynamic> values = await getValues(location);

    values[LocationTable.columnId] = location.id;
    values[LocationTable.columnDone] = 0;

    return values;
  }
}

class SyncLocation extends DisplayLocation {
  final String userId;
  final int contractId;
  final int initialQuantityId;
  final int currentQuantityId;
  final bool deleted;
  final bool done;

  SyncLocation(
      {required super.id,
      required this.userId,
      required this.contractId,
      required this.initialQuantityId,
      required this.currentQuantityId,
      required this.deleted,
      required this.done,
      required super.lastEdited,
      required super.latitude,
      required super.longitude,
      required super.partieNr,
      super.additionalInfo,
      super.sawmill,
      super.oversizeSawmill,
      super.photoIds,
      super.photoUrls,
      super.shipments});

  static SyncLocation fromMap(Map<String, dynamic> map) {
    return SyncLocation(
        id: map[LocationTable.columnId],
        userId: map[LocationTable.columnUserId],
        contractId: map[LocationTable.columnContractId],
        initialQuantityId: map[LocationTable.columnInitialQuantityId],
        currentQuantityId: map[LocationTable.columnCurrentQuantityId],
        deleted: map[LocationTable.columnDeleted],
        done: map[LocationTable.columnDone],
        lastEdited: DateTime.fromMillisecondsSinceEpoch(
            map[LocationTable.columnLastEdited]),
        latitude: map[LocationTable.columnLatitude],
        longitude: map[LocationTable.columnLongitude],
        partieNr: map[LocationTable.columnPartieNr],
        additionalInfo: map[LocationTable.columnAdditionalInfo],
        sawmill: map[LocationTable.columnSawmill],
        oversizeSawmill: map[LocationTable.columnOversizeSawmill],
        photoIds: decodeJsonList<int>(map[LocationTable.columnPhotoIds]),
        photoUrls: decodeJsonList<String>(map[LocationTable.columnPhotoUrls]));
  }
}

class DisplayShipment {
  final DateTime lastEdited;
  final String? driverName;
  final DisplayContract? contract;
  final String sawmill;
  final Quantity? quantity;

  DisplayShipment(
      {required this.lastEdited,
      this.driverName,
      this.contract,
      required this.sawmill,
      this.quantity});

  static DisplayShipment fromMap(Map<String, dynamic> map, Quantity quantity) {
    DisplayContract contract = DisplayContract.fromMap(map);

    return DisplayShipment(
        lastEdited: DateTime.fromMillisecondsSinceEpoch(
            map[ShipmentTable.columnLastEdited]),
        driverName: map[UserTable.columnName],
        contract: contract,
        sawmill: map[ShipmentTable.columnSawmill],
        quantity: quantity);
  }

  static Future<Map<String, dynamic>> getInserUpdateValues(
      DisplayShipment shipment, int locationId) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> values = {
      ShipmentTable.columnId: DateTime.now().microsecondsSinceEpoch,
      ShipmentTable.columnUserId: prefs.getString('apiKey'),
      ShipmentTable.columnLocationId: locationId,
      ShipmentTable.columnContractId: shipment.contract!.id,
      ShipmentTable.columnQuantityId: shipment.quantity!.id,
      ShipmentTable.columnDeleted: 0,
      ShipmentTable.columnLastEdited: shipment.lastEdited,
      ShipmentTable.columnSawmill: shipment.sawmill
    };

    return values;
  }
}

class SyncShipment extends DisplayShipment {
  final int id;
  final String userId;
  final int locationId;
  final int contractId;
  final int quantityId;
  final bool deleted;

  SyncShipment(
      {required this.id,
      required this.userId,
      required this.locationId,
      required this.contractId,
      required this.quantityId,
      required this.deleted,
      required super.lastEdited,
      required super.sawmill});

  static SyncShipment fromMap(Map<String, dynamic> map) {
    return SyncShipment(
        id: map[ShipmentTable.columnId],
        userId: map[ShipmentTable.columnUserId],
        locationId: map[ShipmentTable.columnLocationId],
        contractId: map[ShipmentTable.columnContractId],
        quantityId: map[ShipmentTable.columnQuantityId],
        deleted: map[ShipmentTable.columnDeleted],
        lastEdited: DateTime.fromMillisecondsSinceEpoch(
            map[ShipmentTable.columnLastEdited]),
        sawmill: map[ShipmentTable.columnSawmill]);
  }

  static Future<Map<String, dynamic>> getValues(SyncShipment shipment) async {
    Map<String, dynamic> values = {
      ShipmentTable.columnId: shipment.id,
      ShipmentTable.columnUserId: shipment.userId,
      ShipmentTable.columnLocationId: shipment.locationId,
      ShipmentTable.columnContractId: shipment.contract!.id,
      ShipmentTable.columnQuantityId: shipment.quantity!.id,
      ShipmentTable.columnDeleted: shipment.deleted,
      ShipmentTable.columnLastEdited: shipment.lastEdited,
      ShipmentTable.columnSawmill: shipment.sawmill
    };

    return values;
  }
}

class DisplayContract {
  final int id;
  final String title;
  final String? additionalInfo;
  final int availableQuantity;
  final int bookedQuantity;
  final int shippedQuantity;

  DisplayContract({
    required this.id,
    required this.title,
    this.additionalInfo,
    required this.availableQuantity,
    required this.bookedQuantity,
    required this.shippedQuantity,
  });

  static DisplayContract fromMap(Map<String, dynamic> map) {
    return DisplayContract(
      id: map[ContractTable.columnId],
      title: map[ContractTable.columnTitle],
      additionalInfo: map[ContractTable.columnAdditionalInfo],
      availableQuantity: map[ContractTable.columnAvailableQuantity],
      bookedQuantity: map[ContractTable.columnBookedQuantity],
      shippedQuantity: map[ContractTable.columnShippedQuantity],
    );
  }

  static Future<Map<String, dynamic>> getInserUpdateValues(
      DisplayContract contract) async {
    final prefs = await SharedPreferences.getInstance();

    Map<String, dynamic> values = {
      ContractTable.columnId: DateTime.now().microsecondsSinceEpoch,
      ContractTable.columnUserId: prefs.getString('apiKey'),
      ContractTable.columnLocationId: locationId,
      ContractTable.columnContractId: shipment.contract!.id,
      ContractTable.columnQuantityId: shipment.quantity!.id,
      ContractTable.columnDeleted: 0,
      ContractTable.columnLastEdited: shipment.lastEdited,
      ContractTable.columnSawmill: shipment.sawmill
    };

    return values;
  }
}

class SyncContract extends DisplayContract {
  final bool deleted;
  final bool done;
  final DateTime lastEdited;

  SyncContract(
      {required super.id,
      required this.deleted,
      required this.done,
      required this.lastEdited,
      required super.title,
      super.additionalInfo,
      required super.availableQuantity,
      required super.bookedQuantity,
      required super.shippedQuantity});

  static SyncContract fromMap(Map<String, dynamic> map) {
    return SyncContract(
      id: map[ContractTable.columnId],
      deleted: map[ContractTable.columnDeleted],
      done: map[ContractTable.columnDone],
      lastEdited: DateTime.fromMillisecondsSinceEpoch(
          map[ContractTable.columnLastEdited]),
      title: map[ContractTable.columnTitle],
      additionalInfo: map[ContractTable.columnAdditionalInfo],
      availableQuantity: map[ContractTable.columnAvailableQuantity],
      bookedQuantity: map[ContractTable.columnBookedQuantity],
      shippedQuantity: map[ContractTable.columnShippedQuantity],
    );
  }
}

class User {
  final String id;
  final bool privileged;
  final DateTime lastEdited;
  final String name;

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
