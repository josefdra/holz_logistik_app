// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Photo _$PhotoFromJson(Map<String, dynamic> json) => Photo(
      id: json['id'] as String?,
      lastEdit: _$JsonConverterFromJson<int, DateTime>(
          json['lastEdit'], const DateTimeConverter().fromJson,),
      photoFile: const Uint8ListConverter().fromJson(json['photoFile']),
      locationId: json['locationId'] as String? ?? '',
    );

Map<String, dynamic> _$PhotoToJson(Photo instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': const DateTimeConverter().toJson(instance.lastEdit),
      'photoFile': const Uint8ListConverter().toJson(instance.photoFile),
      'locationId': instance.locationId,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
