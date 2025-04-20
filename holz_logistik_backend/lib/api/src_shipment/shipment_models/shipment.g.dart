// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shipment _$ShipmentFromJson(Map<String, dynamic> json) => Shipment(
      id: json['id'] as String?,
      lastEdit: json['lastEdit'] == null
          ? null
          : DateTime.parse(json['lastEdit'] as String),
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
      'lastEdit': instance.lastEdit.toIso8601String(),
      'quantity': instance.quantity,
      'oversizeQuantity': instance.oversizeQuantity,
      'pieceCount': instance.pieceCount,
      'userId': instance.userId,
      'contractId': instance.contractId,
      'sawmillId': instance.sawmillId,
      'locationId': instance.locationId,
    };
