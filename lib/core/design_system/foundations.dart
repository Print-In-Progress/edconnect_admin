import 'package:flutter/material.dart';

abstract class Foundations {
  static const colors = _Colors();
  static const darkColors = _DarkColors();
  static const typography = _Typography();
  static const spacing = _Spacing();
  static final borders = _Borders();
  static const effects = _Effects();
}

class _Colors {
  const _Colors();

  // Primary and Secondary color is selected by the organization

  // Semantic colors
  final Color success = const Color(0xFF22C55E);
  final Color warning = const Color(0xFFF59E0B);
  final Color error = const Color(0xFFEF4444);
  final Color info = const Color(0xFF3B82F6);

  // Surface colors (Light mode)
  final Color surface = const Color(0xFFFFFFFF); // White at 50% opacity
  final Color surfaceHover = const Color(0xFFF8FAFC); // White at 65% opacity
  final Color surfaceActive = const Color(0xFFF1F5F9);

  // Background variations
  final Color background = const Color(0xFFF8FAFC);
  final Color backgroundMuted = const Color(0xFFF1F5F9);
  final Color backgroundSubtle = const Color(0xFFE2E8F0);

  // Text colors
  final Color textPrimary = const Color(0xFF0F172A); // Slate 900
  final Color textSecondary = const Color(0xFF334155); // Slate 700
  final Color textMuted = const Color(0xFF64748B); // Slate 500
  final Color textDisabled = const Color(0xFF94A3B8); // Slate 400

  // Border colors
  final Color border = const Color(0xFFCDCDDF); // Per your spec
  final Color borderHover = const Color(0xFFBBBBCF);

  // Input & control states
  final Color inputBg = const Color(0xFFFFFFFF);
  final Color inputBorder = const Color(0xFFCDCDDF);
  final Color inputHoverBorder = const Color(0xFFBBBBCF);

  // Glassmorphism specific
  final Color glass = const Color(0x80FFFFFF); // White at 50% opacity
  final Color glassBorder = const Color(0xFFCDCDDF);
  final Color glassHighlight = const Color(0xD9FFFFFF);
  final Color glassShadow = const Color(0x14000000); // Shadow for glass effect
}

class _DarkColors {
  const _DarkColors();
  // Primary and Secondary color is selected by the organization

  // TODO: change dark mode focus border color to accentLight in inputs and dropdowns (use it for chips and other elements too)

  // Semantic colors
  final Color success = const Color(0xFF4ADE80);
  final Color warning = const Color(0xFFFBBF24);
  final Color error = const Color(0xFFF87171);
  final Color info = const Color(0xFF60A5FA);

  // Surface colors (Dark mode)
  final Color surface = const Color(0xFF0e1217); // Black at 35% opacity
  final Color surfaceHover = const Color(0xFF334155);
  final Color surfaceActive = const Color(0xFF475569);

  // Background variations
  final Color background = const Color(0xFF0F172A); // Slate 900
  final Color backgroundMuted = const Color(0xFF1E293B); // Slate 800
  final Color backgroundSubtle = const Color(0xFF334155); // Slate 700

  // Text colors
  final Color textPrimary = const Color(0xFFF8FAFC); // Slate 50
  final Color textSecondary = const Color(0xFFE2E8F0); // Slate 200
  final Color textMuted = const Color(0xFF94A3B8); // Slate 400
  final Color textDisabled = const Color(0xFF64748B); // Slate 500

  // Border colors
  final Color border = const Color(0xFF344347); // Per your spec
  final Color borderHover = const Color(0xFF455A60);

  // Input & control states
  final Color inputBg = const Color(0xFF1E293B);
  final Color inputBorder = const Color(0xFF344347);
  final Color inputHoverBorder = const Color(0xFF455A60);

  // Glassmorphism specific
  final Color glass = const Color(0x59000000); // Black at 35% opacity
  final Color glassBorder = const Color(0xFF344347);
  final Color glassHighlight = const Color(0x1AFFFFFF);
  final Color glassShadow = const Color(0x40000000);
}

class _Typography {
  const _Typography();

  // Font Family
  final String primaryFont = 'Inter';

  // Font Sizes
  final double xs = 12; // Extra small text
  final double sm = 14; // Small text
  final double base = 16; // Base/body text
  final double lg = 18; // Large text
  final double xl = 20; // Extra large text
  final double xl2 = 24; // 2xl
  final double xl3 = 30; // 3xl
  final double xl4 = 36; // 4xl
  final double xl5 = 48; // 5xl
  final double xl6 = 60; // 6xl

  // Font Weights
  final FontWeight light = FontWeight.w300;
  final FontWeight regular = FontWeight.w400;
  final FontWeight medium = FontWeight.w500;
  final FontWeight semibold = FontWeight.w600;
  final FontWeight bold = FontWeight.w700;

  // Line Heights
  final double tight = 1.25; // Tight
  final double snug = 1.375; // Snug
  final double normal = 1.5; // Normal
  final double relaxed = 1.625; // Relaxed
  final double loose = 2; // Loose
}

class _Spacing {
  const _Spacing();

  // Base spacing unit (4px)
  final double px = 1; // 1px
  final double xs = 4; // 0.25rem
  final double sm = 8; // 0.5rem
  final double md = 12; // 0.75rem
  final double lg = 16; // 1rem
  final double xl = 20; // 1.25rem
  final double xl2 = 24; // 1.5rem
  final double xl3 = 32; // 2rem
  final double xl4 = 40; // 2.5rem
  final double xl5 = 48; // 3rem
  final double xl6 = 64; // 4rem

  // Layout Spacing
  final double pageMargin = 24;
  final double sectionGap = 48;
  final double componentGap = 16;
  final double inlineGap = 8;
}

class _Borders {
  // Border Radius
  final BorderRadius none = BorderRadius.zero;
  final BorderRadius xs = BorderRadius.circular(4); // Extra small
  final BorderRadius sm = BorderRadius.circular(6); // Small
  final BorderRadius md = BorderRadius.circular(8); // Medium
  final BorderRadius lg = BorderRadius.circular(12); // Large
  final BorderRadius xl = BorderRadius.circular(16); // Extra large
  final BorderRadius xl2 = BorderRadius.circular(20); // 2xl
  final BorderRadius full = BorderRadius.circular(9999); // Full

  // Border Widths
  final double thin = 0.5; // Thin border
  final double normal = 1; // Normal border
  final double thick = 2; // Thick border

  // Ring (Focus) Widths
  final double ringWidth = 2;
  final double ringOffsetWidth = 2;
}

class _Effects {
  const _Effects();

  final List<BoxShadow> shadowSm = const [
    BoxShadow(
      offset: Offset(0, 1),
      blurRadius: 2,
      spreadRadius: -1,
      color: Color.fromRGBO(0, 0, 0, 0.1),
    ),
  ];

  final List<BoxShadow> shadowMd = const [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 4,
      spreadRadius: -2,
      color: Color.fromRGBO(0, 0, 0, 0.1),
    ),
  ];

  final List<BoxShadow> shadowLg = const [
    BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 6,
      spreadRadius: -4,
      color: Color.fromRGBO(0, 0, 0, 0.1),
    ),
  ];

  // Animation durations (matching shadcn)
  final Duration shortAnimation = const Duration(milliseconds: 150);
  final Duration mediumAnimation = const Duration(milliseconds: 300);
  final Duration longAnimation = const Duration(milliseconds: 500);
}
