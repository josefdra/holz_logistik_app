// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sawmill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Sawmill _$SawmillFromJson(Map<String, dynamic> json) => Sawmill(
      id: json['id'] as String,
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      name: json['name'] as String,
    );

Map<String, dynamic> _$SawmillToJson(Sawmill instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': instance.lastEdit.toIso8601String(),
      'name': instance.name,
    };
