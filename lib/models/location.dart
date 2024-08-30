import 'dart:io';

class Location {
  final int? id;
  final String name;
  final double? latitude;
  final double? longitude;
  final String description;
  final String partNumber;
  final String sawmill;
  final dynamic quantity;
  final int? pieceCount;
  final List<String> photos;
  final List<File> newPhotos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Location({
    this.id,
    required this.name,
    this.latitude,
    this.longitude,
    required this.description,
    required this.partNumber,
    required this.sawmill,
    required this.quantity,
    this.pieceCount,
    this.photos = const [],
    this.newPhotos = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      name: json['name'] ?? '',
      latitude: json['latitude'] != null
          ? double.parse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.parse(json['longitude'].toString())
          : null,
      description: json['description'] ?? '',
      partNumber: json['part_number'] ?? '',
      sawmill: json['sawmill'] ?? '',
      quantity: json['quantity'],
      pieceCount: json['piece_count'] != null
          ? int.parse(json['piece_count'].toString())
          : null,
      photos: List<String>.from(json['photos'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'description': description,
        'part_number': partNumber,
        'sawmill': sawmill,
        'quantity': quantity,
        'piece_count': pieceCount,
        'photos': photos,
      };

  Location copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? description,
    String? partNumber,
    String? sawmill,
    dynamic quantity,
    int? pieceCount,
    List<String>? photos,
    List<File>? newPhotos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Location(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      partNumber: partNumber ?? this.partNumber,
      sawmill: sawmill ?? this.sawmill,
      quantity: quantity ?? this.quantity,
      pieceCount: pieceCount ?? this.pieceCount,
      photos: photos ?? this.photos,
      newPhotos: newPhotos ?? this.newPhotos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
