import 'dart:io';

class Location {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String additionalInfo;
  final String access;
  final String partNumber;
  final String sawmill;
  final int? oversizeQuantity;
  final int? quantity;
  final int? pieceCount;
  final List<String> photoUrls;
  final List<File> newPhotos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Location({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.additionalInfo,
    required this.access,
    required this.partNumber,
    required this.sawmill,
    this.oversizeQuantity,
    this.quantity,
    this.pieceCount,
    this.photoUrls = const [],
    this.newPhotos = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'],
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      additionalInfo: json['additional_info'],
      access: json['access'],
      partNumber: json['part_number'],
      sawmill: json['sawmill'],
      oversizeQuantity: json['oversize_quantity'],
      quantity: json['quantity'],
      pieceCount: json['piece_count'],
      photoUrls: List<String>.from(json['photos'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    throw FormatException('Cannot parse $value to double');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'additional_info': additionalInfo,
      'access': access,
      'part_number': partNumber,
      'sawmill': sawmill,
      'oversize_quantity': oversizeQuantity,
      'quantity': quantity,
      'piece_count': pieceCount,
      'photo_urls': photoUrls,
    };
  }

  Location copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? additionalInfo,
    String? access,
    String? partNumber,
    String? sawmill,
    int? oversizeQuantity,
    int? quantity,
    int? pieceCount,
    List<String>? photoUrls,
    List<File>? newPhotos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      access: access ?? this.access,
      partNumber: partNumber ?? this.partNumber,
      sawmill: sawmill ?? this.sawmill,
      oversizeQuantity: oversizeQuantity ?? this.oversizeQuantity,
      quantity: quantity ?? this.quantity,
      pieceCount: pieceCount ?? this.pieceCount,
      photoUrls: photoUrls ?? this.photoUrls,
      newPhotos: newPhotos ?? this.newPhotos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
