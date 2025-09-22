import 'package:holz_logistik_backend/api/shipment_api.dart';

/// {@template shipment_api}
/// The interface for an API that provides access to shipments.
/// {@endtemplate}
abstract class ShipmentApi {
  /// {@macro shipment_api}
  const ShipmentApi();

  /// Provides updates on shipments.
  Stream<Shipment> get shipmentUpdates;

  /// Gets the active database name
  String get dbName;

  /// Provides the last sync date
  Future<DateTime> getLastSyncDate();

  /// Sets the last sync date
  Future<void> setLastSyncDate(String dbName, DateTime date);

  /// Gets updates
  Future<List<Map<String, dynamic>>> getUpdates();

  /// Provides shipments by location.
  Future<List<Shipment>> getShipmentsByLocation(String locationId);

  /// Provides shipments.
  Future<List<Shipment>> getShipmentsByDate(DateTime start, DateTime end);

  /// Get shipment by id
  Future<Shipment> getShipmentById(String id);

  /// Saves or updates a [shipment].
  ///
  /// If a [shipment] with the same id already exists, it will be updated.
  Future<void> saveShipment(
    Shipment shipment, {
    bool fromServer = false,
    String? dbName,
  });

  /// Marks a `shipment` with the given [id] and [locationId] as deleted.
  Future<void> markShipmentDeleted({
    required String id,
    required String locationId,
  });

  /// Deletes the `shipment` with the given [id].
  Future<void> deleteShipment({required String id, required String dbName});

  /// Sets synced
  Future<void> setSynced({required String id, required String dbName});

  /// Closes the client and frees up any resources.
  Future<void> close();
}
