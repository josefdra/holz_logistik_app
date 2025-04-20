// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Note _$NoteFromJson(Map<String, dynamic> json) => Note(
      id: json['id'] as String?,
      lastEdit: json['lastEdit'] == null
          ? null
          : DateTime.parse(json['lastEdit'] as String),
      text: json['text'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
    );

Map<String, dynamic> _$NoteToJson(Note instance) => <String, dynamic>{
      'id': instance.id,
      'lastEdit': instance.lastEdit.toIso8601String(),
      'text': instance.text,
      'userId': instance.userId,
    };
