import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8D08A);
  static const Color goldDark = Color(0xFFA8832A);
  static const Color black = Color(0xFFF5F0E8);
  static const Color darkSurface = Color(0xFFF5F0E8);
  static const Color darkCard = Color(0xFFF0EAD6);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color cream = Color(0xFF141414);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF8A8070);
  static const Color error = Color(0xFFB04040);
  static const Color success = Color(0xFF3A7A5A);

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: black,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      secondary: goldLight,
      surface: darkSurface,
      error: error,
      onPrimary: black,
      onSecondary: black,
      onSurface: textPrimary,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.cormorantGaramond(
        fontSize: 48,
        fontWeight: FontWeight.w300,
        color: gold,
        letterSpacing: 2,
      ),
      displayMedium: GoogleFonts.cormorantGaramond(
        fontSize: 36,
        fontWeight: FontWeight.w300,
        color: textPrimary,
        letterSpacing: 1.5,
      ),
      displaySmall: GoogleFonts.cormorantGaramond(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 1,
      ),
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: textPrimary,
      ),
      titleLarge: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 1.2,
      ),
      titleMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        letterSpacing: 0.8,
      ),
      bodyLarge: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.montserrat(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.montserrat(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: gold,
        letterSpacing: 2,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cormorantGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: gold,
        letterSpacing: 2,
      ),
      iconTheme: const IconThemeData(color: gold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: gold, width: 1.5),
      ),
      labelStyle: GoogleFonts.montserrat(color: textSecondary, fontSize: 12),
      hintStyle: GoogleFonts.montserrat(color: textSecondary, fontSize: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: black,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        textStyle: GoogleFonts.montserrat(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
    chipTheme: ChipThemeData(
      backgroundColor: darkCard,
      selectedColor: gold,
      labelStyle: GoogleFonts.montserrat(fontSize: 12, color: textPrimary),
      side: const BorderSide(color: darkBorder),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    ),
  );
}


