import 'package:holz_logistik_backend/api/shipment_api.dart';

/// {@template shipment_api}
/// The interface for an API that provides access to shipments.
/// {@endtemplate}
abstract class ShipmentApi {
  /// {@macro shipment_api}
  const ShipmentApi();

  /// Provides updates on shipments.
  Stream<Map<String, dynamic>> get shipmentUpdates;

  /// Provides shipments by location.
  Future<List<Shipment>> getShipmentsByLocation(String locationId);

  /// Provides shipments.
  Future<List<Shipment>> getShipmentsByDate(DateTime start, DateTime end);

  /// Get shipment by id
  Future<Shipment> getShipmentById(String id);

  /// Saves or updates a [shipment].
  ///
  /// If a [shipment] with the same id already exists, it will be updated.
  Future<void> saveShipment(Shipment shipment);

  /// Deletes the `shipment` with the given [id] and [locationId].
  Future<void> deleteShipment({required String id, required String locationId});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
