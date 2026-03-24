import 'package:flutter/material.dart';

class AppTheme {
  // Brand colors inspired by the reference
  // Primary accent (warm orange) and rich dark surfaces.
  static const Color _brandOrange = Color(0xFFFF7A00); // warm orange
  static const Color _brandOrangeDim = Color(0xFFFF8C26);
  static const Color _brandOnOrange =
      Colors.black; // good contrast on bright orange

  // Dark surfaces
  static const Color _darkBg = Color(0xFF0E0E10); // main background
  static const Color _darkSurface = Color(0xFF131315);
  static const Color _darkSurfaceHigh = Color(0xFF1A1A1D);
  static const Color _darkOutline = Color(0xFF2A2A2E);

  // Text colors
  static const Color _darkOnSurface = Color(0xFFECECEC);

  // Light variant (kept pleasant; accent consistent)
  static const Color _lightBg = Color(0xFFF8F7F6);
  static const Color _lightSurface = Colors.white;
  static const Color _lightOutline = Color(0xFFE3E3E6);
  static const Color _lightOnSurface = Color(0xFF141414);
  static const Color _lightOnSurfaceVar = Color(0xFF5C5C60);

  static ThemeData get darkTheme {
    final scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _brandOrange,
      onPrimary: _brandOnOrange,
      primaryContainer: _brandOrangeDim,
      onPrimaryContainer: _brandOnOrange,
      secondary: const Color(0xFFED9E59), // warm secondary
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFF3A3028),
      onSecondaryContainer: _darkOnSurface,
      tertiary: const Color(0xFFB56A45), // rust
      onTertiary: _darkOnSurface,
      tertiaryContainer: const Color(0xFF32221C),
      onTertiaryContainer: _darkOnSurface,
      error: const Color(0xFFFF4D4F),
      onError: Colors.white,
      errorContainer: const Color(0xFF5A1A1A),
      onErrorContainer: _darkOnSurface,
      surface: _darkBg,
      onSurface: _darkOnSurface,
      surfaceDim: _darkSurface,
      surfaceBright: _darkSurfaceHigh,
      surfaceContainerLowest: _darkBg,
      surfaceContainerLow: _darkSurface,
      surfaceContainer: _darkSurface,
      surfaceContainerHigh: _darkSurfaceHigh,
      surfaceContainerHighest: _darkSurfaceHigh,
      outline: _darkOutline,
      outlineVariant: _darkOutline,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFFEDEDED),
      onInverseSurface: Colors.black,
      inversePrimary: const Color(0xFFFFB97A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      // Typography
      textTheme: Typography.whiteMountainView.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: scheme.surface,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.4),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.primary.withOpacity(0.10),
        labelStyle:
            TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: scheme.primary.withOpacity(0.25)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: _roundedBorder(scheme),
        enabledBorder: _roundedBorder(scheme),
        focusedBorder: _roundedBorder(scheme, focus: true),
        errorBorder: _roundedBorder(scheme, error: true),
        focusedErrorBorder: _roundedBorder(scheme, error: true),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle:
            TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        actionTextColor: scheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        modalBackgroundColor: scheme.surfaceContainerHigh,
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withOpacity(0.3),
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      // Buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
      // Navigation bar ripple/ink are default and fit well
    );
  }

  static ThemeData get lightTheme {
    final scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _brandOrange,
      onPrimary: _brandOnOrange,
      primaryContainer: _brandOrangeDim,
      onPrimaryContainer: _brandOnOrange,
      secondary: const Color(0xFFDE8B4D),
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFFFFE7D1),
      onSecondaryContainer: Colors.black,
      tertiary: const Color(0xFFB56A45),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFE3D3),
      onTertiaryContainer: Colors.black,
      error: const Color(0xFFB00020),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: Colors.black,
      surface: _lightBg,
      onSurface: _lightOnSurface,
      surfaceDim: const Color(0xFFF2F1EF),
      surfaceBright: Colors.white,
      surfaceContainerLowest: _lightBg,
      surfaceContainerLow: Colors.white,
      surfaceContainer: Colors.white,
      surfaceContainerHigh: Colors.white,
      surfaceContainerHighest: _lightSurface,
      outline: _lightOutline,
      outlineVariant: _lightOutline,
      shadow: Colors.black12,
      scrim: Colors.black54,
      inverseSurface: const Color(0xFF222326),
      onInverseSurface: Colors.white,
      inversePrimary: const Color(0xFFFFB36A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      textTheme: Typography.blackMountainView.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: scheme.surface,
        elevation: 8,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withOpacity(0.1),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 6,
        shape: const CircleBorder(),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerHighest,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurface,
        textColor: scheme.onSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.primary.withOpacity(0.08),
        labelStyle:
            TextStyle(color: scheme.onSurface, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: scheme.primary.withOpacity(0.2)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: _roundedBorder(scheme),
        enabledBorder: _roundedBorder(scheme),
        focusedBorder: _roundedBorder(scheme, focus: true),
        errorBorder: _roundedBorder(scheme, error: true),
        focusedErrorBorder: _roundedBorder(scheme, error: true),
        labelStyle: TextStyle(color: _lightOnSurfaceVar),
        hintStyle: TextStyle(color: _lightOnSurfaceVar),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainerHigh),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(color: _lightOnSurfaceVar, fontSize: 14),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        actionTextColor: scheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        modalBackgroundColor: scheme.surfaceContainerHigh,
        backgroundColor: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outline.withOpacity(0.5),
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: scheme.primary),
      ),
    );
  }

  static OutlineInputBorder _roundedBorder(ColorScheme scheme,
      {bool focus = false, bool error = false}) {
    final color = error
        ? scheme.error
        : (focus ? scheme.primary : scheme.outline.withOpacity(0.6));
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: focus ? 1.4 : 1),
    );
  }
}
