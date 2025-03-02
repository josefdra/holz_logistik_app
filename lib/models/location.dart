import 'dart:io';

class Location {
  final int? id;                // Local database ID
  final String? serverId;       // Server-side ID for sync
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
  final List<File> newPhotos;   // Temporary storage for new photos before saving
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isSynced;          // Flag to track sync status
  final bool isDeleted;         // Soft delete flag for sync

  Location({
    this.id,
    this.serverId,
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
    this.isSynced = false,
    this.isDeleted = false,
  });

  Location copyWith({
    int? id,
    String? serverId,
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
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Location(
      id: id ?? this.id,
      serverId: serverId ?? this.serverId,
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
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
