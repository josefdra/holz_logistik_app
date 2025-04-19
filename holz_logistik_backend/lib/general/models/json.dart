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
class Uint8ListConverter implements JsonConverter<Uint8List, List<dynamic>> {
  /// Converts byte list to json
  const Uint8ListConverter();

  @override
  Uint8List fromJson(List<dynamic> json) {
    // Convert the List<dynamic> to List<int> before creating Uint8List
    return Uint8List.fromList(json.cast<int>());
  }

  @override
  List<int> toJson(Uint8List object) {
    return object.toList();
  }
}
