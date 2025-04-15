import 'dart:async';

import 'package:holz_logistik_backend/api/shipment_api.dart';
import 'package:holz_logistik_backend/sync/shipment_sync_service.dart';

/// {@template shipment_repository}
/// A repository that handles `shipment` related requests.
/// {@endtemplate}
class ShipmentRepository {
  /// {@macro shipment_repository}
  ShipmentRepository({
    required ShipmentApi shipmentApi,
    required ShipmentSyncService shipmentSyncService,
  })  : _shipmentApi = shipmentApi,
        _shipmentSyncService = shipmentSyncService {
    _shipmentSyncService.shipmentUpdates.listen(_handleServerUpdate);
  }

  final ShipmentApi _shipmentApi;
  final ShipmentSyncService _shipmentSyncService;

  /// Provides a [Stream] of all shipments.
  Stream<List<Shipment>> get allShipments => _shipmentApi.shipments;

  /// Provides a [Stream] of all shipments by location.
  Stream<Map<String, List<Shipment>>> get shipmentsByLocation =>
      _shipmentApi.shipmentsByLocation;

  /// Provides all current shipments
  List<Shipment> get currentShipments => _shipmentApi.currentShipments;

  /// Provides all current shipments by location
  Map<String, List<Shipment>> get currentShipmentsByLocation =>
      _shipmentApi.currentShipmentsByLocation;

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _shipmentApi.deleteShipment(
        id: data['id'] as String,
        locationId: data['locationId'] as String,
      );
    } else {
      _shipmentApi.saveShipment(Shipment.fromJson(data));
    }
  }

  /// Saves a [shipment].
  ///
  /// If a [shipment] with the same id already exists, it will be replaced.
  Future<void> saveShipment(Shipment shipment) {
    _shipmentApi.saveShipment(shipment);
    return _shipmentSyncService.sendShipmentUpdate(shipment.toJson());
  }

  /// Deletes the `shipment` with the given id.
  Future<void> deleteShipment({
    required String id,
    required String locationId,
  }) {
    _shipmentApi.deleteShipment(id: id, locationId: locationId);
    final data = {
      'id': id,
      'deleted': true,
      'locationId': locationId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _shipmentSyncService.sendShipmentUpdate(data);
  }

  /// Deletes all `shipment`s for a given locationId.
  Future<void> deleteShipmentsByLocationId(String locationId) {
    if (_shipmentApi.currentShipmentsByLocation.containsKey(locationId)) {
      final shipments = List<Shipment>.from(
        _shipmentApi.currentShipmentsByLocation[locationId]!,
      );

      for (final shipment in shipments) {
        deleteShipment(id: shipment.id, locationId: locationId);
      }
    }

    return Future<void>.value();
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _shipmentApi.close();
}
