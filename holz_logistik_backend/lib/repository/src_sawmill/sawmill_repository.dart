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
    _init();
  }

  final SawmillApi _sawmillApi;
  final SawmillSyncService _sawmillSyncService;

  /// Provides a [Stream] of all sawmills.
  Stream<Map<String, Sawmill>> get sawmills => _sawmillApi.sawmills;

  void _init() {
    _sawmillSyncService
      ..registerDateGetter(_sawmillApi.getLastSyncDate)
      ..registerDataGetter(_sawmillApi.getUpdates);
  }

  /// Handle updates from Server
  void _handleServerUpdate(Map<String, dynamic> data) {
    if (data.containsKey('newSyncDate')) {
      _sawmillApi.setLastSyncDate(
        DateTime.fromMillisecondsSinceEpoch(
          data['newSyncDate'] as int,
          isUtc: true,
        ),
      );
    } else if (data['deleted'] == true || data['deleted'] == 1) {
      _sawmillApi.deleteSawmill(
        id: data['id'] as String,
      );
    } else if (data['synced'] == true || data['synced'] == 1) {
      _sawmillApi.setSynced(id: data['id'] as String);
    } else {
      final sawmill = Sawmill.fromJson(data);
      _sawmillApi.saveSawmill(sawmill, fromServer: true);
    }
  }

  /// Saves a [sawmill].
  ///
  /// If a [sawmill] with the same id already exists, it will be replaced.
  Future<void> saveSawmill(Sawmill sawmill) {
    final s = sawmill.copyWith(lastEdit: DateTime.now());
    _sawmillApi.saveSawmill(s);
    return _sawmillSyncService.sendSawmillUpdate(s.toJson());
  }

  /// Deletes the `sawmill` with the given id.
  Future<void> deleteSawmill(String id) {
    _sawmillApi.markSawmillDeleted(id: id);
    final data = {
      'id': id,
      'deleted': 1,
      'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
    };

    return _sawmillSyncService.sendSawmillUpdate(data);
  }

  /// Disposes any resources managed by the repository.
  void dispose() => _sawmillApi.close();
}
