import 'package:equatable/equatable.dart';
import 'package:holz_logistik_backend/general/general.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

part 'comment.g.dart';

/// {@template comment_item}
/// A single `comment` item.
///
/// Contains a [id], time of the [lastEdit], [text], [userId] and the [noteId].
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
    required this.userId,
    required this.noteId,
  });

  /// {@macro comment_item}
  Comment.empty({
    String? id,
    DateTime? lastEdit,
    this.text = '',
    this.userId = '',
    this.noteId = '',
  })  : id = id ?? const Uuid().v4(),
        lastEdit = lastEdit ?? DateTime.now();

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

  /// The userId the `comment` is associated with.
  ///
  /// Cannot be empty.
  final String userId;

  /// The noteId the `comment` is associated with.
  ///
  /// Cannot be empty.
  final String noteId;

  /// Returns a copy of this `comment` with the given values updated.
  ///
  /// {@macro comment_item}
  Comment copyWith({
    String? id,
    DateTime? lastEdit,
    String? text,
    String? userId,
    String? noteId,
  }) {
    return Comment(
      id: id ?? this.id,
      lastEdit: lastEdit ?? this.lastEdit,
      text: text ?? this.text,
      userId: userId ?? this.userId,
      noteId: noteId ?? this.noteId,
    );
  }

  /// Deserializes the given [JsonMap] into a [Comment].
  static Comment fromJson(JsonMap json) => _$CommentFromJson(json);

  /// Converts this [Comment] into a [JsonMap].
  JsonMap toJson() => _$CommentToJson(this);

  @override
  List<Object> get props => [id, lastEdit, text, userId, noteId];
}
