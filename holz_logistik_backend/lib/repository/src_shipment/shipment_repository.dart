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
  Stream<List<Shipment>> getShipments() => _shipmentApi.getShipments();

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _shipmentApi.deleteShipment(data['id'] as String);
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
  ///
  /// If no `shipment` with the given id exists, a [ShipmentNotFoundException] 
  /// error is thrown.
  Future<void> deleteShipment(String id) {
    _shipmentApi.deleteShipment(id);
    final data = {
      'id': id,
      'deleted': true,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _shipmentSyncService.sendShipmentUpdate(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _shipmentApi.close();
}
