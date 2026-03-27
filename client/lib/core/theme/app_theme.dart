import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// OneKeep 主题系统 — 深色/浅色模式统一设计
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════
  // 深色主题 — 深海蓝灰调夜间模式
  // ═══════════════════════════════════════════════════════════════════
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.teal,
      secondary: AppColors.purple,
      surface: AppColors.darkSurface,
      surfaceContainerHighest: AppColors.darkElevated,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      outline: AppColors.darkCardBorder,
    ),
    textTheme: _buildDarkTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.darkTextPrimary,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
      ),
      elevation: 0,
      shadowColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      selectedItemColor: AppColors.teal,
      unselectedItemColor: AppColors.darkTextTertiary,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkElevated,
      selectedColor: AppColors.teal.withValues(alpha: 0.2),
      labelStyle: const TextStyle(color: AppColors.darkTextPrimary),
      secondaryLabelStyle: const TextStyle(color: AppColors.teal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkInputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.darkInputBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.darkInputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.darkTextTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        textStyle: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
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
        foregroundColor: AppColors.darkTextPrimary,
        side: const BorderSide(color: AppColors.darkCardBorder),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkHairline,
      thickness: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        side: const BorderSide(color: AppColors.darkCardBorder, width: 1),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkElevated,
      contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ═══════════════════════════════════════════════════════════════════
  // 浅色主题 — 温暖米白调日间模式
  // ═══════════════════════════════════════════════════════════════════
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme.light(
      primary: AppColors.teal,
      secondary: AppColors.purple,
      surface: AppColors.lightSurface,
      surfaceContainerHighest: AppColors.lightElevated,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      outline: AppColors.lightCardBorder,
    ),
    textTheme: _buildLightTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.lightTextPrimary,
        letterSpacing: -0.5,
      ),
      iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.lightCard,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
      ),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.04),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      selectedItemColor: AppColors.teal,
      unselectedItemColor: AppColors.lightTextTertiary,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.lightInputBg,
      selectedColor: AppColors.teal.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: AppColors.lightTextPrimary),
      secondaryLabelStyle: const TextStyle(color: AppColors.teal),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.chip),
        side: const BorderSide(color: AppColors.lightHairline, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightInputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.lightInputBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.lightInputBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      hintStyle: const TextStyle(color: AppColors.lightTextTertiary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: const TextStyle(
          fontSize: 16, 
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
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
        foregroundColor: AppColors.lightTextPrimary,
        side: const BorderSide(color: AppColors.lightCardBorder),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightHairline,
      thickness: 1,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.lightSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        side: const BorderSide(color: AppColors.lightCardBorder, width: 1),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.lightElevated,
      contentTextStyle: const TextStyle(color: AppColors.lightTextPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  // ═══════════════════════════════════════════════════════════════════
  // 文字主题
  // ═══════════════════════════════════════════════════════════════════
  static TextTheme _buildDarkTextTheme() {
    return GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    ).copyWith(
      displayLarge: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700),
      displayMedium: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700),
      displaySmall: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      headlineLarge: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      headlineMedium: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      headlineSmall: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      titleLarge: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
      titleMedium: const TextStyle(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w500),
      titleSmall: const TextStyle(color: AppColors.darkTextTertiary, fontWeight: FontWeight.w500),
      bodyLarge: const TextStyle(color: AppColors.darkTextPrimary),
      bodyMedium: const TextStyle(color: AppColors.darkTextSecondary),
      bodySmall: const TextStyle(color: AppColors.darkTextTertiary),
      labelLarge: const TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w500),
      labelMedium: const TextStyle(color: AppColors.darkTextSecondary, fontWeight: FontWeight.w500),
      labelSmall: const TextStyle(color: AppColors.darkTextTertiary, fontWeight: FontWeight.w500),
    );
  }

  static TextTheme _buildLightTextTheme() {
    return GoogleFonts.manropeTextTheme(ThemeData.light().textTheme).apply(
      bodyColor: AppColors.lightTextPrimary,
      displayColor: AppColors.lightTextPrimary,
    ).copyWith(
      displayLarge: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w700),
      displayMedium: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w700),
      displaySmall: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
      headlineLarge: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
      headlineMedium: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
      headlineSmall: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
      titleLarge: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
      titleMedium: const TextStyle(color: AppColors.lightTextSecondary, fontWeight: FontWeight.w500),
      titleSmall: const TextStyle(color: AppColors.lightTextTertiary, fontWeight: FontWeight.w500),
      bodyLarge: const TextStyle(color: AppColors.lightTextPrimary),
      bodyMedium: const TextStyle(color: AppColors.lightTextSecondary),
      bodySmall: const TextStyle(color: AppColors.lightTextTertiary),
      labelLarge: const TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w500),
      labelMedium: const TextStyle(color: AppColors.lightTextSecondary, fontWeight: FontWeight.w500),
      labelSmall: const TextStyle(color: AppColors.lightTextTertiary, fontWeight: FontWeight.w500),
    );
  }
}
