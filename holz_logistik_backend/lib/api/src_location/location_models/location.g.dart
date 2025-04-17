// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      id: json['id'] as String,
      done: TypeConverters.boolFromInt((json['done'] as num).toInt()),
      started: TypeConverters.boolFromInt((json['started'] as num).toInt()),
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      partieNr: json['partieNr'] as String,
      date: DateTime.parse(json['date'] as String),
      additionalInfo: json['additionalInfo'] as String,
      initialQuantity: (json['initialQuantity'] as num).toDouble(),
      initialOversizeQuantity:
          (json['initialOversizeQuantity'] as num).toDouble(),
      initialPieceCount: (json['initialPieceCount'] as num).toInt(),
      currentQuantity: (json['currentQuantity'] as num).toDouble(),
      currentOversizeQuantity:
          (json['currentOversizeQuantity'] as num).toDouble(),
      currentPieceCount: (json['currentPieceCount'] as num).toInt(),
      contractId: json['contractId'] as String,
      sawmillIds: (json['sawmillIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      oversizeSawmillIds: (json['oversizeSawmillIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'id': instance.id,
      'done': TypeConverters.boolToInt(instance.done),
      'started': TypeConverters.boolToInt(instance.started),
      'lastEdit': instance.lastEdit.toIso8601String(),
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'partieNr': instance.partieNr,
      'date': instance.date.toIso8601String(),
      'additionalInfo': instance.additionalInfo,
      'initialQuantity': instance.initialQuantity,
      'initialOversizeQuantity': instance.initialOversizeQuantity,
      'initialPieceCount': instance.initialPieceCount,
      'currentQuantity': instance.currentQuantity,
      'currentOversizeQuantity': instance.currentOversizeQuantity,
      'currentPieceCount': instance.currentPieceCount,
      'contractId': instance.contractId,
      'sawmillIds': instance.sawmillIds,
      'oversizeSawmillIds': instance.oversizeSawmillIds,
    };
