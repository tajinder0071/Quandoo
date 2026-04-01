import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color bg        = Color(0xFF0F1923);
  static const Color surface   = Color(0xFF1A2433);
  static const Color card      = Color(0xFF1E2A3B);
  static const Color cardAlt   = Color(0xFF243044);
  static const Color border    = Color(0xFF2A3A50);
  static const Color primary   = Color(0xFFFF6B35);
  static const Color primaryDk = Color(0xFFD94F1A);
  static const Color gold      = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8CC6A);
  static const Color white     = Color(0xFFFFFFFF);
  static const Color text1     = Color(0xFFF0F4F8);
  static const Color text2     = Color(0xFF8FA3BC);
  static const Color text3     = Color(0xFF4A6380);
  static const Color success   = Color(0xFF22C55E);
  static const Color error     = Color(0xFFEF4444);
  static const Color warning   = Color(0xFFF59E0B);
  static const Color star      = Color(0xFFFBBF24);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: gold,
      surface: surface,
      error: error,
      onPrimary: white,
      onSecondary: bg,
      onSurface: text1,
    ),
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18, fontWeight: FontWeight.w600, color: text1),
      iconTheme: const IconThemeData(color: text1),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5)),
      hintStyle: GoogleFonts.dmSans(color: text3, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: text3,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  static TextTheme get _textTheme => TextTheme(
    displayLarge: GoogleFonts.playfairDisplay(fontSize: 36, fontWeight: FontWeight.w700, color: text1),
    displayMedium: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w700, color: text1),
    displaySmall: GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w600, color: text1),
    headlineLarge: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w700, color: text1),
    headlineMedium: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: text1),
    titleLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: text1),
    titleMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: text1),
    bodyLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w400, color: text1),
    bodyMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: text2),
    labelLarge: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: text1, letterSpacing: 0.5),
  );
}
