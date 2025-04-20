// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
      id: json['id'] as String?,
      // ignore: avoid_bool_literals_in_conditional_expressions
      done: json['done'] == null
          ? false
          : TypeConverters.boolFromInt((json['done'] as num).toInt()),
      // ignore: avoid_bool_literals_in_conditional_expressions
      started: json['started'] == null
          ? false
          : TypeConverters.boolFromInt((json['started'] as num).toInt()),
      lastEdit: json['lastEdit'] == null
          ? null
          : DateTime.parse(json['lastEdit'] as String),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      partieNr: json['partieNr'] as String? ?? '',
      date:
          json['date'] == null ? null : DateTime.parse(json['date'] as String),
      additionalInfo: json['additionalInfo'] as String? ?? '',
      initialQuantity: (json['initialQuantity'] as num?)?.toDouble() ?? 0,
      initialOversizeQuantity:
          (json['initialOversizeQuantity'] as num?)?.toDouble() ?? 0,
      initialPieceCount: (json['initialPieceCount'] as num?)?.toInt() ?? 0,
      currentQuantity: (json['currentQuantity'] as num?)?.toDouble() ?? 0,
      currentOversizeQuantity:
          (json['currentOversizeQuantity'] as num?)?.toDouble() ?? 0,
      currentPieceCount: (json['currentPieceCount'] as num?)?.toInt() ?? 0,
      contractId: json['contractId'] as String? ?? '',
      sawmillIds: (json['sawmillIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      oversizeSawmillIds: (json['oversizeSawmillIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
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
