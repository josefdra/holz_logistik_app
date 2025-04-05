import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/api/general/models/json_map.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'sawmill.g.dart';

/// {@template sawmill_item}
/// A single `sawmill` item.
///
/// Contains a [id], time of the [lastEdit] and [name].
///
/// [Sawmill]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Sawmill extends Equatable {
  /// {@macro sawmill_item}
  const Sawmill({
    required this.id,
    required this.lastEdit,
    required this.name,
  });

  /// The id of the `sawmill`.
  ///
  /// Cannot be empty.
  final int id;

  /// The time the `sawmill` was last modified.
  ///
  /// Cannot be empty.
  final DateTime lastEdit;

  /// The name of the `sawmill`.
  ///
  /// Cannot be empty.
  final String name;

  /// Returns a copy of this `sawmill` with the given values updated.
  ///
  /// {@macro sawmill_item}
  Sawmill copyWith({
    int? id,
    DateTime? lastEdit,
    String? name,
  }) {
    return Sawmill(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      name: name ?? this.name,
    );
  }

  /// Deserializes the given [JsonMap] into a [Sawmill].
  static Sawmill fromJson(JsonMap json) => _$SawmillFromJson(json);

  /// Converts this [Sawmill] into a [JsonMap].
  JsonMap toJson() => _$SawmillToJson(this);

  @override
  List<Object> get props => [id, lastEdit, name];
}
