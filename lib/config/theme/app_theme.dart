import 'package:flutter/material.dart';

class AppTheme {
  // ── Brand colors ────────────────────────────────────────────────────────────
  static const Color primaryColor = Color(0xFF1A0047);
  static const Color accentColor = Color(0xFF4233CE);

  // ── Dark UI palette ─────────────────────────────────────────────────────────
  static const Color background = Color(0xFF0F0035);
  static const Color surface = Color(0xFF1A0050);
  static const Color cardColor = Color(0xFF220A5A);
  static const Color cardBorder = Color(0xFF4433B0);
  static const Color navBar = Color(0xFF110038);
  static const Color successColor = Color(0xFF4CAF82);
  static const Color dangerColor = Color(0xFFE05A7A);
  static const Color textSecondary = Color(0xFFAA99D8);

  static ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
      primary: accentColor,
      secondary: accentColor,
      surface: surface,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: cardBorder, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: navBar,
      selectedItemColor: Color(0xFF7B6FEA),
      unselectedItemColor: Color(0xFF554488),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: cardColor,
      filled: true,
      labelStyle: const TextStyle(color: textSecondary),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: cardBorder),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: cardBorder, width: 0.8),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: accentColor, width: 2),
      ),
    ),
  );
}
