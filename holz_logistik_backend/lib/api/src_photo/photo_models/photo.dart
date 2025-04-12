import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/models/json.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'photo.g.dart';

/// {@template photo_item}
/// A single `photo` item.
///
/// Contains a [id], time of the [lastEdit], [serverPhotoUrl], [localPhotoUrl]
/// and [locationId].
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
    required this.serverPhotoUrl,
    required this.localPhotoUrl,
    required this.locationId,
  });

  /// {@macro photo_item}
  Photo.empty({
    String? id,
    DateTime? lastEdit,
    this.serverPhotoUrl = '',
    this.localPhotoUrl = '',
    this.locationId = '',
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

  /// The server url of the `photo`.
  ///
  /// Cannot be empty.
  final String serverPhotoUrl;

  /// The local url of the `photo`.
  ///
  /// Cannot be empty.
  final String localPhotoUrl;

  /// The locationId of the `photo`.
  ///
  /// Cannot be empty.
  final String locationId;

  /// Returns a copy of this `photo` with the given values updated.
  ///
  /// {@macro photo_item}
  Photo copyWith({
    String? id,
    DateTime? lastEdit,
    String? serverPhotoUrl,
    String? localPhotoUrl,
    String? locationId,
  }) {
    return Photo(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      serverPhotoUrl: serverPhotoUrl ?? this.serverPhotoUrl,
      localPhotoUrl: localPhotoUrl ?? this.localPhotoUrl,
      locationId: locationId ?? this.locationId,
    );
  }

  /// Deserializes the given [JsonMap] into a [Photo].
  static Photo fromJson(JsonMap json) => _$PhotoFromJson(json);

  /// Converts this [Photo] into a [JsonMap].
  JsonMap toJson() => _$PhotoToJson(this);

  @override
  List<Object> get props =>
      [id, lastEdit, serverPhotoUrl, localPhotoUrl, locationId];
}
