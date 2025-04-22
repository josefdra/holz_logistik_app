import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/general.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'shipment.g.dart';

/// Mixin that implements the [Gettable] interface for Shipment objects
/// Maps specific shipment properties to standard sortable properties
mixin ShipmentSortGettable implements Gettable {
  /// Original shipment date
  DateTime get lastEdit;

  /// Original shipment locationId
  String get locationId;

  /// Maps [lastEdit] to the standardized [date] property
  @override
  DateTime get date => lastEdit;

  /// Maps [locationId] to the standardized [name] property
  @override
  String get name => locationId;
}

/// {@template shipment_item}
/// A single `shipment` item.
///
/// Contains a [id], time of the [lastEdit], [quantity], [oversizeQuantity],
/// [pieceCount], [userId], [contractId], [sawmillId] and [locationId].
///
/// [Shipment]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Shipment extends Equatable with ShipmentSortGettable {
  /// {@macro shipment_item}
  Shipment({
    String? id,
    DateTime? lastEdit,
    this.quantity = 0.0,
    this.oversizeQuantity = 0.0,
    this.pieceCount = 0,
    this.userId = '',
    this.contractId = '',
    this.sawmillId = '',
    this.locationId = '',
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

  /// The id of the `shipment`.
  ///
  /// Cannot be empty.
  final String id;

  /// The time the `shipment` was last modified.
  ///
  /// Cannot be empty.
  @override
  @DateTimeConverter()
  final DateTime lastEdit;

  /// The quantity of the `shipment`.
  ///
  /// Cannot be empty.
  final double quantity;

  /// The oversize quantity of the `shipment`.
  ///
  /// Cannot be empty.
  final double oversizeQuantity;

  /// The piece count of the `shipment`.
  ///
  /// Cannot be empty.
  final int pieceCount;

  /// The userId of the `shipment`.
  ///
  /// Cannot be empty.
  final String userId;

  /// The contractId of the `shipment`.
  ///
  /// Cannot be empty.
  final String contractId;

  /// The sawmillId of the `shipment`.
  ///
  /// Cannot be empty.
  final String sawmillId;

  /// The locationId of the `shipment`.
  ///
  /// Cannot be empty.
  @override
  final String locationId;

  /// Returns a copy of this `shipment` with the given values updated.
  ///
  /// {@macro shipment_item}
  Shipment copyWith({
    String? id,
    DateTime? lastEdit,
    double? quantity,
    double? oversizeQuantity,
    int? pieceCount,
    String? userId,
    String? contractId,
    String? sawmillId,
    String? locationId,
  }) {
    return Shipment(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      quantity: quantity ?? this.quantity,
      oversizeQuantity: oversizeQuantity ?? this.oversizeQuantity,
      pieceCount: pieceCount ?? this.pieceCount,
      userId: userId ?? this.userId,
      contractId: contractId ?? this.contractId,
      sawmillId: sawmillId ?? this.sawmillId,
      locationId: locationId ?? this.locationId,
    );
  }

  /// Deserializes the given [JsonMap] into a [Shipment].
  static Shipment fromJson(JsonMap json) => _$ShipmentFromJson(json);

  /// Converts this [Shipment] into a [JsonMap].
  JsonMap toJson() => _$ShipmentToJson(this);

  @override
  List<Object> get props => [
        id,
        lastEdit,
        quantity,
        oversizeQuantity,
        pieceCount,
        userId,
        contractId,
        sawmillId,
        locationId,
      ];
}
