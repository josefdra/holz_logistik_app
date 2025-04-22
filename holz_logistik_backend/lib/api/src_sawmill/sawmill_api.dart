import 'package:holz_logistik_backend/api/sawmill_api.dart';

/// {@template sawmill_api}
/// The interface for an API that provides access to sawmills.
/// {@endtemplate}
abstract class SawmillApi {
  /// {@macro sawmill_api}
  const SawmillApi();

  /// Provides a [Stream] of all sawmills.
  Stream<Map<String, Sawmill>> get sawmills;

  /// Provides the last sync date
  Future<DateTime> getLastSyncDate(String type);

  /// Sets the last sync date
  Future<void> setLastSyncDate(String type, DateTime date);

  /// Gets updates
  Future<List<Map<String, dynamic>>> getUpdates();

  /// Saves or updates a [sawmill].
  ///
  /// If a [sawmill] with the same id already exists, it will be updated.
  Future<void> saveSawmill(Sawmill sawmill);

  /// Deletes the `sawmill` with the given [id].
  Future<void> deleteSawmill(String id);

  /// Closes the client and frees up any resources.
  Future<void> close();
}
