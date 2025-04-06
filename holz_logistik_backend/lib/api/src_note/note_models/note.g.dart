// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      id: (json['id'] as num).toInt(),
      lastEdit: DateTime.parse(json['lastEdit'] as String),
      text: json['text'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': instance.lastEdit.toIso8601String(),
      'text': instance.text,
      'user': instance.user,
    };
