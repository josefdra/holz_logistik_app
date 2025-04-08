import 'package:holz_logistik_backend/api/shipment_api.dart';

/// {@template shipment_api}
/// The interface for an API that provides access to shipments.
/// {@endtemplate}
abstract class ShipmentApi {
  /// {@macro shipment_api}
  const ShipmentApi();

  /// Provides a [Stream] of all shipments as list.
  Stream<List<Shipment>> get shipments;

  /// Provides a [Stream] of all shipments by location.
  Stream<Map<String, List<Shipment>>> get shipmentsByLocation;

  /// Provides all current shipments as list
  List<Shipment> get currentShipments;

  /// Provides all current shipments by location
  Map<String, List<Shipment>> get currentShipmentsByLocation;

  /// Saves or updates a [shipment].
  ///
  /// If a [shipment] with the same id already exists, it will be updated.
  Future<void> saveShipment(Shipment shipment);

  /// Deletes the `shipment` with the given [id] and [locationId].
  Future<void> deleteShipment({required String id, required String locationId});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
