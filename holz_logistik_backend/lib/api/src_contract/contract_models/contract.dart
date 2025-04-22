import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/general.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'contract.g.dart';

/// Mixin that implements the [Gettable] interface for Contract objects
/// Maps specific contract properties to standard sortable properties
mixin ContractSortGettable implements Gettable {
  /// Original contract edit timestamp
  DateTime get lastEdit;

  /// Original contract title
  String get title;

  /// Maps [lastEdit] to the standardized [date] property
  @override
  DateTime get date => lastEdit;

  /// Maps [title] to the standardized [name] property
  @override
  String get name => title;
}

/// {@template contract_item}
/// A single `contract` item.
///
/// Contains a [id], the [done] status, time of the [lastEdit], the [title],
/// [additionalInfo].
///
/// [Contract]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Contract extends Equatable with ContractSortGettable {
  /// {@macro contract_item}
  Contract({
    String? id,
    this.done = false,
    DateTime? lastEdit,
    this.title = '',
    this.additionalInfo = '',
    DateTime? startDate,
    DateTime? endDate,
    this.availableQuantity = 0,
    this.bookedQuantity = 0,
    this.shippedQuantity = 0,
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now(),
        startDate = startDate ?? DateTime.now(),
        endDate = endDate ?? DateTime.now();

  /// The id of the `contract`.
  ///
  /// Cannot be empty.
  final String id;

  /// If the contract is done.
  ///
  /// Cannot be empty.
  @JsonKey(
    fromJson: TypeConverters.boolFromInt,
    toJson: TypeConverters.boolToInt,
  )
  final bool done;

  /// The time the `contract` was last modified.
  ///
  /// Cannot be empty.
  @override
  @DateTimeConverter()
  final DateTime lastEdit;

  /// The title of the `contract`.
  ///
  /// Cannot be empty.
  @override
  final String title;

  /// Additional info of the `contract`.
  ///
  /// Cannot be empty.
  final String additionalInfo;

  /// Start date of the `contract`.
  ///
  /// Cannot be empty.
  @DateTimeConverter()
  final DateTime startDate;

  /// End date of the `contract`.
  ///
  /// Cannot be empty.
  @DateTimeConverter()
  final DateTime endDate;

  /// The available quantity of the `contract`.
  ///
  /// Cannot be empty.
  final double availableQuantity;

  /// The booked quantity of the `contract`.
  ///
  /// Cannot be empty.
  final double bookedQuantity;

  /// The shipped quantity of the `contract`.
  ///
  /// Cannot be empty.
  final double shippedQuantity;

  /// Returns a copy of this `contract` with the given values updated.
  ///
  /// {@macro contract_item}
  Contract copyWith({
    String? id,
    bool? done,
    DateTime? lastEdit,
    String? title,
    String? additionalInfo,
    DateTime? startDate,
    DateTime? endDate,
    double? availableQuantity,
    double? bookedQuantity,
    double? shippedQuantity,
  }) {
    return Contract(
      id: id ?? this.id,
      done: done ?? this.done,
      lastEdit: lastEdit ?? this.lastEdit,
      title: title ?? this.title,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      availableQuantity: availableQuantity ?? this.availableQuantity,
      bookedQuantity: bookedQuantity ?? this.bookedQuantity,
      shippedQuantity: shippedQuantity ?? this.shippedQuantity,
    );
  }

  /// Deserializes the given [JsonMap] into a [Contract].
  static Contract fromJson(JsonMap json) => _$ContractFromJson(json);

  /// Converts this [Contract] into a [JsonMap].
  JsonMap toJson() => _$ContractToJson(this);

  @override
  List<Object> get props => [
        id,
        done,
        lastEdit,
        title,
        additionalInfo,
        startDate,
        endDate,
        availableQuantity,
        bookedQuantity,
        shippedQuantity,
      ];
}
