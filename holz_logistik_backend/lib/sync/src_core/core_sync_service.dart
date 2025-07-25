import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:holz_logistik_backend/general/general.dart';
import 'package:holz_logistik_backend/sync/core_sync_service.dart';
import 'package:rxdart/subjects.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

/// {@template core_sync_service}
/// A flutter implementation of Synchronization service that is usable from
/// specific components.
/// {@endtemplate}
class CoreSyncService {
  /// {@macro core_sync_service}
  CoreSyncService({
    required String url,
  }) : _url = url;

  final String _url;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;

  // Map to store message type to handler mappings
  final Map<String, MessageHandler> _messageHandlers = {};

  // Map to store date getters
  final Map<String, DateGetter> _dateGetters = {};

  // Map to store data getters
  final Map<String, DataGetter> _dataGetters = {};

  // StreamController to broadcast updates on connection
  final _connectionStreamController =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected);

  /// Stream of connection status
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStreamController.stream;

  var _connection = false;
  var _apiKey = '';
  var _missedPongs = 0;
  var _reconnectAttempts = 0;
  static const int _maxMissedPongs = 3;
  static const int _maxReconnectAttempts = 5;
  static const Duration _pingInterval = Duration(seconds: 5);
  static const Duration _pongTimeout = Duration(seconds: 30);
  static const Duration _initialReconnectDelay = Duration(seconds: 2);
  Timer? _pingTimer;
  Timer? _pongTimeoutTimer;
  Timer? _reconnectTimer;

  /// Register a handler for a specific message type
  void registerMessageHandler({
    required String messageType,
    required MessageHandler messageHandler,
  }) {
    _messageHandlers[messageType] = messageHandler;
  }

  /// Register a handler for a specific type
  void registerDateGetter({
    required String type,
    required DateGetter dateGetter,
  }) {
    _dateGetters[type] = dateGetter;
  }

  /// Register a handler for a specific type
  void registerDataGetter({
    required String type,
    required DataGetter dataGetter,
  }) {
    _dataGetters[type] = dataGetter;
  }

  /// Reset missed pongs when a pong is received
  void _resetPongTimeout() {
    _missedPongs = 0;
    _pongTimeoutTimer?.cancel();
  }

  /// Sends data for all registered types
  Future<void> sendSyncData() async {
    for (final key in _dataGetters.keys) {
      final dataList = await _dataGetters[key]!.call();

      for (final data in dataList) {
        final dataCopy = Map<String, dynamic>.from(data)..remove('synced');
        await sendMessage(key, dataCopy);
      }
    }

    return sendMessage('sync_complete', null);
  }

  /// Request a sync for all registered types
  Future<void> sendSyncRequest() async {
    final data = <String, int>{};

    for (final key in _dateGetters.keys) {
      final date = await _dateGetters[key]!.call();
      data[key] = date.toUtc().millisecondsSinceEpoch;
    }

    return sendMessage('sync_request', data);
  }

  /// Handle incoming messages
  void _handleMessage(dynamic rawMessage) {
    if (kDebugMode) {
      print('RAW MESSAGE RECEIVED: $rawMessage');
    }

    try {
      _reconnectAttempts = 0;
      final message = rawMessage is String
          ? jsonDecode(rawMessage) as Map<String, dynamic>
          : rawMessage as Map<String, dynamic>;

      final type = message['type'] as String;
      final dynamic data = message['data'];

      if (type == 'pong') {
        _resetPongTimeout();
        return;
      } else if (type == 'authentication_response') {
        final messageHandler = _messageHandlers[type];
        if (messageHandler != null) {
          messageHandler(data);
        }
        sendSyncData();
      } else if (type == 'sync_to_server_complete') {
        sendSyncRequest();
      } else if (type == 'sync_from_server_complete') {
        _startPingTimer();
        _connectionStreamController.add(ConnectionStatus.synced);
      } else {
        final messageHandler = _messageHandlers[type];
        if (messageHandler != null) {
          messageHandler(data);
        }
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  /// Clean up resources
  void _cleanup() {
    _connection = false;
    _pingTimer?.cancel();
    _pongTimeoutTimer?.cancel();
    _reconnectTimer?.cancel();
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _connectionStreamController.add(ConnectionStatus.disconnected);

    try {
      _channel?.sink.close(status.normalClosure);
    } catch (e) {
      // Ignore errors during cleanup
    }

    _channel = null;
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _connectionStreamController.add(ConnectionStatus.error);
    _connection = false;
    _scheduleReconnect();
  }

  /// Handle WebSocket connection closure
  void _handleDone() {
    debugPrint('WebSocket connection closed');
    _connectionStreamController.add(ConnectionStatus.disconnected);
    _connection = false;
    _scheduleReconnect();
  }

  /// Send a message through the WebSocket
  Future<void> sendMessage(String type, dynamic data) async {
    if (_channel != null) {
      try {
        final message = {
          'type': type,
          'data': data,
          'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
        };

        _channel!.sink.add(jsonEncode(message));
        return Future<void>.value();
      } catch (e) {
        debugPrint('Error sending WebSocket message: $e');
        _connectionStreamController.add(ConnectionStatus.error);
      }
    }

    return Future<void>.value();
  }

  /// Handle pong timeout
  void _handlePongTimeout() {
    _missedPongs++;

    if (_missedPongs >= _maxMissedPongs) {
      debugPrint('WebSocket connection lost: too many missed pongs');
      _cleanup();
    }
  }

  /// Send a ping message and start the pong timeout timer
  void _sendPing() {
    sendMessage('ping', const <String, dynamic>{});

    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = Timer(_pongTimeout, _handlePongTimeout);
  }

  /// Start the ping timer for keep-alive mechanism
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) => _sendPing());
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnection attempts reached');
      return;
    }

    _reconnectTimer?.cancel();

    final delay = _initialReconnectDelay * (1 << _reconnectAttempts);
    debugPrint('Scheduling reconnect attempt in ${delay.inSeconds} seconds');

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  /// Connect to the WebSocket server
  Future<void> _connect() async {
    if (_connection) return Future<void>.value();

    _connection = true;
    _connectionStreamController.add(ConnectionStatus.connecting);

    try {
      final uri = Uri.parse(_url);
      _channel = WebSocketChannel.connect(uri);
      if (_channel != null) {
        await _channel!.ready;

        _channelSubscription = _channel!.stream.listen(
          _handleMessage,
          onError: _handleError,
          onDone: _handleDone,
        );

        await sendMessage('authentication_request', {'apiKey': _apiKey});
        _connectionStreamController.add(ConnectionStatus.connected);
      }
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _connectionStreamController.add(ConnectionStatus.error);
      _scheduleReconnect();
      _connection = false;
    }
  }

  /// Sets up connection
  Future<void> connect({String? apiKey}) async {
    if (apiKey != null) _apiKey = apiKey;

    _cleanup();
    await _connect();
  }

  /// Close the WebSocket connection and clean up resources
  void dispose() {
    _cleanup();
    _connectionStreamController.close();

    try {
      _channel?.sink.close(status.normalClosure);
    } catch (e) {
      // Ignore errors during cleanup
    }

    _channel = null;
    _messageHandlers.clear();
  }
}
