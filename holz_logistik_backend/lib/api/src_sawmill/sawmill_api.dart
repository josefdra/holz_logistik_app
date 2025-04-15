import 'package:holz_logistik_backend/api/sawmill_api.dart';

/// {@template sawmill_api}
/// The interface for an API that provides access to sawmills.
/// {@endtemplate}
abstract class SawmillApi {
  /// {@macro sawmill_api}
  const SawmillApi();

  /// Provides a [Stream] of all sawmills.
  Stream<List<Sawmill>> get sawmills;

  /// Provides all current sawmills
  List<Sawmill> get currentSawmills;

  /// Gets the name by [id]
  Future<String> getNameById(String id);

  /// Saves or updates a [sawmill].
  ///
  /// If a [sawmill] with the same id already exists, it will be updated.
  Future<void> saveSawmill(Sawmill sawmill);

  /// Deletes the `sawmill` with the given [id].
  Future<void> deleteSawmill(String id);

  /// Closes the client and frees up any resources.
  Future<void> close();
}
