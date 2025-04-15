import 'package:flutter/material.dart';
import '../models/app_theme.dart';

class AppThemeData {
  static ThemeData darkTheme(AppTheme appTheme) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          iconColor: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: appTheme.primaryColor,
        onPrimary: Colors.white,
        secondary: appTheme.secondaryColor,
        onSecondary: Colors.white,
        surface: const Color(0xFF212121),
        shadow: Colors.grey.shade700,
      ),
      tabBarTheme: const TabBarTheme(
        dividerColor: Colors.transparent,
        indicatorColor: Color.fromRGBO(202, 196, 208, 1),
        labelColor: Color.fromRGBO(202, 196, 208, 1),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        selectedIconTheme: IconThemeData(color: Colors.white),
        unselectedIconTheme: IconThemeData(color: Colors.white),
        unselectedLabelTextStyle: TextStyle(color: Colors.white),
        selectedLabelTextStyle: TextStyle(color: Colors.white),
      ),
      primaryColor: appTheme.primaryColor,
    );
  }

  static ThemeData lightTheme(AppTheme appTheme) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.light(
        primary: appTheme.primaryColor,
        onPrimary: Colors.white,
        secondary: appTheme.secondaryColor,
        onSecondary: Colors.white,
      ),
      primaryColor: appTheme.primaryColor,
    );
  }
}
