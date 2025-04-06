import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/api/general.dart';
import 'package:holz_logistik_backend/api/src_note/note_models/note.dart';
import 'package:holz_logistik_backend/api/user_api.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'comment.g.dart';

/// {@template comment_item}
/// A single `comment` item.
///
/// Contains a [id], time of the [lastEdit], [text], [user] and the [note].
///
/// [Comment]s are immutable and can be copied using [copyWith], in addition to
/// being serialized and deserialized using [toJson] and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class Comment extends Equatable {
  /// {@macro comment_item}
  const Comment({
    required this.id,
    required this.lastEdit,
    required this.text,
    required this.user,
    required this.note,
  });

  /// {@macro comment_item}
  Comment.empty({
    String? id,
    DateTime? lastEdit,
    this.text = '',
    User? user,
    Note? note,
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now(),
        user = user ?? User.empty(),
        note = note ?? Note.empty();

  /// The id of the `comment`.
  ///
  /// Cannot be empty.
  final String id;

  /// The time the `comment` was last modified.
  ///
  /// Cannot be empty.
  final DateTime lastEdit;

  /// The text of the `comment`.
  ///
  /// Cannot be empty.
  final String text;

  /// The user that wrote the `comment`.
  ///
  /// Cannot be empty.
  final User user;

  /// The note the `comment` is associated with.
  ///
  /// Cannot be empty.
  final Note note;

  /// Returns a copy of this `comment` with the given values updated.
  ///
  /// {@macro comment_item}
  Comment copyWith({
    String? id,
    DateTime? lastEdit,
    String? text,
    User? user,
    Note? note,
  }) {
    return Comment(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      text: text ?? this.text,
      user: user ?? this.user,
      note: note ?? this.note,
    );
  }

  /// Deserializes the given [JsonMap] into a [Comment].
  static Comment fromJson(JsonMap json) => _$CommentFromJson(json);

  /// Converts this [Comment] into a [JsonMap].
  JsonMap toJson() => _$CommentToJson(this);

  @override
  List<Object> get props => [id, lastEdit, text, user, note];
}
