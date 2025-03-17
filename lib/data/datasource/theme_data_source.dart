import 'package:flutter/material.dart';

abstract class ThemeDataSource {
  /// Get current theme mode
  Future<bool> isDarkMode();

  /// Save theme mode preference
  Future<void> setDarkMode(bool isDark);

  /// Get primary color
  Future<Color> getPrimaryColor();

  /// Get secondary color
  Future<Color> getSecondaryColor();

  /// Save colors
  Future<void> saveColors(Color primary, Color secondary);

  /// Get logo link
  Future<String> getLogoLink();

  /// Save logo link
  Future<void> saveLogoLink(String url);

  /// Get customer name
  Future<String> getCustomerName();

  /// Save customer name
  Future<void> saveCustomerName(String name);

  /// Get last refresh timestamp
  Future<int> getLastRefreshTimestamp();

  /// Save refresh timestamp
  Future<void> saveRefreshTimestamp(int timestamp);
}

abstract class RemoteThemeDataSource {
  /// Fetch theme settings from remote source
  Future<Map<String, dynamic>?> fetchThemeSettings();
}
