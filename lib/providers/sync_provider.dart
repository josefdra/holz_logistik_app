// lib/providers/sync_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/sync_service.dart';
import '../utils/network_utils.dart';

enum SyncStatus {
  idle,
  syncing,
  error,
  complete,
  offline
}

class SyncProvider extends ChangeNotifier {
  final SyncService _syncService = SyncService();
  SyncStatus _status = SyncStatus.idle;
  String? _lastError;
  DateTime? _lastSyncTime;
  bool _autoSync = true;
  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;

  SyncStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get autoSync => _autoSync;

  SyncProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _syncService.initialize();

    // Set up periodic sync if enabled
    _setupAutoSync();

    // Listen for connectivity changes
    _setupConnectivityListener();
  }

  void _setupAutoSync() {
    if (_autoSync) {
      // Sync every 15 minutes
      _syncTimer?.cancel();
      _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) => sync());
    } else {
      _syncTimer?.cancel();
      _syncTimer = null;
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        // We just got internet, try to sync
        if (_autoSync && _status != SyncStatus.syncing) {
          sync();
        }
      } else {
        // No internet, update status if needed
        if (_status == SyncStatus.syncing) {
          _status = SyncStatus.offline;
          notifyListeners();
        }
      }
    });
  }

  // Toggle auto-sync on/off
  void setAutoSync(bool value) {
    _autoSync = value;
    _setupAutoSync();
    notifyListeners();
  }

  // Manually trigger a sync
  Future<bool> sync() async {
    if (_status == SyncStatus.syncing) {
      return false; // Already syncing
    }

    // Check for internet connection
    final hasConnection = await NetworkUtils.isConnected();
    if (!hasConnection) {
      _status = SyncStatus.offline;
      notifyListeners();
      return false;
    }

    try {
      _status = SyncStatus.syncing;
      _lastError = null;
      notifyListeners();

      final success = await _syncService.syncAll();

      if (success) {
        _status = SyncStatus.complete;
        _lastSyncTime = DateTime.now();
      } else {
        _status = SyncStatus.error;
        _lastError = "Synchronization failed";
      }

      notifyListeners();
      return success;
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}