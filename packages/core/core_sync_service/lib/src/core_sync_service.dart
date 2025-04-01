import 'dart:convert';

import 'package:core_sync_service/core_sync_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// {@template core_sync_service}
/// A flutter implementation of Synchronization service that is usable from specific components.
/// {@endtemplate}
class CoreSyncService {
  /// {@macro core_sync_service}
  factory CoreSyncService() {
    return _instance;
  }

  /// Private constructor
  CoreSyncService._internal();

  static final CoreSyncService _instance = CoreSyncService._internal();

  final String _wsUrl = 'wss://your-api-endpoint.com/ws';

  WebSocketChannel? _channel;

  void _onDone() {
    print('WebSocket connection closed');
  }

  void _onError(dynamic error) {
    print('WebSocket error: $error');
  }

  void _onMessage(dynamic message) {
    try {
      final jsonMap = message is String
          ? jsonDecode(message) as Map<String, dynamic>
          : message as Map<String, dynamic>;

      final wsMessage = WebSocketMessage.fromJson(jsonMap);

      if (wsMessage.type == 'ping') {
        // send(const WebSocketMessage(type: 'pong', data: {}));
      } else {
        //
      }
    } catch (e) {
      print('Error processing message: $e');
    }
  }

  Future<void> _connect() async {
    if (_channel != null) {
      return;
    }

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(_wsUrl),
        pingInterval: const Duration(seconds: 30),
      );

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      print('WebSocket connection failed: $e');
    }
  }

  void _disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void close() {
    _disconnect();
  }
}








/// ======================================= WebSocket Service ======================================= ///

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;

  final String _wsUrl = 'wss://your-api-endpoint.com/ws';

  WebSocketChannel? _channel;
  final _messageController = StreamController<WebSocketMessage>.broadcast();
  final _connectionStatusController =
      BehaviorSubject<SyncStatus>.seeded(SyncStatus.offline);

  final List<WebSocketMessage> _offlineQueue = [];

  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = false;
  bool _wasConnected = false;
  bool _intentionalClosure = false;

  Stream<WebSocketMessage> get messages => _messageController.stream;
  Stream<SyncStatus> get connectionStatus => _connectionStatusController.stream;

  WebSocketService._internal();

  void init() {
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen(_handleConnectivityChange);

    Connectivity().checkConnectivity().then(_handleConnectivityChange);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    _wasConnected = _isConnected;
    _isConnected =
        results.isNotEmpty && results.first != ConnectivityResult.none;

    if (_isConnected && !_wasConnected) {
      connect();
    } else if (!_isConnected && _wasConnected) {
      _connectionStatusController.add(SyncStatus.offline);
      _disconnect(reconnect: false);
    }
  }

  Future<void> connect() async {
    if (_channel != null) {
      return;
    }

    _intentionalClosure = false;
    _connectionStatusController.add(SyncStatus.syncing);

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(_wsUrl),
        pingInterval: const Duration(seconds: 30),
      );

      _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _authenticate();

      _connectionStatusController.add(SyncStatus.synced);

      if (_offlineQueue.isEmpty) {
        _offlineQueue.addAll(await OfflineQueueManager.getQueuedMessages());
      }

      _processOfflineQueue();
    } catch (e) {
      print('WebSocket connection failed: $e');
      _connectionStatusController.add(SyncStatus.failed);

      _scheduleReconnect();
    }
  }

  void _authenticate() {
    send(WebSocketMessage(
      type: 'auth',
      data: {
        'token': 'your-auth-token', // Replace with your actual auth token
      },
    ));
  }

  void _onMessage(dynamic data) {
    try {
      final Map<String, dynamic> message = jsonDecode(data);
      final wsMessage = WebSocketMessage.fromMap(message);

      if (wsMessage.type == 'auth_response') {
        if (wsMessage.data['success'] == true) {
          _requestInitialData();
        } else {
          print('Authentication failed: ${wsMessage.data['message']}');
          _connectionStatusController.add(SyncStatus.failed);
          _disconnect(reconnect: true);
        }
      } else if (wsMessage.type == 'ping') {
        send(WebSocketMessage(type: 'pong', data: {}));
      } else {
        _messageController.add(wsMessage);
      }
    } catch (e) {
      print('Error processing message: $e');
    }
  }

  void _onError(dynamic error) {
    print('WebSocket error: $error');
    _connectionStatusController.add(SyncStatus.failed);
    _disconnect(reconnect: true);
  }

  void _onDone() {
    print('WebSocket connection closed');

    if (!_intentionalClosure) {
      _connectionStatusController.add(SyncStatus.failed);
      _disconnect(reconnect: true);
    }
  }

  void _disconnect({bool reconnect = false}) {
    _channel?.sink.close();
    _channel = null;

    if (reconnect && _isConnected) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    Future.delayed(const Duration(seconds: 2), () {
      if (_isConnected) {
        connect();
      }
    });
  }

  Future<void> _requestInitialData() async {
    final db = DatabaseHelper.instance;

    final userTimestamp =
        await db.getLastSyncTimestamp(SyncTimestampTable.entityUser);
    final contractTimestamp =
        await db.getLastSyncTimestamp(SyncTimestampTable.entityContract);
    final quantityTimestamp =
        await db.getLastSyncTimestamp(SyncTimestampTable.entityQuantity);
    final shipmentTimestamp =
        await db.getLastSyncTimestamp(SyncTimestampTable.entityShipment);
    final locationTimestamp =
        await db.getLastSyncTimestamp(SyncTimestampTable.entityLocation);

    send(WebSocketMessage(
      type: 'sync_request',
      data: {
        'last_sync': {
          'user': userTimestamp,
          'contract': contractTimestamp,
          'quantity': quantityTimestamp,
          'shipment': shipmentTimestamp,
          'location': locationTimestamp,
        }
      },
    ));
  }

  void send(WebSocketMessage message) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(jsonEncode(message.toMap()));
      } catch (e) {
        print('Failed to send message: $e');
        _queueMessageForLater(message);
      }
    } else {
      _queueMessageForLater(message);
    }
  }

  Future<void> _queueMessageForLater(WebSocketMessage message) async {
    _offlineQueue.add(message);
    await OfflineQueueManager.enqueueMessage(message);
    _connectionStatusController.add(SyncStatus.pending);
  }

  Future<void> _processOfflineQueue() async {
    if (_offlineQueue.isEmpty) {
      return;
    }

    _connectionStatusController.add(SyncStatus.syncing);

    final queueCopy = List<WebSocketMessage>.from(_offlineQueue);
    _offlineQueue.clear();

    await OfflineQueueManager.clearQueue();

    for (final message in queueCopy) {
      send(message);
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _connectionStatusController.add(SyncStatus.synced);
  }

  void close() {
    _intentionalClosure = true;
    _messageController.close();
    _connectionStatusController.close();
    _connectivitySubscription.cancel();
    _disconnect(reconnect: false);
  }
}
