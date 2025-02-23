import 'package:flutter/material.dart';
import 'package:edconnect_admin/models/shared_prefs.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false) {
    // Load the saved theme on initialization.
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = await AppPreferences().getTheme();
    updateTheme(isDark);
  }

  // Call this method to switch between dark and light modes.
  void updateTheme(bool isDark) {
    // Save the new theme preference.
    AppPreferences().setDarkTheme(isDark);
    // Update the theme state.
    state = isDark ? true : false;
  }
}

@immutable
class ColorAndLogoState {
  final Color primaryColor;
  final Color secondaryColor;
  final String logoLink;
  final String customerName;

  const ColorAndLogoState({
    this.primaryColor = const Color(0xFF192B4C),
    this.secondaryColor = const Color(0xFF01629C),
    this.logoLink = '',
    this.customerName = '',
  });

  ColorAndLogoState copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    String? logoLink,
    String? customerName,
  }) {
    return ColorAndLogoState(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      logoLink: logoLink ?? this.logoLink,
      customerName: customerName ?? this.customerName,
    );
  }
}

class ColorAndLogoNotifier extends StateNotifier<ColorAndLogoState> {
  ColorAndLogoNotifier() : super(const ColorAndLogoState());

  // Add the updateColors method that matches the call in color_and_logo_utils.dart
  void updateColors({
    required Color primaryColor,
    required Color secondaryColor,
    required String logoLink,
    required String customerName,
  }) {
    state = ColorAndLogoState(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      logoLink: logoLink,
      customerName: customerName,
    );
  }

  // Keep existing helper methods but simplify them to use state directly
  void setPrimaryColor(String hexValue) {
    final color = hexToColor(hexValue);
    state = state.copyWith(primaryColor: color);
  }

  void setSecondaryColor(String hexValue) {
    final color = hexToColor(hexValue);
    state = state.copyWith(secondaryColor: color);
  }

  void setLogoLink(String value) {
    state = state.copyWith(logoLink: value);
  }

  void setCustomerName(String value) {
    state = state.copyWith(customerName: value);
  }

  // Helper method to convert hex string to Color.
  Color hexToColor(String hexCode) {
    // Ensure the string is in the format "0xFF123456"
    return Color(int.parse(hexCode));
  }
}

final colorAndLogoProvider =
    StateNotifierProvider<ColorAndLogoNotifier, ColorAndLogoState>(
  (ref) => ColorAndLogoNotifier(),
);
