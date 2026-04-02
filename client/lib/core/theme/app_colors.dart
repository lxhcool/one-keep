import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- 北欧森林 (Nordic Emerald) 核心系统 ---
  static const emerald = Color(0xFF059669); 
  static const emeraldLight = Color(0xFF10B981);
  static const emeraldDark = Color(0xFF047857);
  static const emeraldSoft = Color(0xFFD1FAE5);

  // 辅助色
  static const amber = Color(0xFFD97706);
  static const amberLight = Color(0xFFF59E0B);
  static const indigo = Color(0xFF4F46E5); // 对应旧版的 purple
  static const rose = Color(0xFFE11D48);   // 对应旧版的 expense/error

  // 功能色别名 (兼容旧代码)
  static const teal = emerald;
  static const tealLight = emeraldLight;
  static const tealDark = emeraldDark;
  static const purple = indigo; 
  static const error = rose;
  static const expense = rose;
  static const income = emerald;
  static const info = Color(0xFF0EA5E9);
  static const warning = amberLight;
  static const success = emeraldLight;

  // --- 深色模式 (Deep Forest) ---
  static const darkBg = Color(0xFF0D1111);
  static const darkBgSecondary = Color(0xFF151B1B);
  static const darkSurface = Color(0xFF1C2424);
  static const darkElevated = Color(0xFF242C2C);
  static const darkCard = Color(0xFF1C2424);
  static const darkBorder = Color(0xFF2A3333);
  static const darkCardBorder = Color(0xFF2A3333);
  static const darkCardBorderStrong = Color(0xFF364040);
  static const darkInputBg = Color(0xFF151B1B);
  static const darkInputBorder = Color(0xFF2A3333);
  static const darkShadow = Colors.black;
  static const darkDimOverlay = Color(0x99000000);
  static const darkGlass = Color(0x1AFFFFFF);
  static const darkGlassStrong = Color(0x33FFFFFF);

  static const darkTextPrimary = Color(0xFFECECEC);
  static const darkTextSecondary = Color(0xFFA1A8A1);
  static const darkTextTertiary = Color(0xFF6B726B);

  // --- 浅色模式 (Soft Mist) ---
  static const lightBg = Color(0xFFF8FAF9);
  static const lightBgSecondary = Color(0xFFF0F4F2);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightElevated = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE2E8E5);
  static const lightCardBorder = Color(0xFFE2E8E5);
  static const lightCardBorderStrong = Color(0xFFD1D9D5);
  static const lightInputBg = Color(0xFFF0F4F2);
  static const lightInputBorder = Color(0xFFE2E8E5);
  static const lightShadow = Color(0x0D000000);
  static const lightDimOverlay = Color(0x66000000);
  static const lightGlass = Color(0x1A000000);
  static const lightGlassStrong = Color(0x33000000);
  static const lightHairline = Color(0xFFE2E8E5);

  static const lightTextPrimary = Color(0xFF1A201E);
  static const lightTextSecondary = Color(0xFF5F6B68);
  static const lightTextTertiary = Color(0xFF94A3A0);

  // 渐变色
  static const List<Color> balanceGradientDark = [Color(0xFF151B1B), Color(0xFF0D1111)];
  static const List<Color> balanceGradientLight = [Color(0xFF059669), Color(0xFF10B981)];

  // 通用
  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
}

class AppRadius {
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  
  // 语义化映射 (兼容旧代码)
  static const double card = 16.0;
  static const double sheet = 24.0;
  static const double chip = 20.0;
  static const double button = 12.0;
  static const double xxl = 28.0;
  static const double round = 999.0;
  static const double pill = 100.0;
}

class AppSize {
  static const double navBarHeight = 64.0;
  static const double fabSize = 64.0;
}
