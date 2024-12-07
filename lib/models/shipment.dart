class Shipment {
  final int? id;
  final int locationId;
  final int? oversizeQuantity;
  final int quantity;
  final int pieceCount;
  final DateTime timestamp;
  final bool isUndone;

  Shipment({
    this.id,
    required this.locationId,
    this.oversizeQuantity,
    required this.quantity,
    required this.pieceCount,
    DateTime? timestamp,
    this.isUndone = false,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'location_id': locationId,
      'oversize_quantity': oversizeQuantity,
      'quantity': quantity,
      'piece_count': pieceCount,
      'timestamp': timestamp.toIso8601String(),
      'is_undone': isUndone ? 1 : 0,
    };
  }

  factory Shipment.fromMap(Map<String, dynamic> map) {
    return Shipment(
      id: map['id'],
      locationId: map['location_id'],
      oversizeQuantity: map['oversize_quantity'],
      quantity: map['quantity'],
      pieceCount: map['piece_count'],
      timestamp: DateTime.parse(map['timestamp']),
      isUndone: map['is_undone'] == 1,
    );
  }

  Shipment copyWith({
    int? id,
    int? locationId,
    int? oversizeQuantity,
    int? quantity,
    int? pieceCount,
    DateTime? timestamp,
    bool? isUndone,
  }) {
    return Shipment(
      id: id ?? this.id,
      locationId: locationId ?? this.locationId,
      oversizeQuantity: oversizeQuantity ?? this.oversizeQuantity,
      quantity: quantity ?? this.quantity,
      pieceCount: pieceCount ?? this.pieceCount,
      timestamp: timestamp ?? this.timestamp,
      isUndone: isUndone ?? this.isUndone,
    );
  }
}