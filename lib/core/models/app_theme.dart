import 'package:flutter/material.dart';

class AppTheme {
  final bool isDarkMode;
  final Color primaryColor;
  final Color secondaryColor;
  final String logoUrl;
  final String customerName;

  const AppTheme({
    this.isDarkMode = false,
    this.primaryColor = const Color(0xFF192B4C),
    this.secondaryColor = const Color(0xFF01629C),
    this.logoUrl = '',
    this.customerName = '',
  });

  Color get accentColor => primaryColor;

  Color get accentLight => HSLColor.fromColor(primaryColor)
      .withLightness(
          (HSLColor.fromColor(primaryColor).lightness + 0.15).clamp(0.0, 1.0))
      .toColor();

  Color get accentDark => HSLColor.fromColor(primaryColor)
      .withLightness(
          (HSLColor.fromColor(primaryColor).lightness - 0.15).clamp(0.0, 1.0))
      .toColor();

  AppTheme copyWith({
    bool? isDarkMode,
    Color? primaryColor,
    Color? secondaryColor,
    String? logoUrl,
    String? customerName,
  }) {
    return AppTheme(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      logoUrl: logoUrl ?? this.logoUrl,
      customerName: customerName ?? this.customerName,
    );
  }
}
