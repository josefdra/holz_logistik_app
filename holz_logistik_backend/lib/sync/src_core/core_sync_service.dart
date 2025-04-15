import 'dart:async';
import 'dart:convert';

import 'package:holz_logistik_backend/sync/core_sync_service.dart';
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

  // StreamController to broadcast connection status updates
  final _connectionStatusUpdateController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of connection status updates
  Stream<Map<String, dynamic>> get connectionStatusUpdate =>
      _connectionStatusUpdateController.stream;

  /// Register a handler for a specific message type
  void registerHandler(String messageType, MessageHandler handler) {
    _messageHandlers[messageType] = handler;
  }

  /// Connect to the WebSocket server
  void _connect() {
    try {
      final uri = Uri.parse(_url);
      _channel = WebSocketChannel.connect(uri);

      _channelSubscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
      );
    } catch (e) {
      // Implement reconnection logic here if needed
      _scheduleReconnect();
    }
  }

  /// Handle incoming messages
  void _handleMessage(dynamic rawMessage) {
    try {
      // Parse the message
      final message = rawMessage is String
          ? jsonDecode(rawMessage) as Map<String, dynamic>
          : rawMessage as Map<String, dynamic>;

      // Process with registered handlers
      final type = message['type'] as String;
      final dynamic data = message['data'];

      final handler = _messageHandlers[type];
      if (handler != null) {
        handler(data);
      }
    } catch (e) {
      // print('Error processing message: $e');
    }
  }

  /// Handle WebSocket errors
  void _handleError(dynamic error) {
  }

  /// Handle WebSocket connection close
  void _handleDone() {
    _scheduleReconnect();
  }

  /// Schedule a reconnection attempt
  void _scheduleReconnect() {
    // Implement backoff strategy if needed
    Future.delayed(const Duration(seconds: 5), _connect);
  }

  /// Send a message through the WebSocket
  Future<void> sendMessage(String type, dynamic data) {
    if (_channel != null) {
      try {
        final message = {
          'type': type,
          'data': data,
          'timestamp': DateTime.now().toIso8601String(),
        };

        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        // print('Error sending message: $e');
      }
    }

    return Future<void>.value();
  }

  /// Close the WebSocket connection and clean up resources
  void dispose() {
    _channelSubscription?.cancel();
    _channel?.sink.close(status.normalClosure);
    _messageHandlers.clear();
  }
}
