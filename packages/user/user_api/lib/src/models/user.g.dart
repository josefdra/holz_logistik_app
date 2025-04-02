// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num).toInt(),
      role: $enumDecode(_$RoleEnumMap, json['role']),
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      name: json['name'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'role': _$RoleEnumMap[instance.role],
      'lastEdit': instance.lastEdit.toIso8601String(),
      'name': instance.name,
    };

const _$RoleEnumMap = {
  Role.basic: 0,
  Role.privileged: 1,
};
