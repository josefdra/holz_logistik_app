import 'dart:async';

import 'package:flutter/foundation.dart';

import '../utils/offline_sync_manager.dart';

class BackgroundSyncService {
  Timer? _timer;

  void startPeriodicSync() {
    // Sync every 15 minutes
    _timer = Timer.periodic(Duration(minutes: 15), (_) => _sync());
  }

  void stopPeriodicSync() {
    _timer?.cancel();
  }

  Future<void> _sync() async {
    try {
      await OfflineSyncManager.syncOfflineLocations();
      debugPrint('Background sync completed successfully');
    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  }
}
