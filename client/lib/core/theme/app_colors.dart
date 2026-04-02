import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- 纯净北欧森林 (Pure Nordic Emerald) 调色盘 ---
  
  // 核心强调色 - 提升了一点点亮度的祖母绿，更通透
  static const emerald = Color(0xFF10B981); 
  static const emeraldLight = Color(0xFF34D399);
  static const emeraldDark = Color(0xFF059669);
  static const emeraldSoft = Color(0xFFECFDF5);

  // 辅助色
  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFBBF24);
  static const indigo = Color(0xFF6366F1);
  static const rose = Color(0xFFF43F5E); // 玫瑰红，更明亮

  // 功能色映射
  static const teal = emerald;
  static const tealLight = emeraldLight;
  static const tealDark = emeraldDark;
  static const purple = indigo; 
  static const error = rose;
  static const expense = rose;
  static const income = emerald;
  static const info = Color(0xFF0EA5E9);
  static const warning = amber;
  static const success = emerald;

  // --- 极致深色模式 (Deep Night) ---
  // 彻底告别“灰蒙蒙”，改用更纯粹的深色
  static const darkBg = Color(0xFF050707);          // 更深的墨黑
  static const darkBgSecondary = Color(0xFF0D1111); // 次级背景
  static const darkSurface = Color(0xFF121717);     // 表面色
  static const darkElevated = Color(0xFF1A2020);
  static const darkCard = Color(0xFF121717);
  static const darkBorder = Color(0xFF1E2626);      // 调淡边框
  static const darkCardBorder = Color(0xFF1E2626);
  static const darkCardBorderStrong = Color(0xFF2A3333);
  static const darkInputBg = Color(0xFF0D1111);
  static const darkInputBorder = Color(0xFF1E2626);
  static const darkShadow = Colors.black;
  static const darkDimOverlay = Color(0xCC000000);
  static const darkGlass = Color(0x1AFFFFFF);
  static const darkGlassStrong = Color(0x33FFFFFF);

  static const darkTextPrimary = Color(0xFFF3F4F6);   // 接近纯白的灰
  static const darkTextSecondary = Color(0xFF9CA3AF); // 更清晰的次要文字
  static const darkTextTertiary = Color(0xFF6B7280);

  // --- 纯净浅色模式 (Crisp White) ---
  // 去除灰色调，追求极致通透
  static const lightBg = Color(0xFFFCFDFD);           // 极简冷白
  static const lightBgSecondary = Color(0xFFF3F4F6);  // 淡灰蓝
  static const lightSurface = Color(0xFFFFFFFF);      // 纯白
  static const lightElevated = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFF1F5F9);       // 极淡的边框线
  static const lightCardBorder = Color(0xFFF1F5F9);
  static const lightCardBorderStrong = Color(0xFFE2E8F0);
  static const lightInputBg = Color(0xFFF8FAFC);
  static const lightInputBorder = Color(0xFFF1F5F9);
  static const lightShadow = Color(0x0A000000);
  static const lightDimOverlay = Color(0x4D000000);
  static const lightGlass = Color(0x0D000000);
  static const lightGlassStrong = Color(0x1A000000);
  static const lightHairline = Color(0xFFF1F5F9);

  static const lightTextPrimary = Color(0xFF0F172A);   // 深石板色，替代墨绿黑，更清晰
  static const lightTextSecondary = Color(0xFF475569); // 中石板色
  static const lightTextTertiary = Color(0xFF94A3B8);

  // 首页专用渐变
  static const List<Color> balanceGradientDark = [Color(0xFF0D1111), Color(0xFF050707)];
  static const List<Color> balanceGradientLight = [Color(0xFF10B981), Color(0xFF059669)];

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
