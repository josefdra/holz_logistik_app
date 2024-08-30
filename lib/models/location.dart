import 'dart:io';

class Location {
  final int? id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final String partNumber;
  final String sawmill;
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
    required this.description,
    required this.partNumber,
    required this.sawmill,
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
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      description: json['description'],
      partNumber: json['part_number'],
      sawmill: json['sawmill'],
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'part_number': partNumber,
      'sawmill': sawmill,
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
    String? description,
    String? partNumber,
    String? sawmill,
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
      description: description ?? this.description,
      partNumber: partNumber ?? this.partNumber,
      sawmill: sawmill ?? this.sawmill,
      quantity: quantity ?? this.quantity,
      pieceCount: pieceCount ?? this.pieceCount,
      photoUrls: photoUrls ?? this.photoUrls,
      newPhotos: newPhotos ?? this.newPhotos,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
