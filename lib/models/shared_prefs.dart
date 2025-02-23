import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const String kThemeStatus = "THEMESTATUS";
  static const String kPrimaryColor = "PRIMARYCOLOR";
  static const String kSecondaryColor = "SECONDARYCOLOR";
  static const String kLogoLink = "LOGOLINK";

  // Singleton pattern
  static final AppPreferences _instance = AppPreferences._internal();
  factory AppPreferences() => _instance;
  AppPreferences._internal();

  // Theme preferences
  Future<void> setDarkTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kThemeStatus, value);
  }

  Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kThemeStatus) ?? false;
  }

  // Color preferences
  Future<void> setColors({
    required Color primaryColor,
    required Color secondaryColor,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kPrimaryColor, primaryColor.value);
    await prefs.setInt(kSecondaryColor, secondaryColor.value);
  }

  Future<ColorPair> getColors() async {
    final prefs = await SharedPreferences.getInstance();
    return ColorPair(
      primaryColor: Color(prefs.getInt(kPrimaryColor) ?? 0xFF192B4C),
      secondaryColor: Color(prefs.getInt(kSecondaryColor) ?? 0xFF01629C),
    );
  }

  // Logo preferences
  Future<void> setLogoLink(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLogoLink, value);
  }

  Future<String> getLogoLink() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kLogoLink) ?? 'assets/edconnect_logo.png';
  }

  // Clear all preferences
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }
}

class ColorPair {
  final Color primaryColor;
  final Color secondaryColor;

  ColorPair({
    required this.primaryColor,
    required this.secondaryColor,
  });
}
