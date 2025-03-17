import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme_data_source.dart';

class SharedPrefsThemeDataSource implements ThemeDataSource {
  static const String kThemeStatus = "THEMESTATUS";
  static const String kPrimaryColor = "PRIMARYCOLOR";
  static const String kSecondaryColor = "SECONDARYCOLOR";
  static const String kLogoLink = "LOGOLINK";
  static const String kCustomerName = "CUSTOMERNAME";
  static const String kLastRefreshTimestamp = "LAST_REFRESH_TIMESTAMP";

  @override
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(kThemeStatus) ?? false;
  }

  @override
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kThemeStatus, isDark);
  }

  @override
  Future<Color> getPrimaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return Color(prefs.getInt(kPrimaryColor) ?? 0xFF192B4C);
  }

  @override
  Future<Color> getSecondaryColor() async {
    final prefs = await SharedPreferences.getInstance();
    return Color(prefs.getInt(kSecondaryColor) ?? 0xFF01629C);
  }

  @override
  Future<void> saveColors(Color primary, Color secondary) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kPrimaryColor, primary.value);
    await prefs.setInt(kSecondaryColor, secondary.value);
  }

  @override
  Future<String> getLogoLink() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kLogoLink) ?? '';
  }

  @override
  Future<void> saveLogoLink(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kLogoLink, url);
  }

  @override
  Future<String> getCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kCustomerName) ?? '';
  }

  @override
  Future<void> saveCustomerName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(kCustomerName, name);
  }

  @override
  Future<int> getLastRefreshTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(kLastRefreshTimestamp) ?? 0;
  }

  @override
  Future<void> saveRefreshTimestamp(int timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kLastRefreshTimestamp, timestamp);
  }
}
