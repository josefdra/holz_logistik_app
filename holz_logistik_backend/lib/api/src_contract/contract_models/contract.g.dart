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
      availableQuantity: (json['availableQuantity'] as num).toDouble(),
      bookedQuantity: (json['bookedQuantity'] as num).toDouble(),
      shippedQuantity: (json['shippedQuantity'] as num).toDouble(),
    );

Map<String, dynamic> _$ContractToJson(Contract instance) => <String, dynamic>{
      'id': instance.id,
      'done': TypeConverters.boolToInt(instance.done),
      'lastEdit': instance.lastEdit.toIso8601String(),
      'title': instance.title,
      'additionalInfo': instance.additionalInfo,
      'availableQuantity': instance.availableQuantity,
      'bookedQuantity': instance.bookedQuantity,
      'shippedQuantity': instance.shippedQuantity,
    };
