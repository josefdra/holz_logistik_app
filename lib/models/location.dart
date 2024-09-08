import 'dart:io';

class Location {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String additional_info;
  final String access;
  final String partNumber;
  final String sawmill;
  final int? oversize_quantity;
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
    required this.additional_info,
    required this.access,
    required this.partNumber,
    required this.sawmill,
    this.oversize_quantity,
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
      additional_info: json['additional_info'],
      access: json['access'],
      partNumber: json['part_number'],
      sawmill: json['sawmill'],
      oversize_quantity: json['oversize_quantity'],
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
      'additional_info': additional_info,
      'access': access,
      'part_number': partNumber,
      'sawmill': sawmill,
      'oversize_quantity': oversize_quantity,
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
    String? additional_info,
    String? access,
    String? partNumber,
    String? sawmill,
    int? oversize_quantity,
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
      additional_info: additional_info ?? this.additional_info,
      access: access ?? this.access,
      partNumber: partNumber ?? this.partNumber,
      sawmill: sawmill ?? this.sawmill,
      oversize_quantity: oversize_quantity ?? this.oversize_quantity,
      quantity: quantity ?? this.quantity,
      pieceCount: pieceCount ?? this.pieceCount,
      photoUrls: photoUrls ?? this.photoUrls,
      newPhotos: newPhotos ?? this.newPhotos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
