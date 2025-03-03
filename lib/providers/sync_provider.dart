import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  String _baseUrl = '';
  bool _syncInProgress = false;

  SyncStatus get status => _status;
  String? get lastError => _lastError;
  DateTime? get lastSyncTime => _lastSyncTime;
  bool get autoSync => _autoSync;

  SyncProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _loadSettings(); // Load settings first
      await _syncService.initialize();

      // Add error handling and logging
      print("SyncProvider initialized: BaseURL = $_baseUrl");
    } catch (e) {
      print("SyncProvider initialization error: $e");
      // Ensure some default state
      _baseUrl = '';
    }

    // Rest of your initialization code
    _setupAutoSync();
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

  void _setupAutoSync() {
    _syncTimer?.cancel();
    if (_autoSync) {
      _syncTimer = Timer.periodic(const Duration(minutes: 15), (_) => sync());
    }
  }

  void _setupConnectivityListener() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        if (_autoSync && _status != SyncStatus.syncing) {
          sync();
        }
      } else if (_status == SyncStatus.syncing) {
        _status = SyncStatus.offline;
        notifyListeners();
      }
    });
  }

  void setAutoSync(bool value) {
    _autoSync = value;
    _setupAutoSync();
    notifyListeners();
  }

  Future<bool> sync() async {
    if (_syncInProgress || _status == SyncStatus.syncing) {
      return false;
    }

    try {
      _syncInProgress = true;
      _status = SyncStatus.syncing;
      _lastError = null;
      notifyListeners();

      if (_baseUrl.isNotEmpty) {
        try {
          final testResponse = await http.get(
            Uri.parse('$_baseUrl/api_status.php'),
          ).timeout(const Duration(seconds: 10));

          if (testResponse.statusCode != 200) {
            throw Exception("Server returned status code: ${testResponse.statusCode}");
          }
        } catch (e) {
          _status = SyncStatus.error;
          _lastError = "Cannot connect to server: $e";
          notifyListeners();
          _syncInProgress = false;
          return false;
        }
      }

      final success = await _syncService.syncAll();

      _status = success ? SyncStatus.complete : SyncStatus.error;
      if (success) {
        _lastSyncTime = DateTime.now();
      } else {
        _lastError = "Synchronization failed";
      }

      notifyListeners();
      _syncInProgress = false;
      return success;
    } catch (e) {
      _status = SyncStatus.error;
      _lastError = e.toString();
      notifyListeners();
      _syncInProgress = false;
      return false;
    }
  }

  Future<void> syncAfterChange() async {
    if (_autoSync && await NetworkUtils.isConnected()) {
      sync();
    }
  }

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