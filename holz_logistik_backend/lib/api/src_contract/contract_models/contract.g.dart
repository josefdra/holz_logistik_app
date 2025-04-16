// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contract _$ContractFromJson(Map<String, dynamic> json) => Contract(
      id: json['id'] as String,
      done: TypeConverters.boolFromInt((json['done'] as num).toInt()),
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      title: json['title'] as String,
      additionalInfo: json['additionalInfo'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$ContractToJson(Contract instance) => <String, dynamic>{
      'id': instance.id,
      'done': TypeConverters.boolToInt(instance.done),
      'lastEdit': instance.lastEdit.toIso8601String(),
      'title': instance.title,
      'additionalInfo': instance.additionalInfo,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };
