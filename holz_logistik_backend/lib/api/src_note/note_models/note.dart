import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/api/comment_api.dart';
import 'package:holz_logistik_backend/api/general.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'note.g.dart';

/// {@template note_item}
/// A single `note` item.
///
/// Contains a [id], time of the [lastEdit], [text], [user] and [comments].
///
/// [Note]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Note extends Equatable {
  /// {@macro note_item}
  const Note({
    required this.id,
    required this.lastEdit,
    required this.text,
    required this.user,
    required this.comments,
  });

  /// {@macro note_item}
  Note.empty({
    String? id,
    DateTime? lastEdit,
    this.text = '',
    User? user,
    this.comments = const [],
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now(),
        user = user ?? User.empty();

  /// The id of the `note`.
  ///
  /// Cannot be empty.
  final String id;

  /// The time the `note` was last modified.
  ///
  /// Cannot be empty.
  final DateTime lastEdit;

  /// The text of the `note`.
  ///
  /// Cannot be empty.
  final String text;

  /// The user that wrote the `note`.
  ///
  /// Cannot be empty.
  final User user;

  /// The comments to this `note`.
  ///
  /// Cannot be empty.
  final List<Comment> comments;

  /// Returns a copy of this `note` with the given values updated.
  ///
  /// {@macro note_item}
  Note copyWith({
    String? id,
    DateTime? lastEdit,
    String? text,
    User? user,
    List<Comment>? comments,
  }) {
    return Note(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      text: text ?? this.text,
      user: user ?? this.user,
      comments: comments ?? this.comments,
    );
  }

  /// Deserializes the given [JsonMap] into a [Note].
  static Note fromJson(JsonMap json) => _$NoteFromJson(json);

  /// Converts this [Note] into a [JsonMap].
  JsonMap toJson() => _$NoteToJson(this);

  @override
  List<Object> get props => [id, lastEdit, text, user, comments];
}
