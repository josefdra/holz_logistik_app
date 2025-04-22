import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/general.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'note.g.dart';

/// Mixin that implements the [Gettable] interface for Note objects
/// Maps specific note properties to standard sortable properties
mixin NoteSortGettable implements Gettable {
  /// Original note date
  DateTime get lastEdit;
  
  /// Original note text
  String get text;
  
  /// Maps [lastEdit] to the standardized [date] property
  @override
  DateTime get date => lastEdit;
  
  /// Maps [text] to the standardized [name] property
  @override
  String get name => text;
}

/// {@template note_item}
/// A single `note` item.
///
/// Contains a [id], time of the [lastEdit], [text] and [userId].
///
/// [Note]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Note extends Equatable with NoteSortGettable {
  /// {@macro note_item}
  Note({
    String? id,
    DateTime? lastEdit,
    this.text = '',
    this.userId = '',
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

  /// The id of the `note`.
  ///
  /// Cannot be empty.
  final String id;

  /// The time the `note` was last modified.
  ///
  /// Cannot be empty.
  @override
  @DateTimeConverter()
  final DateTime lastEdit;

  /// The text of the `note`.
  ///
  /// Cannot be empty.
  @override
  final String text;

  /// The userId that is associated with the `note`.
  ///
  /// Cannot be empty.
  final String userId;

  /// Returns a copy of this `note` with the given values updated.
  ///
  /// {@macro note_item}
  Note copyWith({
    String? id,
    DateTime? lastEdit,
    String? text,
    String? userId,
  }) {
    return Note(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      text: text ?? this.text,
      userId: userId ?? this.userId,
    );
  }

  /// Deserializes the given [JsonMap] into a [Note].
  static Note fromJson(JsonMap json) => _$NoteFromJson(json);

  /// Converts this [Note] into a [JsonMap].
  JsonMap toJson() => _$NoteToJson(this);

  @override
  List<Object> get props => [id, lastEdit, text, userId];
}
