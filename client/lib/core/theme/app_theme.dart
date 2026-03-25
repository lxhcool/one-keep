import 'package:flutter/material.dart';

abstract final class AppColors {
  static const accentGreen = Color(0xFF22C55E);
  static const accentGreenDark = Color(0xFF16A34A);
  static const accentRed = Color(0xFFEF4444);

  static const bgPrimary = Color(0xFFFFFFFF);
  static const bgCard = Color(0xFFF9FAFB);
  static const bgIncome = Color(0xFFF0FDF4);
  static const bgExpense = Color(0xFFFFF1F2);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);

  static const borderSubtle = Color(0xFFE5E7EB);

  static const shimmerBase = Color(0xFFE5E7EB);
  static const shimmerHighlight = Color(0xFFF3F4F6);
}

abstract final class AppRadius {
  static const double large = 20;
  static const double medium = 12;
  static const double small = 8;
}

abstract final class AppSpacing {
  static const double section = 24;
  static const double card = 12;
}

abstract final class AppTheme {
  static ThemeData get theme => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accentGreen),
        scaffoldBackgroundColor: AppColors.bgPrimary,
        useMaterial3: true,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
      );
}
