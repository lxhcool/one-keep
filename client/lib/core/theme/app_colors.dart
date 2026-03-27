import 'package:flutter/material.dart';

/// OneKeep 设计令牌 — 现代化配色方案
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════════════
  // 品牌色系统 — 统一使用 Teal 作为主色调
  // ═══════════════════════════════════════════════════════════════════
  static const teal = Color(0xFF14B8A6);
  static const tealLight = Color(0xFF2DD4BF);
  static const tealDark = Color(0xFF0D9488);
  static const tealMuted = Color(0xFF5EEAD4);
  
  // 辅助品牌色
  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFA78BFA);
  static const coral = Color(0xFFFB7185);
  static const amber = Color(0xFFF59E0B);

  // ═══════════════════════════════════════════════════════════════════
  // 语义色 — 支出/收入标识
  // ═══════════════════════════════════════════════════════════════════
  static const expense = Color(0xFFFB7185);      // 柔和珊瑚红
  static const expenseLight = Color(0xFFFECDD3);
  static const income = Color(0xFF14B8A6);       // 品牌青绿色
  static const incomeLight = Color(0xFF99F6E4);

  // ═══════════════════════════════════════════════════════════════════
  // 深色主题 — 深海蓝灰调，更有质感的夜间模式
  // ═══════════════════════════════════════════════════════════════════
  // 背景层次
  static const darkBg = Color(0xFF0F172A);           // 深海蓝背景
  static const darkSurface = Color(0xFF1E293B);      // 表面层
  static const darkElevated = Color(0xFF334155);     // 提升层
  
  // 卡片系统
  static const darkCard = Color(0xFF1E293B);
  static const darkCardHover = Color(0xFF334155);
  static const darkCardBorder = Color(0xFF334155);
  static const darkCardBorderStrong = Color(0xFF475569);
  
  // 玻璃拟态
  static const darkGlass = Color(0x1AFFFFFF);
  static const darkGlassStrong = Color(0x26FFFFFF);
  static const darkDimOverlay = Color(0x80000000);
  
  // 文字层次
  static const darkTextPrimary = Color(0xFFF8FAFC);
  static const darkTextSecondary = Color(0xFFCBD5E1);
  static const darkTextTertiary = Color(0xFF94A3B8);
  static const darkTextMuted = Color(0xFF64748B);
  
  // 输入与分隔
  static const darkInputBg = Color(0xFF334155);
  static const darkInputBorder = Color(0xFF475569);
  static const darkHairline = Color(0xFF334155);

  // ═══════════════════════════════════════════════════════════════════
  // 浅色主题 — 温暖米白调，更舒适的日间模式
  // ═══════════════════════════════════════════════════════════════════
  // 背景层次
  static const lightBg = Color(0xFFFAFAF9);          // 温暖米白
  static const lightSurface = Color(0xFFFFFFFF);     // 纯白表面
  static const lightElevated = Color(0xFFF5F5F4);    // 提升层
  
  // 卡片系统
  static const lightCard = Color(0xFFFFFFFF);
  static const lightCardHover = Color(0xFFF5F5F4);
  static const lightCardBorder = Color(0xFFE7E5E4);
  static const lightCardBorderStrong = Color(0xFFD6D3D1);
  
  // 玻璃拟态
  static const lightGlass = Color(0x80FFFFFF);
  static const lightDimOverlay = Color(0x40000000);
  
  // 文字层次
  static const lightTextPrimary = Color(0xFF1C1917);
  static const lightTextSecondary = Color(0xFF44403C);
  static const lightTextTertiary = Color(0xFF78716C);
  static const lightTextMuted = Color(0xFFA8A29E);
  
  // 输入与分隔
  static const lightInputBg = Color(0xFFF5F5F4);
  static const lightInputBorder = Color(0xFFE7E5E4);
  static const lightHairline = Color(0xFFE7E5E4);

  // ═══════════════════════════════════════════════════════════════════
  // 渐变系统
  // ═══════════════════════════════════════════════════════════════════
  static const expenseGradient = [Color(0xFFFB7185), Color(0xFFE11D48)];
  static const incomeGradient = [Color(0xFF14B8A6), Color(0xFF0D9488)];
  static const fabGradient = [Color(0xFF14B8A6), Color(0xFF8B5CF6)];
  static const cardGradientDark = [Color(0xFF1E293B), Color(0xFF0F172A)];
  static const cardGradientLight = [Color(0xFFFFFFFF), Color(0xFFFAFAF9)];

  // ═══════════════════════════════════════════════════════════════════
  // 功能色
  // ═══════════════════════════════════════════════════════════════════
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);
}

class AppSpacing {
  AppSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}

class AppRadius {
  AppRadius._();

  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const sheet = 24.0;
  static const card = 16.0;
  static const chip = 20.0;
  static const button = 12.0;
}
