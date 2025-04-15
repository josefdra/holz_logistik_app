import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/general.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'contract.g.dart';

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
class Contract extends Equatable {
  /// {@macro contract_item}
  const Contract({
    required this.id,
    required this.done,
    required this.lastEdit,
    required this.title,
    required this.additionalInfo,
  });

  /// {@macro contract_item}
  Contract.empty({
    String? id,
    this.done = false,
    DateTime? lastEdit,
    this.title = '',
    this.additionalInfo = '',
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

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
  final DateTime lastEdit;

  /// The title of the `contract`.
  ///
  /// Cannot be empty.
  final String title;

  /// Additional info of the `contract`.
  ///
  /// Cannot be empty.
  final String additionalInfo;

  /// Returns a copy of this `contract` with the given values updated.
  ///
  /// {@macro contract_item}
  Contract copyWith({
    String? id,
    bool? done,
    DateTime? lastEdit,
    String? title,
    String? additionalInfo,
  }) {
    return Contract(
      id: id ?? this.id,
      done: done ?? this.done,
      lastEdit: lastEdit ?? this.lastEdit,
      title: title ?? this.title,
      additionalInfo: additionalInfo ?? this.additionalInfo,
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
      ];
}
