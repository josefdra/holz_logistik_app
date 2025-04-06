// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Shipment _$ShipmentFromJson(Map<String, dynamic> json) => Shipment(
      id: json['id'] as String,
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      oversizeQuantity: (json['oversizeQuantity'] as num).toDouble(),
      pieceCount: (json['pieceCount'] as num).toInt(),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      contract: Contract.fromJson(json['contract'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ShipmentToJson(Shipment instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': instance.lastEdit.toIso8601String(),
      'quantity': instance.quantity,
      'oversizeQuantity': instance.oversizeQuantity,
      'pieceCount': instance.pieceCount,
      'user': instance.user,
      'contract': instance.contract,
    };
