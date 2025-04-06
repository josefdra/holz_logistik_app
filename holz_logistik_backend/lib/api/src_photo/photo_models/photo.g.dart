// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      id: (json['id'] as num).toInt(),
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      localPhotoUrl: json['localPhotoUrl'] as String,
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': instance.lastEdit.toIso8601String(),
      'localPhotoUrl': instance.localPhotoUrl,
    };
