import 'dart:async';

import 'package:holz_logistik_backend/api/shipment_api.dart';
import 'package:holz_logistik_backend/general/general.dart';
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
    _init();
  }

  final ShipmentApi _shipmentApi;
  final ShipmentSyncService _shipmentSyncService;

  /// Provides a [Stream] of shipment updates.
  Stream<Shipment> get shipmentUpdates => _shipmentApi.shipmentUpdates;

  void _init() {
    _shipmentSyncService
      ..registerDateGetter(_shipmentApi.getLastSyncDate)
      ..registerDataGetter(_shipmentApi.getUpdates);
  }

  /// Provides shipments by location.
  Future<List<Shipment>> getShipmentsByLocation(String locationId) =>
      _shipmentApi.getShipmentsByLocation(locationId);

  /// Provides shipments.
  Future<List<Shipment>> getShipmentsByDate(DateTime start, DateTime end) =>
      _shipmentApi.getShipmentsByDate(start, end);

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data.containsKey('newSyncDate')) {
      _shipmentApi.setLastSyncDate(
        DateTime.fromMillisecondsSinceEpoch(
          data['newSyncDate'] as int,
          isUtc: true,
        ),
      );
    } else if (data['deleted'] == true || data['deleted'] == 1) {
      _shipmentApi.deleteShipment(
        id: data['id'] as String,
      );
    } else if (data['synced'] == true || data['synced'] == 1) {
      _shipmentApi.setSynced(id: data['id'] as String);
    } else {
      final shipment = Shipment.fromJson(data);
      _shipmentApi.saveShipment(shipment, fromServer: true);
    }
  }

  /// Saves a [shipment].
  ///
  /// If a [shipment] with the same id already exists, it will be replaced.
  Future<void> saveShipment(Shipment shipment) {
    final updatedShipment = shipment.copyWith(
      quantity: customRound(shipment.quantity),
      oversizeQuantity: customRound(shipment.oversizeQuantity),
      lastEdit: DateTime.now(),
    );
    _shipmentApi.saveShipment(updatedShipment);
    return _shipmentSyncService.sendShipmentUpdate(updatedShipment.toJson());
  }

  /// Deletes the `shipment` with the given id.
  Future<void> deleteShipment({
    required String id,
    required String locationId,
  }) async {
    await _shipmentApi.markShipmentDeleted(id: id, locationId: locationId);
    final data = {
      'id': id,
      'deleted': 1,
      'locationId': locationId,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    };

    return _shipmentSyncService.sendShipmentUpdate(data);
  }

  /// Deletes all `shipment`s for a given locationId.
  Future<void> deleteShipmentsByLocationId(String locationId) async {
    final shipments = await _shipmentApi.getShipmentsByLocation(locationId);

    if (shipments.isNotEmpty) {
      for (final shipment in shipments) {
        await deleteShipment(id: shipment.id, locationId: locationId);
      }
    }

    return Future<void>.value();
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _shipmentApi.close();
}
