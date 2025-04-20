/// Defines the possible Sync status the device can be in
enum ConnectionStatus {
  /// The device is disconnected
  disconnected,

  /// The device is connecting
  connecting,

  /// The device is connected
  connected,

  /// The device is reconnecting
  reconnecting,

  /// There is an error with the connection
  error,
}

/// A callback type for handling connection state changes
typedef ConnectionStatusCallback = void Function(ConnectionStatus state);
