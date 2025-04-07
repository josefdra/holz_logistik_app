import 'dart:async';

import 'package:holz_logistik_backend/api/sawmill_api.dart';
import 'package:holz_logistik_backend/sync/sawmill_sync_service.dart';

/// {@template sawmill_repository}
/// A repository that handles `sawmill` related requests.
/// {@endtemplate}
class SawmillRepository {
  /// {@macro sawmill_repository}
  SawmillRepository({
    required SawmillApi sawmillApi,
    required SawmillSyncService sawmillSyncService,
  })  : _sawmillApi = sawmillApi,
        _sawmillSyncService = sawmillSyncService {
    _sawmillSyncService.sawmillUpdates.listen(_handleServerUpdate);
  }

  final SawmillApi _sawmillApi;
  final SawmillSyncService _sawmillSyncService;

  /// Provides a [Stream] of all sawmills.
  Stream<List<Sawmill>> getSawmills() => _sawmillApi.sawmills;

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data['deleted'] == true || data['deleted'] == 1) {
      _sawmillApi.deleteSawmill(data['id'] as String);
    } else {
      _sawmillApi.saveSawmill(Sawmill.fromJson(data));
    }
  }

  /// Saves a [sawmill].
  ///
  /// If a [sawmill] with the same id already exists, it will be replaced.
  Future<void> saveSawmill(Sawmill sawmill) {
    _sawmillApi.saveSawmill(sawmill);
    return _sawmillSyncService.sendSawmillUpdate(sawmill.toJson());
  }

  /// Deletes the `sawmill` with the given id.
  ///
  /// If no `sawmill` with the given id exists, a [SawmillNotFoundException] 
  /// error is thrown.
  Future<void> deleteSawmill(String id) {
    _sawmillApi.deleteSawmill(id);
    final data = {
      'id': id,
      'deleted': true,
      'timestamp': DateTime.now().toIso8601String(),
    };

    return _sawmillSyncService.sendSawmillUpdate(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _sawmillApi.close();
}
