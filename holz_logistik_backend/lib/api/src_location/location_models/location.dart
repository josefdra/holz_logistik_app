import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/general.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'location.g.dart';

/// Mixin that implements the [Gettable] interface for Location objects
/// Maps specific location properties to standard sortable properties
mixin LocationSortGettable implements Gettable {
  /// Original location date
  @override
  DateTime get date;

  /// Original location partieNr
  String get partieNr;

  /// Maps [partieNr] to the standardized [name] property
  @override
  String get name => partieNr;
}

/// {@template location_item}
/// A single `location` item.
///
/// Contains a [id], [done], [started], [lastEdit], [latitude], [longitude],
/// [partieNr], [date], [additionalInfo], [initialQuantity],
/// [initialOversizeQuantity], [initialPieceCount], [currentQuantity],
/// [currentOversizeQuantity], [currentPieceCount], [contractId], [sawmillIds]
/// and [oversizeSawmillIds].
///
/// [Location]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Location extends Equatable with LocationSortGettable {
  /// {@macro location_item}
  const Location({
    required this.id,
    required this.done,
    required this.started,
    required this.lastEdit,
    required this.latitude,
    required this.longitude,
    required this.partieNr,
    required this.date,
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
    this.started = false,
    DateTime? lastEdit,
    this.latitude = 0,
    this.longitude = 0,
    this.partieNr = '',
    DateTime? date,
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
        lastEdit = lastEdit ?? DateTime.now(),
        date = date ?? DateTime.now();

  /// {@macro location_item}
  Location.copy({
    required Location location,
  })  : id = location.id,
        done = location.done,
        started = location.started,
        lastEdit = location.lastEdit,
        latitude = location.latitude,
        longitude = location.longitude,
        partieNr = location.partieNr,
        date = location.date,
        additionalInfo = location.additionalInfo,
        initialQuantity = location.initialQuantity,
        initialOversizeQuantity = location.initialOversizeQuantity,
        initialPieceCount = location.initialPieceCount,
        currentQuantity = location.currentQuantity,
        currentOversizeQuantity = location.currentOversizeQuantity,
        currentPieceCount = location.currentPieceCount,
        contractId = location.contractId,
        sawmillIds = location.sawmillIds,
        oversizeSawmillIds = location.oversizeSawmillIds;

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
  @override
  final String partieNr;

  /// The date of the `location`.
  @override
  final DateTime date;

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
    bool? started,
    DateTime? lastEdit,
    double? latitude,
    double? longitude,
    String? partieNr,
    DateTime? date,
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
      started: started ?? this.started,
      lastEdit: lastEdit ?? this.lastEdit,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      partieNr: partieNr ?? this.partieNr,
      date: date ?? this.date,
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
        date,
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
