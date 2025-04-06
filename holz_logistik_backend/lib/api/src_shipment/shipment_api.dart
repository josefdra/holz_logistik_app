import 'package:holz_logistik_backend/api/shipment_api.dart';

/// {@template shipment_api}
/// The interface for an API that provides access to shipments.
/// {@endtemplate}
abstract class ShipmentApi {
  /// {@macro shipment_api}
  const ShipmentApi();

  /// Provides a [Stream] of all shipments.
  Stream<List<Shipment>> getShipments();

  /// Saves or updates a [shipment].
  ///
  /// If a [shipment] with the same id already exists, it will be updated.
  Future<void> saveShipment(Shipment shipment);

  /// Deletes the `shipment` with the given [id].
  ///
  /// If no `shipment` with the given id exists, a [ShipmentNotFoundException] 
  /// error is thrown.
  Future<void> deleteShipment(String id);

  /// Closes the client and frees up any resources.
  Future<void> close();
}

/// Error thrown when a [Shipment] with a given id is not found.
class ShipmentNotFoundException implements Exception {}
