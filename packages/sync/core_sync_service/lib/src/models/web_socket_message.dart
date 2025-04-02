import 'package:core_sync_service/core_sync_service.dart';
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';

part 'web_socket_message.g.dart';

/// {@template web_socket_message}
/// Contains a [type] and [data].
///
/// [WebSocketMessage]s can be serialized and deserialized using [toJson] 
/// and [fromJson]
/// respectively.
/// {@endtemplate}
@immutable
@JsonSerializable()
class WebSocketMessage {
  /// {@macro web_socket_message}
  const WebSocketMessage({required this.type, required this.data});

  /// The type of the `webSocketMessage`.
  ///
  /// Cannot be empty.
  final String type;

  /// The data of the `webSocketMessage`.
  ///
  /// Cannot be empty.
  final Map<String, dynamic> data;

  /// Deserializes the given [JsonMap] into a [WebSocketMessage].
  static WebSocketMessage fromJson(JsonMap json) =>
      _$WebSocketMessageFromJson(json);

  /// Converts this [WebSocketMessage] into a [JsonMap].
  JsonMap toJson() => _$WebSocketMessageToJson(this);
}
