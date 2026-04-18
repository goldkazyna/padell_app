import 'package:flutter/material.dart';

class AppTheme {
  // === Base palette (V3) ===
  static const Color background = Color(0xFF131317);
  static const Color card = Color(0xFF1C1C21);
  static const Color cardRaised = Color(0xFF23232A);

  static const Color accent = Color(0xFF22C47A);
  static const Color accentSoft = Color(0x2422C47A); // rgba(34,196,122,0.14)

  static const Color amber = Color(0xFFEAB34E);
  static const Color blue = Color(0xFF4A8BF5);
  static const Color purple = Color(0xFFA89CF5);
  static const Color orange = Color(0xFFF08446);
  static const Color error = Color(0xFFF0554D);
  static const Color errorSoft = Color(0x1FF0554D); // rgba(240,85,77,0.12)

  // === Text ===
  static const Color textPrimary = Color(0xFFF3F3F5);
  static const Color textSecondary = Color(0xFFA2A2AB); // muted
  static const Color textDim = Color(0xFF6A6A73);

  // === Dividers / borders ===
  static const Color border = Color(0x0FFFFFFF);   // rgba(255,255,255,0.06)
  static const Color divider = Color(0x0DFFFFFF);  // rgba(255,255,255,0.05)

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        surface: card,
        error: error,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }
}
