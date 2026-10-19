import 'package:flutter/material.dart';

/// Shared visual system for Mithaq Al-Mumin.
///
/// Keep the palette centralized so features can be migrated independently
/// without creating subtly different shades or component styles.
abstract final class AppPalette {
  static const deepGreen = Color(0xFF071B15);
  static const panelGreen = Color(0xFF123A2D);
  static const leafGreen = Color(0xFF174936);
  static const accentGold = Color(0xFFD6BB7A);
  static const ivory = Color(0xFFF5EAD0);
  static const mutedText = Color(0xFFB5C9BD);
}

abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppPalette.accentGold,
      onPrimary: AppPalette.deepGreen,
      secondary: AppPalette.leafGreen,
      onSecondary: AppPalette.ivory,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: AppPalette.panelGreen,
      onSurface: AppPalette.ivory,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppPalette.deepGreen,
      canvasColor: AppPalette.deepGreen,
      dividerColor: AppPalette.accentGold.withValues(alpha: 0.16),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.deepGreen,
        foregroundColor: AppPalette.ivory,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF051811),
        indicatorColor: AppPalette.accentGold.withValues(alpha: 0.18),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppPalette.panelGreen,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: AppPalette.accentGold.withValues(alpha: 0.14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.panelGreen,
        hintStyle: const TextStyle(color: AppPalette.mutedText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppPalette.accentGold.withValues(alpha: 0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppPalette.accentGold),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.accentGold,
          foregroundColor: AppPalette.deepGreen,
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppPalette.accentGold,
        selectionColor: Color(0x55D6BB7A),
        selectionHandleColor: AppPalette.accentGold,
      ),
    );
  }
}
