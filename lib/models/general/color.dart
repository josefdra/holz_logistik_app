import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

/// Generates a color from a string using SHA-256 hashing
/// The same string will always produce the same color,
/// while different strings will produce different colors
Color colorFromString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);

  // Get the hex string from the digest
  final hexString = digest.toString();

  // Use a portion of the hash to create a hue (0-360)
  final hue = int.parse(hexString.substring(0, 3), radix: 16) % 360;

  // Determine whether to use a "light" or "dark" variant based on another portion of the hash
  // This creates more variety in the colors while maintaining visibility
  final useLightVariant =
      int.parse(hexString.substring(6, 8), radix: 16) % 2 == 0;

  // For map visibility, we want:
  // - High saturation (makes colors pop against gray/neutral map backgrounds)
  // - Brightness that contrasts with typical map elements
  double saturation = 1.0;
  double brightness = useLightVariant ? 1.0 : 0.7;

  // Maps often have greens, blues, and beiges/tans
  // Adjust saturation and brightness based on the hue to improve visibility
  if (hue >= 70 && hue <= 170) {
    // For greens (common in maps), boost brightness to make them more visible
    brightness = useLightVariant ? 1.0 : 0.8;
    saturation = 0.9;
  } else if (hue >= 180 && hue <= 260) {
    // For blues (water in maps), increase saturation and adjust brightness
    saturation = 1.0;
    brightness = useLightVariant ? 0.95 : 0.6;
  }

  // Convert HSV to a color with the specified opacity
  return HSVColor.fromAHSV(1, hue.toDouble(), saturation, brightness).toColor();
}
