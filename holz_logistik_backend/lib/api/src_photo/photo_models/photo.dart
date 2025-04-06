import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/models/json_map.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'photo.g.dart';

/// {@template photo_item}
/// A single `photo` item.
///
/// Contains a [id], time of the [lastEdit] and [localPhotoUrl].
///
/// [Photo]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Photo extends Equatable {
  /// {@macro photo_item}
  const Photo({
    required this.id,
    required this.lastEdit,
    required this.localPhotoUrl,
  });

  /// {@macro photo_item}
  Photo.empty({
    String? id,
    DateTime? lastEdit,
    this.localPhotoUrl = '',
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

  /// The id of the `photo`.
  ///
  /// Cannot be empty.
  final String id;

  /// The time the `photo` was last modified.
  ///
  /// Cannot be empty.
  final DateTime lastEdit;

  /// The local url of the `photo`.
  ///
  /// Cannot be empty.
  final String localPhotoUrl;

  /// Returns a copy of this `photo` with the given values updated.
  ///
  /// {@macro photo_item}
  Photo copyWith({
    String? id,
    DateTime? lastEdit,
    String? localPhotoUrl,
  }) {
    return Photo(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      localPhotoUrl: localPhotoUrl ?? this.localPhotoUrl,
    );
  }

  /// Deserializes the given [JsonMap] into a [Photo].
  static Photo fromJson(JsonMap json) => _$PhotoFromJson(json);

  /// Converts this [Photo] into a [JsonMap].
  JsonMap toJson() => _$PhotoToJson(this);

  @override
  List<Object> get props => [id, lastEdit, localPhotoUrl];
}
