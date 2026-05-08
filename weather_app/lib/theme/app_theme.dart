import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const Color skyBlue      = Color(0xFF4FC3F7);
  static const Color deepSky      = Color(0xFF0288D1);
  static const Color lightBlue    = Color(0xFFE1F5FE);
  static const Color sunYellow    = Color(0xFFFFD54F);
  static const Color sunOrange    = Color(0xFFFF8F00);
  static const Color cloudGray    = Color(0xFFB0BEC5);
  static const Color nightBlue    = Color(0xFF1A237E);
  static const Color white        = Color(0xFFFFFFFF);
  static const Color softWhite    = Color(0xFFF8FBFF);
  static const Color textPrimary  = Color(0xFF1C2B3A);
  static const Color textSecondary= Color(0xFF546E7A);
  static const Color cardSurface  = Color(0xFFFFFFFF);
  static const Color errorRed     = Color(0xFFE53935);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient dayGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF74C0FC), Color(0xFF4FC3F7), Color(0xFFB2EBF2)],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB74D), Color(0xFFFF8F00), Color(0xFFE65100)],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF1565C0)],
  );

  static const LinearGradient cloudyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF90A4AE), Color(0xFFB0BEC5), Color(0xFFCFD8DC)],
  );

  static const LinearGradient rainGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF37474F), Color(0xFF455A64), Color(0xFF546E7A)],
  );

  // ── Theme Data ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: deepSky,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.dmSansTextTheme().copyWith(
        displayLarge: GoogleFonts.dmSans(
          fontSize: 72,
          fontWeight: FontWeight.w300,
          color: white,
          letterSpacing: -2,
        ),
        displayMedium: GoogleFonts.dmSans(
          fontSize: 48,
          fontWeight: FontWeight.w300,
          color: white,
        ),
        headlineLarge: GoogleFonts.dmSans(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: white,
        ),
        headlineMedium: GoogleFonts.dmSans(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: white,
        ),
        titleLarge: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
        labelSmall: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.8,
        ),
      ),
      scaffoldBackgroundColor: softWhite,
      cardTheme: CardThemeData(
        elevation: 0,
        color: cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: deepSky, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  // ── Weather-based gradient selector ──────────────────────────────────────
  static LinearGradient getWeatherGradient(String condition, bool isDay) {
    if (!isDay) return nightGradient;
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle') || c.contains('thunder')) {
      return rainGradient;
    }
    if (c.contains('cloud') || c.contains('mist') || c.contains('fog')) {
      return cloudyGradient;
    }
    if (c.contains('clear')) return dayGradient;
    return dayGradient;
  }

  static Color getWeatherAccent(String condition, bool isDay) {
    if (!isDay) return const Color(0xFF7986CB);
    final c = condition.toLowerCase();
    if (c.contains('rain') || c.contains('drizzle')) return const Color(0xFF4DD0E1);
    if (c.contains('thunder')) return const Color(0xFFCE93D8);
    if (c.contains('cloud')) return const Color(0xFF90CAF9);
    if (c.contains('clear')) return sunYellow;
    return skyBlue;
  }

  static String getWeatherEmoji(String condition) {
    final c = condition.toLowerCase();
    if (c.contains('thunder')) return '⛈️';
    if (c.contains('rain') || c.contains('drizzle')) return '🌧️';
    if (c.contains('snow')) return '❄️';
    if (c.contains('mist') || c.contains('fog') || c.contains('haze')) return '🌫️';
    if (c.contains('cloud')) return '⛅';
    if (c.contains('clear')) return '☀️';
    if (c.contains('wind')) return '💨';
    return '🌤️';
  }
}
