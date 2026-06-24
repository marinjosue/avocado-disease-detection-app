// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_tokens.dart';
import 'disease_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        primary: LightTokens.primary,
        onPrimary: Colors.white,
        secondary: LightTokens.accent,
        background: LightTokens.background,
        surface: LightTokens.surface,
        textPrimary: LightTokens.textPrimary,
        textSecondary: LightTokens.textSecondary,
        error: LightTokens.error,
        appBarColor: LightTokens.primary,
        diseaseColors: DiseaseColors.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        primary: DarkTokens.primary,
        onPrimary: const Color(0xFF06140C),
        secondary: DarkTokens.accent,
        background: DarkTokens.background,
        surface: DarkTokens.surface,
        textPrimary: DarkTokens.textPrimary,
        textSecondary: DarkTokens.textSecondary,
        error: DarkTokens.error,
        appBarColor: DarkTokens.primaryDark,
        diseaseColors: DiseaseColors.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color error,
    required Color appBarColor,
    required DiseaseColors diseaseColors,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    const tabular = [FontFeature.tabularFigures()];

    final textTheme = TextTheme(
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: textPrimary, fontFeatures: tabular, letterSpacing: -1),
      bodyMedium: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: textPrimary),
      bodySmall: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: textSecondary),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 0.6),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      extensions: [diseaseColors],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: primary, width: 1.5),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: textSecondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primary.withValues(alpha: 0.1),
        labelStyle: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12),
      ),
      dividerTheme: DividerThemeData(color: textSecondary.withValues(alpha: 0.15), thickness: 1),
    );
  }
}
