import 'package:flutter/material.dart';

/// OneKeep 设计令牌 — 源自 Pencil 设计稿
class AppColors {
  AppColors._();

  // ─── 品牌色 ───
  static const teal = Color(0xFF00CEC9);
  static const tealLight = Color(0xFF2AA79B);
  static const indigo = Color(0xFF4F46E5);
  static const purple = Color(0xFF8B5CF6);
  static const blue = Color(0xFF3B82F6);

  // ─── 语义色 ───
  static const expensePink = Color(0xFFFF6B9D);
  static const expenseRed = Color(0xFFEF4444);
  static const incomeTeal = Color(0xFF00CEC9);
  static const incomeGreen = Color(0xFF10B981);

  // ─── 深色主题 ───
  static const darkBg = Color(0xFF0A0A0A);
  static const darkSurface = Color(0xFF16181F);
  static const darkCard = Color(0x08FFFFFF);
  static const darkCardBorder = Color(0x0FFFFFFF);
  static const darkCardBorderStrong = Color(0x20FFFFFF);
  static const darkGlass = Color(0x08FFFFFF);
  static const darkGlassStrong = Color(0x10FFFFFF);
  static const darkDimOverlay = Color(0x70000000);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFA1A1AA);
  static const darkTextTertiary = Color(0xFF52525B);
  static const darkTextSoft = Color(0x99FFFFFF);
  static const darkInputBg = Color(0x12FFFFFF);
  static const darkHairline = Color(0x15FFFFFF);

  // ─── 浅色主题 ───
  static const lightBg = Color(0xFFF3F6FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFF8FAFC);
  static const lightCardBorder = Color(0xFFDCE3EC);
  static const lightDimOverlay = Color(0x40000000);
  static const lightTextPrimary = Color(0xFF111827);
  static const lightTextSecondary = Color(0xFF475569);
  static const lightTextTertiary = Color(0xFF64748B);
  static const lightInputBg = Color(0xFFF0F4F8);
  static const lightHairline = Color(0xFFD8E0EA);

  // ─── 图表渐变 ───
  static const expenseGradient = [Color(0xFFFF6B9D), Color(0xFF6C5CE7)];
  static const incomeGradient = [Color(0xFF80FFEA), Color(0xFF00CEC9)];
  static const fabGradientDark = [Color(0xFF00CEC9), Color(0xFF6C5CE7)];
  static const fabGradientLight = [Color(0xFF4F46E5), Color(0xFF8B5CF6)];

  // ─── 分类高亮 ───
  static const tealHighlight = Color(0x3300CEC9); // 20%

  // ─── 功能色 ───
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
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
