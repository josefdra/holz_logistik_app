import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/api/contract_api.dart';
import 'package:holz_logistik_backend/api/general.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'shipment.g.dart';

/// {@template shipment_item}
/// A single `shipment` item.
///
/// Contains a [id], time of the [lastEdit], [quantity], [oversizeQuantity],
/// [pieceCount], [user] and [contract].
///
/// [Shipment]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Shipment extends Equatable {
  /// {@macro shipment_item}
  const Shipment({
    required this.id,
    required this.lastEdit,
    required this.quantity,
    required this.oversizeQuantity,
    required this.pieceCount,
    required this.user,
    required this.contract,
  });

  /// {@macro shipment_item}
  Shipment.empty({
    String? id,
    DateTime? lastEdit,
    this.quantity = 0.0,
    this.oversizeQuantity = 0.0,
    this.pieceCount = 0,
    User? user,
    Contract? contract,
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now(),
        user = user ?? User.empty(),
        contract = contract ?? Contract.empty();

  /// The id of the `shipment`.
  ///
  /// Cannot be empty.
  final String id;

  /// The time the `shipment` was last modified.
  ///
  /// Cannot be empty.
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

  /// The user that created the `shipment`.
  ///
  /// Cannot be empty.
  final User user;

  /// The name of the `shipment`.
  ///
  /// Cannot be empty.
  final Contract contract;

  /// Returns a copy of this `shipment` with the given values updated.
  ///
  /// {@macro shipment_item}
  Shipment copyWith({
    String? id,
    DateTime? lastEdit,
    double? quantity,
    double? oversizeQuantity,
    int? pieceCount,
    User? user,
    Contract? contract,
  }) {
    return Shipment(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      quantity: quantity ?? this.quantity,
      oversizeQuantity: oversizeQuantity ?? this.oversizeQuantity,
      pieceCount: pieceCount ?? this.pieceCount,
      user: user ?? this.user,
      contract: contract ?? this.contract,
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
        user,
        contract,
      ];
}
