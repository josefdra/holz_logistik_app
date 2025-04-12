import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/models/json.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'location.g.dart';

/// {@template location_item}
/// A single `location` item.
///
/// Contains a [id], [done], [started], [lastEdit], [latitude], [longitude],
/// [partieNr], [additionalInfo], [initialQuantity], [initialOversizeQuantity],
/// [initialPieceCount], [contractId], [sawmillIds] and
/// [oversizeSawmillIds].
///
/// [Location]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Location extends Equatable {
  /// {@macro location_item}
  const Location({
    required this.id,
    required this.done,
    required this.started,
    required this.lastEdit,
    required this.latitude,
    required this.longitude,
    required this.partieNr,
    required this.additionalInfo,
    required this.initialQuantity,
    required this.initialOversizeQuantity,
    required this.initialPieceCount,
    required this.contractId,
    required this.sawmillIds,
    required this.oversizeSawmillIds,
  });

  /// {@macro location_item}
  Location.empty({
    String? id,
    this.done = false,
    this.started = false,
    DateTime? lastEdit,
    this.latitude = 0,
    this.longitude = 0,
    this.partieNr = '',
    this.additionalInfo = '',
    this.initialQuantity = 0,
    this.initialOversizeQuantity = 0,
    this.initialPieceCount = 0,
    this.contractId = '',
    this.sawmillIds = const [],
    this.oversizeSawmillIds = const [],
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

  /// The id of the `location`.
  ///
  /// Cannot be empty.
  final String id;

  /// The done status of the `location`.
  ///
  /// Cannot be empty.
  @JsonKey(
    fromJson: TypeConverters.boolFromInt,
    toJson: TypeConverters.boolToInt,
  )
  final bool done;

  /// The started status of the `location`.
  ///
  /// Cannot be empty.
  @JsonKey(
    fromJson: TypeConverters.boolFromInt,
    toJson: TypeConverters.boolToInt,
  )
  final bool started;

  /// The time the `location` was last modified.
  final DateTime lastEdit;

  /// The latitude of the `location`.
  ///
  /// Cannot be empty.
  final double latitude;

  /// The longitude of the `location`.
  ///
  /// Cannot be empty.
  final double longitude;

  /// The partieNr of the `location`.
  ///
  /// Cannot be empty.
  final String partieNr;

  /// The additional information of the `location`.
  ///
  /// Cannot be empty.
  final String additionalInfo;

  /// The initial quantity of the `location`.
  ///
  /// Cannot be empty.
  final double initialQuantity;

  /// The initial oversize quantity of the `location`.
  ///
  /// Cannot be empty.
  final double initialOversizeQuantity;

  /// The initial piece count of the `location`.
  ///
  /// Cannot be empty.
  final int initialPieceCount;

  /// The contract recommended for the `location`.
  ///
  /// Cannot be empty.
  final String contractId;

  /// The sawmillIds associated with the `location`.
  ///
  /// Cannot be empty.
  final List<String>? sawmillIds;

  /// The oversizeSawmillIds associated with the `location`.
  ///
  /// Cannot be empty.
  final List<String>? oversizeSawmillIds;

  /// Returns a copy of this `location` with the given values updated.
  ///
  /// {@macro location_item}
  Location copyWith({
    String? id,
    bool? done,
    bool? started,
    DateTime? lastEdit,
    double? latitude,
    double? longitude,
    String? partieNr,
    String? additionalInfo,
    double? initialQuantity,
    double? initialOversizeQuantity,
    int? initialPieceCount,
    String? contractId,
    List<String>? sawmillIds,
    List<String>? oversizeSawmillIds,
  }) {
    return Location(
      id: id ?? this.id,
      done: done ?? this.done,
      started: started ?? this.started,
      lastEdit: lastEdit ?? this.lastEdit,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      partieNr: partieNr ?? this.partieNr,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      initialOversizeQuantity:
          initialOversizeQuantity ?? this.initialOversizeQuantity,
      initialPieceCount: initialPieceCount ?? this.initialPieceCount,
      contractId: contractId ?? this.contractId,
      sawmillIds: sawmillIds ?? this.sawmillIds,
      oversizeSawmillIds: oversizeSawmillIds ?? this.oversizeSawmillIds,
    );
  }

  /// Deserializes the given [JsonMap] into a [Location].
  static Location fromJson(JsonMap json) => _$LocationFromJson(json);

  /// Converts this [Location] into a [JsonMap].
  JsonMap toJson() => _$LocationToJson(this);

  @override
  List<Object> get props => [
        id,
        done,
        started,
        lastEdit,
        latitude,
        longitude,
        partieNr,
        additionalInfo,
        initialQuantity,
        initialOversizeQuantity,
        initialPieceCount,
        contractId,
        sawmillIds!,
        oversizeSawmillIds!,
      ];
}
