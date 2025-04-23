import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

/// The type definition for a JSON-serializable [Map].
typedef JsonMap = Map<String, dynamic>;

/// Utility functions for common type conversions
class TypeConverters {
  /// Converts an integer to a boolean.
  /// 0 is considered false, anything else is true.
  static bool boolFromInt(int value) => value != 0;

  /// Converts a boolean to an integer.
  /// true is converted to 1, false to 0.
  // ignore: avoid_positional_boolean_parameters
  static int boolToInt(bool value) => value ? 1 : 0;
}

/// Converts byte list to json
class Uint8ListConverter implements JsonConverter<Uint8List, dynamic> {
  /// Converts byte list to json
  const Uint8ListConverter();

  @override
  Uint8List fromJson(dynamic json) {
    if (json == null) return Uint8List(0);

    if (json is List) {
      return Uint8List.fromList(json.cast<int>());
    } else if (json is Uint8List) {
      return json;
    }

    // Handle database BLOB case
    return json as Uint8List;
  }

  @override
  dynamic toJson(Uint8List object) {
    // For SQLite, return Uint8List directly
    return object;
  }
}

/// Converts DateTime to and from integer timestamps ensuring UTC time
class DateTimeConverter implements JsonConverter<DateTime, int> {
  /// Constructor
  const DateTimeConverter();

  @override
  DateTime fromJson(int json) {
    return DateTime.fromMillisecondsSinceEpoch(json, isUtc: true).toLocal();
  }

  @override
  int toJson(DateTime object) {
    return object.toUtc().millisecondsSinceEpoch;
  }
}
