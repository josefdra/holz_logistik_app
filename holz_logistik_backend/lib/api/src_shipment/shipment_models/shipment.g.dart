// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shipment _$ShipmentFromJson(Map<String, dynamic> json) => Shipment(
      id: json['id'] as String?,
      lastEdit: _$JsonConverterFromJson<int, DateTime>(
          json['lastEdit'], const DateTimeConverter().fromJson),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      oversizeQuantity: (json['oversizeQuantity'] as num?)?.toDouble() ?? 0.0,
      pieceCount: (json['pieceCount'] as num?)?.toInt() ?? 0,
      userId: json['userId'] as String? ?? '',
      contractId: json['contractId'] as String? ?? '',
      sawmillId: json['sawmillId'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
    );

Map<String, dynamic> _$ShipmentToJson(Shipment instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': const DateTimeConverter().toJson(instance.lastEdit),
      'quantity': instance.quantity,
      'oversizeQuantity': instance.oversizeQuantity,
      'pieceCount': instance.pieceCount,
      'userId': instance.userId,
      'contractId': instance.contractId,
      'sawmillId': instance.sawmillId,
      'locationId': instance.locationId,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);
