// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contract _$ContractFromJson(Map<String, dynamic> json) => Contract(
      id: json['id'] as String?,
      // ignore: avoid_bool_literals_in_conditional_expressions
      done: json['done'] == null
          ? false
          : TypeConverters.boolFromInt((json['done'] as num).toInt()),
      lastEdit: json['lastEdit'] == null
          ? null
          : DateTime.parse(json['lastEdit'] as String),
      title: json['title'] as String? ?? '',
      additionalInfo: json['additionalInfo'] as String? ?? '',
      startDate: json['startDate'] == null
          ? null
          : DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      availableQuantity: (json['availableQuantity'] as num?)?.toDouble() ?? 0,
      bookedQuantity: (json['bookedQuantity'] as num?)?.toDouble() ?? 0,
      shippedQuantity: (json['shippedQuantity'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$ContractToJson(Contract instance) => <String, dynamic>{
      'id': instance.id,
      'done': TypeConverters.boolToInt(instance.done),
      'lastEdit': instance.lastEdit.toIso8601String(),
      'title': instance.title,
      'additionalInfo': instance.additionalInfo,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'availableQuantity': instance.availableQuantity,
      'bookedQuantity': instance.bookedQuantity,
      'shippedQuantity': instance.shippedQuantity,
    };
