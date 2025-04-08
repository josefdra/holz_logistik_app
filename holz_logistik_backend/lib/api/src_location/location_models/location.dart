import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/models/json_map.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'location.g.dart';

/// {@template location_item}
/// A single `location` item.
///
/// Contains a [id], [done], time of the [lastEdit], [latitude], [longitude],
/// [partieNr], [additionalInfo], [initialQuantity], [initialOversizeQuantity],
/// [initialPieceCount], [currentQuantity], [currentOversizeQuantity],
/// [currentPieceCount], [contractId], [sawmillIds] and 
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
    required this.lastEdit,
    required this.latitude,
    required this.longitude,
    required this.partieNr,
    required this.additionalInfo,
    required this.initialQuantity,
    required this.initialOversizeQuantity,
    required this.initialPieceCount,
    required this.currentQuantity,
    required this.currentOversizeQuantity,
    required this.currentPieceCount,
    required this.contractId,
    required this.sawmillIds,
    required this.oversizeSawmillIds,
  });

  /// {@macro location_item}
  Location.empty({
    String? id,
    this.done = false,
    DateTime? lastEdit,
    this.latitude = 0,
    this.longitude = 0,
    this.partieNr = '',
    this.additionalInfo = '',
    this.initialQuantity = 0,
    this.initialOversizeQuantity = 0,
    this.initialPieceCount = 0,
    this.currentQuantity = 0,
    this.currentOversizeQuantity = 0,
    this.currentPieceCount = 0,
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
    fromJson: _boolFromInt,
    toJson: _boolToInt,
  )
  final bool done;

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

  /// The current quantity of the `location`.
  ///
  /// Cannot be empty.
  final double currentQuantity;

  /// The current oversize quantity of the `location`.
  ///
  /// Cannot be empty.
  final double currentOversizeQuantity;

  /// The current piece count of the `location`.
  ///
  /// Cannot be empty.
  final int currentPieceCount;

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
    DateTime? lastEdit,
    double? latitude,
    double? longitude,
    String? partieNr,
    String? additionalInfo,
    double? initialQuantity,
    double? initialOversizeQuantity,
    int? initialPieceCount,
    double? currentQuantity,
    double? currentOversizeQuantity,
    int? currentPieceCount,
    String? contractId,
    List<String>? sawmillIds,
    List<String>? oversizeSawmillIds,
  }) {
    return Location(
      id: id ?? this.id,
      done: done ?? this.done,
      lastEdit: lastEdit ?? this.lastEdit,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      partieNr: partieNr ?? this.partieNr,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      initialOversizeQuantity:
          initialOversizeQuantity ?? this.initialOversizeQuantity,
      initialPieceCount: initialPieceCount ?? this.initialPieceCount,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      currentOversizeQuantity:
          currentOversizeQuantity ?? this.currentOversizeQuantity,
      currentPieceCount: currentPieceCount ?? this.currentPieceCount,
      contractId: contractId ?? this.contractId,
      sawmillIds: sawmillIds ?? this.sawmillIds,
      oversizeSawmillIds:
          oversizeSawmillIds ?? this.oversizeSawmillIds,
    );
  }

  /// Deserializes the given [JsonMap] into a [Location].
  static Location fromJson(JsonMap json) => _$LocationFromJson(json);

  /// Converts this [Location] into a [JsonMap].
  JsonMap toJson() => _$LocationToJson(this);

  /// Converts an integer to a boolean.
  /// 0 is considered false, anything else is true.
  static bool _boolFromInt(int value) => value != 0;

  /// Converts a boolean to an integer.
  /// true is converted to 1, false to 0.
  static int _boolToInt(bool value) => value ? 1 : 0;

  @override
  List<Object> get props => [
        id,
        done,
        lastEdit,
        latitude,
        longitude,
        partieNr,
        additionalInfo,
        initialQuantity,
        initialOversizeQuantity,
        initialPieceCount,
        currentQuantity,
        currentOversizeQuantity,
        currentPieceCount,
        contractId,
        sawmillIds!,
        oversizeSawmillIds!,
      ];
}
