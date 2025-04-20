import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/general.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'photo.g.dart';

/// Mixin that implements the [Gettable] interface for Photo objects
/// Maps specific photo properties to standard sortable properties
mixin PhotoSortGettable implements Gettable {
  /// Original photo date
  DateTime get lastEdit;
  
  /// Original photo locationId
  String get locationId;
  
  /// Maps [lastEdit] to the standardized [date] property
  @override
  DateTime get date => lastEdit;
  
  /// Maps [locationId] to the standardized [name] property
  @override
  String get name => locationId;
}

/// {@template photo_item}
/// A single `photo` item.
///
/// Contains a [id], time of the [lastEdit], [photoFile] and [locationId].
///
/// [Photo]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Photo extends Equatable with PhotoSortGettable {
  /// {@macro photo_item}
  Photo({
    String? id,
    DateTime? lastEdit,
    Uint8List? photoFile,
    this.locationId = '',
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now(),
        photoFile = photoFile ?? Uint8List(0);

  /// The id of the `photo`.
  ///
  /// Cannot be empty.
  final String id;

  /// The time the `photo` was last modified.
  ///
  /// Cannot be empty.
  @override
  final DateTime lastEdit;

  /// The photo file.
  ///
  /// Cannot be empty.
  @Uint8ListConverter()
  final Uint8List photoFile;

  /// The locationId of the `photo`.
  ///
  /// Cannot be empty.
  @override
  final String locationId;

  /// Returns a copy of this `photo` with the given values updated.
  ///
  /// {@macro photo_item}
  Photo copyWith({
    String? id,
    DateTime? lastEdit,
    Uint8List? photoFile,
    String? locationId,
  }) {
    return Photo(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      photoFile: photoFile ?? this.photoFile,
      locationId: locationId ?? this.locationId,
    );
  }

  /// Deserializes the given [JsonMap] into a [Photo].
  static Photo fromJson(JsonMap json) => _$PhotoFromJson(json);

  /// Converts this [Photo] into a [JsonMap].
  JsonMap toJson() => _$PhotoToJson(this);

  @override
  List<Object> get props =>
      [id, lastEdit, photoFile, locationId];
}
