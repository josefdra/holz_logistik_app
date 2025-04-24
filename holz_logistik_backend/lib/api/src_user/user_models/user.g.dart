// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String?,
      role: $enumDecodeNullable(_$RoleEnumMap, json['role']) ?? Role.basic,
      lastEdit: _$JsonConverterFromJson<int, DateTime>(
          json['lastEdit'], const DateTimeConverter().fromJson,),
      name: json['name'] as String? ?? '',
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'role': _$RoleEnumMap[instance.role],
      'lastEdit': const DateTimeConverter().toJson(instance.lastEdit),
      'name': instance.name,
    };

const _$RoleEnumMap = {
  Role.basic: 0,
  Role.privileged: 1,
  Role.admin: 2,
};

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
