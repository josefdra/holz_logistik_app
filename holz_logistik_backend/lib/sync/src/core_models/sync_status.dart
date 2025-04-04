/// Defines the possible Sync status the device can be in
enum SyncStatus {
  /// Device is fully synchronized with the server
  synced,

  /// Device is currently synchronizing
  syncing,

  /// Device has changes that need to be synchronized
  pending,

  /// Synchronization failed
  failed,
}
