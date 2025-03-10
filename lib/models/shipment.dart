class Shipment {
  late int id;
  final String userId;
  final int locationId;
  late DateTime date;
  final String? contract;
  final String? additionalInfo;
  final String sawmill;
  final double? normalQuantity;
  final double? oversizeQuantity;
  final int pieceCount;

  Shipment({
    required this.id,
    required this.userId,
    required this.locationId,
    required this.date,
    this.contract,
    this.additionalInfo,
    required this.sawmill,
    this.normalQuantity,
    this.oversizeQuantity,
    required this.pieceCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'locationId': locationId,
      'date': date.millisecondsSinceEpoch,
      'contract': contract,
      'additionalInfo': additionalInfo,
      'sawmill': sawmill,
      'normalQuantity': normalQuantity,
      'oversizeQuantity': oversizeQuantity,
      'pieceCount': pieceCount,
    };
  }

  factory Shipment.fromMap(Map<String, dynamic> map) {
    return Shipment(
      id: map['id'],
      userId: map['userId'],
      locationId: map['locationId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      contract: map['contract'],
      additionalInfo: map['additionalInfo'],
      sawmill: map['sawmill'],
      normalQuantity: map['normalQuantity'],
      oversizeQuantity: map['oversizeQuantity'],
      pieceCount: map['pieceCount'],
    );
  }

  Shipment copyWith({
    int? id,
    int? version,
    String? userId,
    int? locationId,
    DateTime? date,
    String? contract,
    String? additionalInfo,
    String? sawmill,
    double? normalQuantity,
    double? oversizeQuantity,
    int? pieceCount,
  }) {
    return Shipment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      locationId: locationId ?? this.locationId,
      date: date ?? this.date,
      contract: contract ?? this.contract,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      sawmill: sawmill ?? this.sawmill,
      normalQuantity: normalQuantity ?? this.normalQuantity,
      oversizeQuantity: oversizeQuantity ?? this.oversizeQuantity,
      pieceCount: pieceCount ?? this.pieceCount,
    );
  }
}