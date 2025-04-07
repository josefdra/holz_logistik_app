// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      id: json['id'] as String,
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      serverPhotoUrl: json['serverPhotoUrl'] as String,
      localPhotoUrl: json['localPhotoUrl'] as String,
      locationId: json['locationId'] as String,
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': instance.lastEdit.toIso8601String(),
      'serverPhotoUrl': instance.serverPhotoUrl,
      'localPhotoUrl': instance.localPhotoUrl,
      'locationId': instance.locationId,
    };
