import 'dart:convert';

import 'package:holz_logistik/data/tables.dart';

/// --------------------------------------- User --------------------------------------- ///

class User {
  final int id;
  bool privileged;
  String name;

  User({required this.id, required this.privileged, required this.name});

  static User fromMap(Map<String, dynamic> map) {
    return User(
        id: map[UserTable.columnId],
        privileged: map[UserTable.columnPrivileged],
        name: map[UserTable.columnName]);
  }
}

/// --------------------------------------- Contract --------------------------------------- ///

class Contract {
  final int id;
  DateTime lastEdited;
  String title;
  String additionalInfo;
  double availableQuantity;
  double bookedQuantity;
  double shippedQuantity;

  Contract({
    required this.id,
    required this.lastEdited,
    required this.title,
    required this.additionalInfo,
    required this.availableQuantity,
    required this.bookedQuantity,
    required this.shippedQuantity,
  });

  static Contract fromMap(Map<String, dynamic> map) {
    return Contract(
      id: map[ContractTable.columnId],
      lastEdited: DateTime.fromMillisecondsSinceEpoch(
          map[ContractTable.columnLastEdited]),
      title: map[ContractTable.columnTitle],
      additionalInfo: map[ContractTable.columnAdditionalInfo],
      availableQuantity: map[ContractTable.columnAvailable],
      bookedQuantity: map[ContractTable.columnBooked],
      shippedQuantity: map[ContractTable.columnShipped],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      ContractTable.columnId: id,
      ContractTable.columnLastEdited: lastEdited.millisecondsSinceEpoch,
      ContractTable.columnTitle: title,
      ContractTable.columnAdditionalInfo: additionalInfo,
      ContractTable.columnAvailable: availableQuantity,
      ContractTable.columnBooked: bookedQuantity,
      ContractTable.columnShipped: shippedQuantity,
    };

    return map;
  }
}

/// --------------------------------------- Quantity --------------------------------------- ///

class Quantity {
  final int id;
  double normal;
  double oversize;
  int pieceCount;

  Quantity(
      {required this.id,
      required this.normal,
      required this.oversize,
      required this.pieceCount});

  static Quantity fromMap(Map<String, dynamic> map) {
    return Quantity(
      id: map[QuantityTable.columnId],
      normal: map[QuantityTable.columnNormal],
      oversize: map[QuantityTable.columnOversize],
      pieceCount: map[QuantityTable.columnPieceCount],
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      QuantityTable.columnId: id,
      QuantityTable.columnNormal: normal,
      QuantityTable.columnOversize: oversize,
      QuantityTable.columnPieceCount: pieceCount
    };

    return map;
  }
}

/// --------------------------------------- Shipment --------------------------------------- ///

class Shipment {
  final int id;
  final int locationId;
  final int userId;
  final int contractId;
  final int quantityId;
  final String sawmill;
  final DateTime lastEdited;
  late final User? user;
  late final Contract? contract;
  late final Quantity? quantity;

  Shipment(
      {required this.id,
      required this.locationId,
      required this.userId,
      required this.contractId,
      required this.quantityId,
      required this.sawmill,
      required this.lastEdited,
      this.user,
      this.contract,
      this.quantity});

  static Shipment fromMap(Map<String, dynamic> map) {
    return Shipment(
        id: map[ShipmentTable.columnId],
        locationId: map[ShipmentTable.columnLocationId],
        userId: map[ShipmentTable.columnUserId],
        contractId: map[ShipmentTable.columnContractId],
        quantityId: map[ShipmentTable.columnQuantityId],
        sawmill: map[ShipmentTable.columnSawmill],
        lastEdited: DateTime.fromMillisecondsSinceEpoch(
            map[ShipmentTable.columnLastEdited]));
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      ShipmentTable.columnId: id,
      ShipmentTable.columnLocationId: locationId,
      ShipmentTable.columnUserId: userId,
      ShipmentTable.columnContractId: contractId,
      ShipmentTable.columnQuantityId: quantityId,
      ShipmentTable.columnSawmill: sawmill,
      ShipmentTable.columnLastEdited: lastEdited.millisecondsSinceEpoch,
    };

    return map;
  }
}

/// --------------------------------------- Location --------------------------------------- ///

class Location {
  final int id;
  final int contractId;
  final int initQuantityId;
  final int currQuantityId;
  final DateTime lastEdited;
  final double latitude;
  final double longitude;
  String partieNr;
  String additionalInfo;
  String sawmill;
  String oversizeSawmill;
  List<String> photoUrls;
  late final Contract? contract;
  late final Quantity? initialQuantity;
  late final Quantity? currentQuantity;
  late final List<Shipment>? shipments;

  Location(
      {required this.id,
      required this.contractId,
      required this.initQuantityId,
      required this.currQuantityId,
      required this.lastEdited,
      required this.latitude,
      required this.longitude,
      required this.partieNr,
      required this.additionalInfo,
      required this.sawmill,
      required this.oversizeSawmill,
      required this.photoUrls,
      this.contract,
      this.initialQuantity,
      this.currentQuantity,
      this.shipments});

  static Location fromMap(Map<String, dynamic> map) {
    return Location(
        id: map[LocationTable.columnId],
        contractId: map[LocationTable.columnContractId],
        initQuantityId: map[LocationTable.columnInitialQuantityId],
        currQuantityId: map[LocationTable.columnCurrentQuantityId],
        lastEdited: DateTime.fromMillisecondsSinceEpoch(
            map[LocationTable.columnLastEdited]),
        latitude: map[LocationTable.columnLatitude],
        longitude: map[LocationTable.columnLongitude],
        partieNr: map[LocationTable.columnPartieNr],
        additionalInfo: map[LocationTable.columnAdditionalInfo],
        sawmill: map[LocationTable.columnSawmill],
        oversizeSawmill: map[LocationTable.columnOversizeSawmill],
        photoUrls: jsonDecode(map[LocationTable.columnPhotoUrls]));
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      LocationTable.columnId: id,
      LocationTable.columnContractId: contractId,
      LocationTable.columnInitialQuantityId: initQuantityId,
      LocationTable.columnCurrentQuantityId: currQuantityId,
      LocationTable.columnLastEdited: lastEdited.millisecondsSinceEpoch,
      LocationTable.columnLatitude: latitude,
      LocationTable.columnLongitude: longitude,
      LocationTable.columnPartieNr: partieNr,
      LocationTable.columnAdditionalInfo: additionalInfo,
      LocationTable.columnSawmill: sawmill,
      LocationTable.columnOversizeSawmill: oversizeSawmill,
      LocationTable.columnPhotoUrls: jsonEncode(photoUrls),
    };

    return map;
  }
}
