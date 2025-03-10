class Location {
  late int id;
  final String userId;
  late DateTime lastEdited;
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'partieNr': partieNr,
      'contract': contract,
      'additionalInfo': additionalInfo,
      'access': access,
      'sawmill': sawmill,
      'oversizeSawmill': oversizeSawmill,
      'normalQuantity': normalQuantity,
      'oversizeQuantity': oversizeQuantity,
      'pieceCount': pieceCount,
      'photoIds': photoIds,
      'photoUrls': photoUrls,
    };
  }

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      id: map['id'],
      userId: map['userId'],
      lastEdited: DateTime.fromMillisecondsSinceEpoch(map['lastEdited']),
      latitude: map['latitude'],
      longitude: map['longitude'],
      partieNr: map['partieNr'],
      contract: map['contract'],
      additionalInfo: map['additionalInfo'],
      access: map['access'],
      sawmill: map['sawmill'],
      oversizeSawmill: map['oversizeSawmill'],
      normalQuantity: map['normalQuantity'],
      oversizeQuantity: map['oversizeQuantity'],
      pieceCount: map['pieceCount'],
      photoIds: List<int>.from(map['photoIds'] ?? []),
      photoUrls: List<String>.from(map['photoUrls'] ?? []),
    );
  }
}