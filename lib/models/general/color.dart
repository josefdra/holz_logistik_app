import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

/// Generates a color from a string using SHA-256 hashing
/// The same string will always produce the same color,
/// while different strings will produce different colors
Color colorFromString(String input) {
  // Generate a SHA-256 hash of the input string
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);

  // Get the hex string from the digest
  final hexString = digest.toString();

  // Use different parts of the hash for different color components
  // This helps ensure better distribution of colors
  final red = int.parse(hexString.substring(0, 2), radix: 16);
  final green = int.parse(hexString.substring(2, 4), radix: 16);
  final blue = int.parse(hexString.substring(4, 6), radix: 16);

  // Create a color with the RGB values and full opacity
  return Color.fromARGB(255, red, green, blue);
}
