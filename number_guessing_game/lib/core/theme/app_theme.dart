import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Color Palette ───────────────────────────────────────────────────────────
  static const Color bg = Color(0xFF060614);
  static const Color surface = Color(0xFF0D0D2B);
  static const Color card = Color(0xFF14143A);
  static const Color cardBorder = Color(0xFF252560);
  static const Color primary = Color(0xFF6B4EFF);
  static const Color accent = Color(0xFF00EEFF);
  static const Color success = Color(0xFF00FF87);
  static const Color error = Color(0xFFFF3860);
  static const Color warning = Color(0xFFFFB800);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8888BB);

  // ── Theme ───────────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: surface,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.chakraPetch(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 1.5,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondary),
        errorStyle: const TextStyle(color: error, fontSize: 12),
      ),
    );
  }
}
