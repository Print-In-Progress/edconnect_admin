import 'package:flutter/material.dart';

/// Utility class for generating and managing consistent colors for data visualization
/// following Material Design and Tailwind color principles
class ColorGenerator {
  static final Map<String, Color> _colorCache = {};

  static const Color yesColor = Color(0xFF34D399);
  static const Color noColor = Color(0xFFFF6B6B);

  static const List<Color> categorical = [
    Color(0xFF60A5FA), // Blue
    Color(0xFF34D399), // Emerald
    Color(0xFFF472B6), // Pink
    Color(0xFFFBBF24), // Amber
    Color(0xFFA78BFA), // Purple
    Color(0xFF94A3B8), // Slate
    Color(0xFF4ADE80), // Green
    Color(0xFFFF6B6B), // Red
    Color(0xFF38BDF8), // Sky
    Color(0xFFAF7AB3), // Mauve
  ];

  /// Gets a deterministic color for a parameter value based on parameter name and value
  static Color getColor(
    String parameterName,
    String value, {
    bool isDarkMode = false,
    bool isBinary = false,
  }) {
    // Create a unique key for this parameter-value combination
    final key = '$parameterName:$value';

    if (isBinary) {
      final baseColor = value.toLowerCase() == 'yes' ? yesColor : noColor;
      return isDarkMode ? _adjustColorForDarkMode(baseColor) : baseColor;
    }

    if (!_colorCache.containsKey(key)) {
      // Get next available color
      final colorIndex = _colorCache.length % categorical.length;
      _colorCache[key] = categorical[colorIndex];
    }

    final baseColor = _colorCache[key]!;

    if (isDarkMode) {
      return _adjustColorForDarkMode(baseColor);
    }
    return baseColor;
  }

  /// Gets a background color for a parameter based on its main color
  static Color getBackgroundColor(Color baseColor, {bool isDarkMode = false}) {
    return baseColor.withValues(alpha: isDarkMode ? 0.15 : 0.1);
  }

  /// Gets a muted version of the color for secondary elements
  static Color getMutedColor(Color baseColor, {bool isDarkMode = false}) {
    if (isDarkMode) {
      return HSLColor.fromColor(baseColor)
          .withLightness(
              (HSLColor.fromColor(baseColor).lightness * 0.8).clamp(0.0, 1.0))
          .toColor();
    }
    return HSLColor.fromColor(baseColor)
        .withLightness(
            (HSLColor.fromColor(baseColor).lightness * 1.2).clamp(0.0, 1.0))
        .toColor();
  }

  /// Adjusts a color to be more visible in dark mode
  static Color _adjustColorForDarkMode(Color color) {
    final hslColor = HSLColor.fromColor(color);
    return hslColor
        .withLightness((hslColor.lightness + 0.1).clamp(0.0, 1.0))
        .withSaturation((hslColor.saturation - 0.1).clamp(0.0, 1.0))
        .toColor();
  }
}
