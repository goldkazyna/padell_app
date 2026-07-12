import 'package:flutter/material.dart';

/// Тема приложения.
///
/// Бренд-акцент (зелёный) одинаков в обеих темах и остаётся `const`.
/// Остальные токены — переключаемые: значения ставит [applyBrightness],
/// который вызывается в корне приложения перед построением дерева, поэтому
/// все обращения `AppTheme.background` и т.п. читают актуальную палитру.
/// При смене темы всё дерево перестраивается (через SettingsProvider).
class AppTheme {
  // === Бренд (одинаково в обеих темах) ===
  static const Color accent = Color(0xFF22C47A);
  static const Color accentSoft = Color(0x2422C47A); // rgba(34,196,122,0.14)
  /// Тёмный зелёный для текста/иконок на светлом фоне (яркий #22C47A на белом
  /// читается плохо). В тёмной теме визуально совпадает с accent.
  static const Color accentStrong = Color(0xFF0E9E5B);

  // === Переключаемые токены (по умолчанию — тёмная палитра) ===
  static Color background = _dBackground;
  static Color card = _dCard;
  static Color cardRaised = _dCardRaised;

  static Color amber = _dAmber;
  static Color blue = _dBlue;
  static Color purple = _dPurple;
  static Color orange = _dOrange;
  static Color error = _dError;
  static Color errorSoft = _dErrorSoft;

  static Color textPrimary = _dTextPrimary;
  static Color textSecondary = _dTextSecondary;
  static Color textDim = _dTextDim;

  static Color border = _dBorder;
  static Color divider = _dDivider;

  /// Текущая яркость активной палитры.
  static Brightness brightness = Brightness.dark;

  // ---- Тёмная палитра (V3) ----
  static const Color _dBackground = Color(0xFF131317);
  static const Color _dCard = Color(0xFF1C1C21);
  static const Color _dCardRaised = Color(0xFF23232A);
  static const Color _dAmber = Color(0xFFEAB34E);
  static const Color _dBlue = Color(0xFF4A8BF5);
  static const Color _dPurple = Color(0xFFA89CF5);
  static const Color _dOrange = Color(0xFFF08446);
  static const Color _dError = Color(0xFFF0554D);
  static const Color _dErrorSoft = Color(0x1FF0554D); // rgba(240,85,77,0.12)
  static const Color _dTextPrimary = Color(0xFFF3F3F5);
  static const Color _dTextSecondary = Color(0xFFA2A2AB);
  static const Color _dTextDim = Color(0xFF6A6A73);
  static const Color _dBorder = Color(0x0FFFFFFF); // rgba(255,255,255,0.06)
  static const Color _dDivider = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)

  // ---- Светлая палитра ----
  static const Color _lBackground = Color(0xFFFAF9F5); // тёплый кремовый
  static const Color _lCard = Color(0xFFFFFFFF);
  static const Color _lCardRaised = Color(0xFFEEF0F3);
  static const Color _lAmber = Color(0xFFE0A21C);
  static const Color _lBlue = Color(0xFF2E6FE0);
  static const Color _lPurple = Color(0xFF7B67E6);
  static const Color _lOrange = Color(0xFFE0632B);
  static const Color _lError = Color(0xFFE23B32);
  static const Color _lErrorSoft = Color(0x1AE23B32); // rgba(226,59,50,0.10)
  static const Color _lTextPrimary = Color(0xFF17181C);
  static const Color _lTextSecondary = Color(0xFF5C5E66);
  static const Color _lTextDim = Color(0xFF6E7079); // притемнён для контраста
  static const Color _lBorder = Color(0x14000000); // rgba(0,0,0,0.08)
  static const Color _lDivider = Color(0x0F000000); // rgba(0,0,0,0.06)

  /// Применить палитру по яркости. Вызывается в корне перед build.
  static void applyBrightness(Brightness b) {
    brightness = b;
    final light = b == Brightness.light;
    background = light ? _lBackground : _dBackground;
    card = light ? _lCard : _dCard;
    cardRaised = light ? _lCardRaised : _dCardRaised;
    amber = light ? _lAmber : _dAmber;
    blue = light ? _lBlue : _dBlue;
    purple = light ? _lPurple : _dPurple;
    orange = light ? _lOrange : _dOrange;
    error = light ? _lError : _dError;
    errorSoft = light ? _lErrorSoft : _dErrorSoft;
    textPrimary = light ? _lTextPrimary : _dTextPrimary;
    textSecondary = light ? _lTextSecondary : _dTextSecondary;
    textDim = light ? _lTextDim : _dTextDim;
    border = light ? _lBorder : _dBorder;
    divider = light ? _lDivider : _dDivider;
  }

  static ThemeData get darkTheme => _build(Brightness.dark);
  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData _build(Brightness b) {
    final light = b == Brightness.light;
    final bg = light ? _lBackground : _dBackground;
    final cardC = light ? _lCard : _dCard;
    final errC = light ? _lError : _dError;
    final textC = light ? _lTextPrimary : _dTextPrimary;

    return ThemeData(
      brightness: b,
      scaffoldBackgroundColor: bg,
      primaryColor: accent,
      colorScheme: light
          ? const ColorScheme.light(
              primary: accent,
              surface: _lCard,
              error: _lError,
            )
          : const ColorScheme.dark(
              primary: accent,
              surface: _dCard,
              error: _dError,
            ),
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textC,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardC,
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
