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
