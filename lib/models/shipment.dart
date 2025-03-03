class Shipment {
  final int? id;
  final String? serverId;
  final int locationId;
  final String? locationServerId;
  final int? oversizeQuantity;
  final int quantity;
  final int pieceCount;
  final DateTime timestamp;
  final bool isUndone;
  final bool isSynced;
  final bool isDeleted;
  final String driverName;

  Shipment({
    this.id,
    this.serverId,
    required this.locationId,
    this.locationServerId,
    this.oversizeQuantity,
    required this.quantity,
    required this.pieceCount,
    DateTime? timestamp,
    this.isUndone = false,
    this.isSynced = false,
    this.isDeleted = false,
    required this.driverName,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'server_id': serverId,
      'location_id': locationId,
      'location_server_id': locationServerId,
      'oversize_quantity': oversizeQuantity,
      'quantity': quantity,
      'piece_count': pieceCount,
      'timestamp': timestamp.toIso8601String(),
      'is_undone': isUndone ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
      'is_deleted': isDeleted ? 1 : 0,
      'driver_name': driverName,
    };
  }

  factory Shipment.fromMap(Map<String, dynamic> map) {
    return Shipment(
      id: map['id'],
      serverId: map['server_id'],
      locationId: map['location_id'],
      locationServerId: map['location_server_id'],
      oversizeQuantity: map['oversize_quantity'],
      quantity: map['quantity'],
      pieceCount: map['piece_count'],
      timestamp: DateTime.parse(map['timestamp']),
      isUndone: map['is_undone'] == 1,
      isSynced: map['is_synced'] == 1,
      isDeleted: map['is_deleted'] == 1,
      driverName: map['driver_name'] ?? '',
    );
  }

  Shipment copyWith({
    int? id,
    String? serverId,
    int? locationId,
    String? locationServerId,
    int? oversizeQuantity,
    int? quantity,
    int? pieceCount,
    DateTime? timestamp,
    bool? isUndone,
    bool? isSynced,
    bool? isDeleted,
    String? driverName,
  }) {
    return Shipment(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
      locationId: locationId ?? this.locationId,
      locationServerId: locationServerId ?? this.locationServerId,
      oversizeQuantity: oversizeQuantity ?? this.oversizeQuantity,
      quantity: quantity ?? this.quantity,
      pieceCount: pieceCount ?? this.pieceCount,
      timestamp: timestamp ?? this.timestamp,
      isUndone: isUndone ?? this.isUndone,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
      driverName: driverName ?? this.driverName,
    );
  }
}