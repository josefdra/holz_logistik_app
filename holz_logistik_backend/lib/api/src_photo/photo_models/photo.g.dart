// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      id: json['id'] as String?,
      lastEdit: json['lastEdit'] == null
          ? null
          : DateTime.parse(json['lastEdit'] as String),
      photoFile: const Uint8ListConverter().fromJson(json['photoFile']),
      locationId: json['locationId'] as String? ?? '',
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': instance.lastEdit.toIso8601String(),
      'photoFile': const Uint8ListConverter().toJson(instance.photoFile),
      'locationId': instance.locationId,
    };
