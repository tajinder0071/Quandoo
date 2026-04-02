import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color bg = Color(0xFFF8F5F0); // warm off-white
  static const Color surface = Color(0xFFFFFFFF); // pure white surfaces
  static const Color card = Color(0xFFFFFFFF); // white cards
  static const Color cardAlt = Color(0xFFF3EDE4); // warm cream alt
  static const Color border = Color(0xFFE8E0D5); // warm grey border
  static const Color primary = Color(0xFFE05A2B); // warm terracotta
  static const Color primaryDk = Color(0xFFBF4218); // darker terracotta
  static const Color gold = Color(0xFFB8922A); // antique gold
  static const Color goldLight = Color(0xFFD4AF37); // bright gold
  static const Color white = Color(0xFFFFFFFF);
  static const Color text1 = Color(0xFF1C1410); // near-black warm
  static const Color text2 = Color(0xFF6B5B4E); // warm medium brown
  static const Color text3 = Color(0xFFAA9988); // warm light grey
  static const Color success = Color(0xFF2E7D52);
  static const Color error = Color(0xFFC0392B);
  static const Color warning = Color(0xFFD97706);
  static const Color star = Color(0xFFF59E0B);

  static ThemeData get dark => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: gold,
      surface: surface,
      error: error,
      onPrimary: white,
      onSecondary: white,
      onSurface: text1,
    ),
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: text1,
      ),
      iconTheme: const IconThemeData(color: text1),
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 0.8),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(color: text3, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.dmSans(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
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
    displayLarge: GoogleFonts.playfairDisplay(
      fontSize: 36,
      fontWeight: FontWeight.w700,
      color: text1,
    ),
    displayMedium: GoogleFonts.playfairDisplay(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: text1,
    ),
    displaySmall: GoogleFonts.playfairDisplay(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: text1,
    ),
    headlineLarge: GoogleFonts.dmSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: text1,
    ),
    headlineMedium: GoogleFonts.dmSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: text1,
    ),
    titleLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: text1,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: text1,
    ),
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: text1,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: text2,
    ),
    labelLarge: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: text1,
      letterSpacing: 0.5,
    ),
  );
}
