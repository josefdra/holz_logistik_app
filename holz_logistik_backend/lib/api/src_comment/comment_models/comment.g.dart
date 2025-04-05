// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Comment _$CommentFromJson(Map<String, dynamic> json) => Comment(
      id: (json['id'] as num).toInt(),
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      text: json['text'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      note: Note.fromJson(json['note'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommentToJson(Comment instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': instance.lastEdit.toIso8601String(),
      'text': instance.text,
      'user': instance.user,
      'note': instance.note,
    };
