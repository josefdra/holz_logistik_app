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
  final List<File> newPhotos;  // Temporary storage for new photos before saving
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Location({
    this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.additionalInfo = '',
    this.access = '',
    this.partNumber = '',
    this.sawmill = '',
    this.oversizeQuantity,
    this.quantity,
    this.pieceCount,
    this.photoUrls = const [],
    this.newPhotos = const [],
    this.createdAt,
    this.updatedAt,
  });

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