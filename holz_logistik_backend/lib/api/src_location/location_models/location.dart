import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/api/general/models/json_map.dart';
import 'package:holz_logistik_backend/api/location_api.dart';
import 'package:holz_logistik_backend/api/src_contract/contract_models/contract.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'location.g.dart';

/// {@template location_item}
/// A single `location` item.
///
/// Contains a [id], [done], time of the [lastEdit], [latitude], [longitude],
/// [partieNr], [additionalInfo], [initialQuantity], [initialOversizeQuantity],
/// [initialPieceCount], [currentQuantity], [currentOversizeQuantity],
/// [currentPieceCount], [contract].
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
    required this.contract,
  });

  /// The id of the `location`.
  ///
  /// Cannot be empty.
  final int id;

  /// The done status of the `location`.
  ///
  /// Cannot be empty.
  final bool done;

  /// The time the `location` was last modified.
  ///
  /// Cannot be empty.
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
  final Contract contract;

  /// Returns a copy of this `location` with the given values updated.
  ///
  /// {@macro location_item}
  Location copyWith({
    int? id,
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
    Contract? contract,
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
      contract: contract ?? this.contract,
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
        contract,
      ];
}
