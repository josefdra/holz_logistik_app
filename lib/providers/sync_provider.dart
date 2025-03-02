// lib/providers/sync_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http; // Add this import
import 'package:shared_preferences/shared_preferences.dart'; // Add this import
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
  String _baseUrl = ''; // Add this field

  SyncStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get autoSync => _autoSync;

  SyncProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _loadSettings(); // Load settings first
    await _syncService.initialize();

    // Set up periodic sync if enabled
    _setupAutoSync();

    // Listen for connectivity changes
    _setupConnectivityListener();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _baseUrl = prefs.getString('server_url') ?? '';
      if (_baseUrl.endsWith('/')) {
        _baseUrl = _baseUrl.substring(0, _baseUrl.length - 1);
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<String> _getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_key') ?? '';
  }

  void _setupAutoSync() {
    if (_autoSync) {
      // Keep the periodic sync (every 15 minutes) as a failsafe
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

      // Test server connection first (if URL is set)
      if (_baseUrl.isNotEmpty) {
        try {
          final testResponse = await http.get(
            Uri.parse('$_baseUrl/api_status.php'),
          ).timeout(const Duration(seconds: 10));

          debugPrint("API status response: ${testResponse.statusCode}");

          if (testResponse.statusCode != 200) {
            throw Exception("Server returned status code: ${testResponse.statusCode}");
          }
        } catch (e) {
          debugPrint("API connection test failed: $e");
          _status = SyncStatus.error;
          _lastError = "Cannot connect to server: $e";
          notifyListeners();
          return false;
        }
      }

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

  // NEW METHOD: Sync after data changes
  // This method should be called whenever data is created/updated/deleted
  Future<void> syncAfterChange() async {
    if (_autoSync && await NetworkUtils.isConnected()) {
      sync();
    }
  }

  // NEW METHOD: Sync when app is reopened
  Future<void> syncOnAppResume() async {
    if (_autoSync && await NetworkUtils.isConnected()) {
      sync();
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}