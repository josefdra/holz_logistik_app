// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: json['id'] as String,
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      text: json['text'] as String,
      userId: json['userId'] as String,
      noteId: json['noteId'] as String,
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': instance.lastEdit.toIso8601String(),
      'text': instance.text,
      'userId': instance.userId,
      'noteId': instance.noteId,
    };
