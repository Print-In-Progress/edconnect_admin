import 'package:flutter/material.dart';

abstract class ThemeRepository {
  /// Get current theme mode
  Future<bool> isDarkMode();

  /// Save theme mode preference
  Future<void> setDarkMode(bool isDark);

  /// Get application colors
  Future<ColorPair> getColors();

  /// Save application colors
  Future<void> setColors({required Color primary, required Color secondary});

  /// Get logo link
  Future<String> getLogoLink();

  /// Save logo link
  Future<void> setLogoLink(String url);

  /// Get customer name
  Future<String> getCustomerName();

  /// Save customer name
  Future<void> setCustomerName(String name);

  /// Check if theme settings need refreshing from remote source
  Future<bool> needsRemoteRefresh();

  /// Mark theme as refreshed
  Future<void> markRefreshed();
}

/// Simple data class for color pairs
class ColorPair {
  final Color primaryColor;
  final Color secondaryColor;

  const ColorPair({
    required this.primaryColor,
    required this.secondaryColor,
  });
}
