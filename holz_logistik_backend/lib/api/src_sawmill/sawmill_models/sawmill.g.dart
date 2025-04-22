// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sawmill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sawmill _$SawmillFromJson(Map<String, dynamic> json) => Sawmill(
      id: json['id'] as String?,
      lastEdit: _$JsonConverterFromJson<String, DateTime>(
          json['lastEdit'], const DateTimeConverter().fromJson,),
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$SawmillToJson(Sawmill instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': const DateTimeConverter().toJson(instance.lastEdit),
      'name': instance.name,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
