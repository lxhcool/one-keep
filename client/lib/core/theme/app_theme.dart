import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    surface: AppColors.darkSurface,
    elevated: AppColors.darkElevated,
    card: AppColors.darkCard,
    border: AppColors.darkCardBorder,
    borderStrong: AppColors.darkCardBorderStrong,
    inputBg: AppColors.darkInputBg,
    inputBorder: AppColors.darkInputBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textTertiary: AppColors.darkTextTertiary,
    shadow: AppColors.darkShadow,
  );

  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    surface: AppColors.lightSurface,
    elevated: AppColors.lightElevated,
    card: AppColors.lightCard,
    border: AppColors.lightCardBorder,
    borderStrong: AppColors.lightCardBorderStrong,
    inputBg: AppColors.lightInputBg,
    inputBorder: AppColors.lightInputBorder,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textTertiary: AppColors.lightTextTertiary,
    shadow: AppColors.lightShadow,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBackgroundColor,
    required Color surface,
    required Color elevated,
    required Color card,
    required Color border,
    required Color borderStrong,
    required Color inputBg,
    required Color inputBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color shadow,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.teal,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.teal,
          secondary: AppColors.purple,
          surface: surface,
          surfaceContainerHighest: elevated,
          outline: border,
          outlineVariant: borderStrong,
          onPrimary: Colors.white,
          onSurface: textPrimary,
          onSurfaceVariant: textSecondary,
          error: AppColors.error,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: _buildTextTheme(brightness),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: border, width: 0.9),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.teal,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: elevated,
        selectedColor: AppColors.teal.withValues(alpha: isDark ? 0.20 : 0.14),
        labelStyle: TextStyle(color: textPrimary),
        secondaryLabelStyle: const TextStyle(color: AppColors.teal),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.chip),
          side: BorderSide(color: border, width: 0.9),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputBg,
        hintStyle: TextStyle(color: textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: inputBorder, width: 0.9),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: BorderSide(color: inputBorder, width: 0.9),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.teal,
          splashFactory: NoSplash.splashFactory,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          backgroundColor: surface,
          side: BorderSide(color: border, width: 0.9),
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.card),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: border, thickness: 1),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          side: BorderSide(color: borderStrong, width: 0.9),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: elevated,
        contentTextStyle: TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: border, width: 0.8),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final primary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final tertiary = isDark
        ? AppColors.darkTextTertiary
        : AppColors.lightTextTertiary;

    return GoogleFonts.manropeTextTheme(
          isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
        )
        .apply(bodyColor: primary, displayColor: primary)
        .copyWith(
          displayLarge: TextStyle(color: primary, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(color: primary, fontWeight: FontWeight.w700),
          displaySmall: TextStyle(color: primary, fontWeight: FontWeight.w600),
          headlineLarge: TextStyle(color: primary, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(
            color: primary,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(color: primary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(color: secondary, fontWeight: FontWeight.w600),
          titleSmall: TextStyle(color: tertiary, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: primary),
          bodyMedium: TextStyle(color: secondary),
          bodySmall: TextStyle(color: tertiary),
          labelLarge: TextStyle(color: primary, fontWeight: FontWeight.w600),
          labelMedium: TextStyle(color: secondary, fontWeight: FontWeight.w600),
          labelSmall: TextStyle(color: tertiary, fontWeight: FontWeight.w600),
        );
  }
}
