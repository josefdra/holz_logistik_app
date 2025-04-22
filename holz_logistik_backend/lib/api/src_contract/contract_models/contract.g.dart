// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contract.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contract _$ContractFromJson(Map<String, dynamic> json) => Contract(
      id: json['id'] as String?,
      done: json['done'] == null
          ? false
          : TypeConverters.boolFromInt((json['done'] as num).toInt()),
      lastEdit: _$JsonConverterFromJson<String, DateTime>(
          json['lastEdit'], const DateTimeConverter().fromJson,),
      title: json['title'] as String? ?? '',
      additionalInfo: json['additionalInfo'] as String? ?? '',
      startDate: _$JsonConverterFromJson<String, DateTime>(
          json['startDate'], const DateTimeConverter().fromJson,),
      endDate: _$JsonConverterFromJson<String, DateTime>(
          json['endDate'], const DateTimeConverter().fromJson,),
      availableQuantity: (json['availableQuantity'] as num?)?.toDouble() ?? 0,
      bookedQuantity: (json['bookedQuantity'] as num?)?.toDouble() ?? 0,
      shippedQuantity: (json['shippedQuantity'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$ContractToJson(Contract instance) => <String, dynamic>{
      'id': instance.id,
      'done': TypeConverters.boolToInt(instance.done),
      'lastEdit': const DateTimeConverter().toJson(instance.lastEdit),
      'title': instance.title,
      'additionalInfo': instance.additionalInfo,
      'startDate': const DateTimeConverter().toJson(instance.startDate),
      'endDate': const DateTimeConverter().toJson(instance.endDate),
      'availableQuantity': instance.availableQuantity,
      'bookedQuantity': instance.bookedQuantity,
      'shippedQuantity': instance.shippedQuantity,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
