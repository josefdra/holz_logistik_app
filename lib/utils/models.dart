class Location {
  late int id;
  final String userId;
  late DateTime lastEdited;
  final int deleted;
  final double latitude;
  final double longitude;
  final String partieNr;
  final String? contract;
  final String? additionalInfo;
  final String? access;
  final String? sawmill;
  final String? oversizeSawmill;
  final double? normalQuantity;
  final double? oversizeQuantity;
  final int pieceCount;
  final List<int>? photoIds;
  final List<String>? photoUrls;

  Location({
    required this.id,
    required this.userId,
    required this.lastEdited,
    this.deleted = 0,
    required this.latitude,
    required this.longitude,
    required this.partieNr,
    this.contract,
    this.additionalInfo,
    this.access,
    this.sawmill,
    this.oversizeSawmill,
    this.normalQuantity,
    this.oversizeQuantity,
    required this.pieceCount,
    this.photoIds,
    this.photoUrls,
  });

  Location copyWith({
    int? id,
    String? userId,
    DateTime? lastEdited,
    int? deleted,
    double? latitude,
    double? longitude,
    String? partieNr,
    String? contract,
    String? additionalInfo,
    String? access,
    String? sawmill,
    String? oversizeSawmill,
    double? normalQuantity,
    double? oversizeQuantity,
    int? pieceCount,
    List<int>? photoIds,
    List<String>? photoUrls,
  }) {
    return Location(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      lastEdited: lastEdited ?? this.lastEdited,
      deleted: deleted ?? this.deleted,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      partieNr: partieNr ?? this.partieNr,
      contract: contract ?? this.contract,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      access: access ?? this.access,
      sawmill: sawmill ?? this.sawmill,
      oversizeSawmill: oversizeSawmill ?? this.oversizeSawmill,
      normalQuantity: normalQuantity ?? this.normalQuantity,
      oversizeQuantity: oversizeQuantity ?? this.oversizeQuantity,
      pieceCount: pieceCount ?? this.pieceCount,
      photoIds: photoIds ?? this.photoIds,
      photoUrls: photoUrls ?? this.photoUrls,
    );
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      userId: map['userId'],
      lastEdited: DateTime.parse(map['lastEdited']),
      deleted: map['deleted'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      partieNr: map['partieNr'],
      contract: map['contract'],
      additionalInfo: map['additionalInfo'],
      access: map['access'],
      sawmill: map['sawmill'],
      oversizeSawmill: map['oversizeSawmill'],
      normalQuantity: (map['normalQuantity'] ?? 0).toDouble(),
      oversizeQuantity: (map['oversizeQuantity'] ?? 0).toDouble(),
      pieceCount: map['pieceCount'],
      photoIds: List<int>.from(map['photoIds'] ?? []),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
    );
  }
}

class Shipment {
  late int id;
  final String userId;
  final int locationId;
  late DateTime date;
  late String? name;
  final int deleted;
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
    this.name,
    this.deleted = 0,
    this.contract,
    this.additionalInfo,
    required this.sawmill,
    this.normalQuantity,
    this.oversizeQuantity,
    required this.pieceCount,
  });

  factory Shipment.fromMap(Map<String, dynamic> map) {
    return Shipment(
      id: map['id'],
      userId: map['userId'],
      locationId: map['locationId'],
      date: DateTime.parse(map['date']),
      deleted: map['deleted'],
      contract: map['contract'],
      additionalInfo: map['additionalInfo'],
      sawmill: map['sawmill'],
      normalQuantity: (map['normalQuantity'] ?? 0).toDouble(),
      oversizeQuantity: (map['oversizeQuantity'] ?? 0).toDouble(),
      pieceCount: map['pieceCount'],
    );
  }

  Shipment copyWith({
    int? id,
    int? version,
    String? userId,
    int? locationId,
    DateTime? date,
    int? deleted,
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
      deleted: deleted ?? this.deleted,
      contract: contract ?? this.contract,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      sawmill: sawmill ?? this.sawmill,
      normalQuantity: normalQuantity ?? this.normalQuantity,
      oversizeQuantity: oversizeQuantity ?? this.oversizeQuantity,
      pieceCount: pieceCount ?? this.pieceCount,
    );
  }
}

class User {
  final String id;
  final String name;

  User({
    required this.id,
    required this.name,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name']
    );
  }
}
