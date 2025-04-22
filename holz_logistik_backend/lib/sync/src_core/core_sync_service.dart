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
  }) : _url = url {
    _connect();
  }

  final String _url;
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _channelSubscription;

  // Map to store message type to handler mappings
  final Map<String, MessageHandler> _messageHandlers = {};

  // Map to store date getters
  final Map<String, DateGetter> _dateGetters = {};

  // Map to store date setters
  final Map<String, DateSetter> _dateSetters = {};

  // Map to store data getters
  final Map<String, DataGetter> _dataGetters = {};

  // StreamController to broadcast updates on connection
  final _connectionStreamController =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected);

  /// Stream of connection status
  Stream<ConnectionStatus> get connectionStatus =>
      _connectionStreamController.stream;

  // Ping-pong keep-alive mechanism
  Timer? _pingTimer;
  Timer? _pongTimeoutTimer;
  static const Duration _pingInterval = Duration(seconds: 5);
  static const Duration _pongTimeout = Duration(seconds: 30);
  int _missedPongs = 0;
  static const int _maxMissedPongs = 3;
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  static const int _maxReconnectAttempts = 5;
  static const Duration _initialReconnectDelay = Duration(seconds: 2);
  Timer? _connectionStatusDebounceTimer;
  final _debounceTime = const Duration(seconds: 2);

  void _setConnectionStatus(ConnectionStatus status) {
    _connectionStatusDebounceTimer?.cancel();
    _connectionStatusDebounceTimer = Timer(_debounceTime, () {
      if (!_connectionStreamController.isClosed &&
          _connectionStreamController.value != status) {
        _connectionStreamController.add(status);
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnection attempts reached');
      return;
    }

    _reconnectTimer?.cancel();

    // Exponential backoff
    final delay = _initialReconnectDelay * (1 << _reconnectAttempts);
    debugPrint('Scheduling reconnect attempt in ${delay.inSeconds} seconds');

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      reconnect();
    });
  }

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
  void registerDateSetter({
    required String type,
    required DateSetter dateSetter,
  }) {
    _dateSetters[type] = dateSetter;
  }

  /// Register a handler for a specific type
  void registerDataGetter({
    required String type,
    required DataGetter dataGetter,
  }) {
    _dataGetters[type] = dataGetter;
  }

  /// Connect to the WebSocket server
  Future<void> _connect() async {
    final status = _connectionStreamController.value;
    final connected = !(status == ConnectionStatus.error ||
        status == ConnectionStatus.disconnected);

    if (connected) return Future<void>.value();

    _setConnectionStatus(ConnectionStatus.connecting);

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

        // Start ping-pong keep-alive
        _startPingTimer();

        // Connection successful
        _setConnectionStatus(ConnectionStatus.connected);
      }
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _setConnectionStatus(ConnectionStatus.error);

      // Implement automatic reconnection with backoff
      _scheduleReconnect();
    }
  }

  /// Start the ping timer for keep-alive mechanism
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) => _sendPing());
  }

  /// Send a ping message and start the pong timeout timer
  void _sendPing() {
    sendMessage('ping', const <String, dynamic>{});

    _pongTimeoutTimer?.cancel();
    _pongTimeoutTimer = Timer(_pongTimeout, _handlePongTimeout);
  }

  /// Handle pong timeout
  void _handlePongTimeout() {
    _missedPongs++;

    if (_missedPongs >= _maxMissedPongs) {
      debugPrint('WebSocket connection lost: too many missed pongs');
      _cleanup();
      _setConnectionStatus(ConnectionStatus.disconnected);
    }
  }

  /// Reset missed pongs when a pong is received
  void _resetPongTimeout() {
    _missedPongs = 0;
    _pongTimeoutTimer?.cancel();
  }

  /// Handle incoming messages
  void _handleMessage(dynamic rawMessage) {
    try {
      _reconnectAttempts = 0;
      // Parse the message
      final message = rawMessage is String
          ? jsonDecode(rawMessage) as Map<String, dynamic>
          : rawMessage as Map<String, dynamic>;

      print(message);

      // Process with registered handlers
      final type = message['type'] as String;
      final dynamic data = message['data'];

      // Reset pong timeout if we receive a pong message
      if (type == 'pong') {
        _resetPongTimeout();
      }

      final handler = _messageHandlers[type];
      if (handler != null) {
        handler(data);
      }
    } catch (e) {
      debugPrint('Error handling WebSocket message: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
    debugPrint('WebSocket error: $error');
    _setConnectionStatus(ConnectionStatus.error);
    _cleanup();
  }

  /// Handle WebSocket connection closure
  void _handleDone() {
    debugPrint('WebSocket connection closed');
    _setConnectionStatus(ConnectionStatus.disconnected);
    _cleanup();
  }

  /// Clean up resources
  void _cleanup() {
    _pingTimer?.cancel();
    _pongTimeoutTimer?.cancel();
    _channelSubscription?.cancel();
    _channelSubscription = null;
    _setConnectionStatus(ConnectionStatus.disconnected);

    try {
      _channel?.sink.close(status.normalClosure);
    } catch (e) {
      // Ignore errors during cleanup
    }

    _channel = null;
  }

  /// Send a message through the WebSocket
  Future<void> sendMessage(String type, dynamic data) async {
    if (_channel != null) {
      try {
        final message = {
          'type': type,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        };

        _channel!.sink.add(jsonEncode(message));
        return Future<void>.value();
      } catch (e) {
        debugPrint('Error sending WebSocket message: $e');
        _setConnectionStatus(ConnectionStatus.error);
      }
    }

    return Future<void>.value();
  }

  /// Sends data for all registered types
  Future<void> sendSyncData() async {
    for (final key in _dataGetters.keys) {
      final dataList = await _dataGetters[key]!.call();

      for (final data in dataList) {
        await sendMessage(key, data);
        await _dateSetters[key]!
            .call('toServer', DateTime.parse(data['lastEdit'] as String));
      }
    }

    return sendMessage('sync_complete', null);
  }

  /// Request a sync for all registered types
  Future<void> sendSyncRequest() async {
    final data = <String, String>{};

    for (final key in _dateGetters.keys) {
      final date = await _dateGetters[key]!.call('fromServer');
      data[key] = date.toIso8601String();
    }

    return sendMessage('sync_request', data);
  }

  /// Syncs everything
  Future<void> sync() async {
    await sendSyncData();
    await sendSyncRequest();
  }

  /// Reconnect to the WebSocket server
  void reconnect() {
    _cleanup();
    _connect();
  }

  /// Close the WebSocket connection and clean up resources
  void dispose() {
    _pingTimer?.cancel();
    _pongTimeoutTimer?.cancel();
    _reconnectTimer?.cancel();
    _channelSubscription?.cancel();
    _channelSubscription = null;
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
