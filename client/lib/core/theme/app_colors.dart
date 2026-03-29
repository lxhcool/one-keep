import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors - Warm Yellow Brand System
  static const teal = Color(0xFFEDC100); // Main brand color
  static const tealLight = Color(0xFFF3D24A);
  static const tealDark = Color(0xFFC99F00);
  static const tealMuted = Color(0xFFF8E28A);

  static const purple = Color(0xFF6366F1); // Indigo 500 - Accent color
  static const purpleLight = Color(0xFFA5B4FC); // Indigo 300
  static const coral = Color(0xFFFB7185);
  static const amber = Color(0xFFF59E0B); // Amber 500 - Secondary color
  static const amberLight = Color(0xFFFBBF24); // Amber 400

  static const expense = Color(0xFFEF4444); // Red 500 - Softer red
  static const expenseLight = Color(0xFFFCA5A5); // Red 300
  static const income = Color(0xFF22C55E); // Green 500 - Brighter green
  static const incomeLight = Color(0xFF86EFAC); // Green 300

  // Minimalist Premium Dark Mode
  static const darkBg = Color(0xFF0A0A0B); // True black for OLED
  static const darkBgSecondary = Color(0xFF121214); // Secondary background
  static const darkSurface = Color(0xFF1C1C1F); // Surface color
  static const darkElevated = Color(0xFF2C2C30); // Elevated surface
  static const darkCard = Color(0xFF27272A); // Card color
  static const darkCardHover = Color(0xFF2C2C30);
  static const darkCardBorder = Color(0x28FFFFFF); // Improved contrast
  static const darkCardBorderStrong = Color(0x40FFFFFF); // Stronger border
  static const darkGlass = Color(0x80272727);
  static const darkGlassStrong = Color(0xCC1C1C1F);
  static const darkGlassSoft = Color(0x40272727);
  static const darkNav = Color(0xE60A0A0B);
  static const darkInputBg = Color(0xFF1C1C1F);
  static const darkInputBorder = Color(0x28FFFFFF);
  static const darkHairline = Color(0x1AFFFFFF);
  static const darkShadow = Color(0x99000000);
  static const darkDimOverlay = Color(0xB3000000);

  static const darkTextPrimary = Color(0xFFFAFAFA);
  static const darkTextSecondary = Color(0xFFB4B4B8); // Improved contrast
  static const darkTextTertiary = Color(0xFF85858A); // Improved contrast
  static const darkTextMuted = Color(0xFF52525B);

  // Minimalist Premium Light Mode
  static const lightBg = Color(0xFFFAFAFA); // Softer gray-white
  static const lightBgSecondary = Color(0xFFF5F5F5); // Secondary background
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightElevated = Color(0xFFFAFAFA);
  static const lightCard = Color(0xFFFFFFFF); // Solid white cards
  static const lightCardHover = Color(0xFFF5F5F5);
  static const lightCardBorder = Color(0x14000000); // Improved contrast
  static const lightCardBorderStrong = Color(0x28000000); // Stronger border
  static const lightGlass = Color(0xCCFFFFFF);
  static const lightGlassStrong = Color(0xE6FFFFFF);
  static const lightGlassSoft = Color(0x80FFFFFF);
  static const lightNav = Color(0xE6FFFFFF);
  static const lightInputBg = Color(0xFFFFFFFF);
  static const lightInputBorder = Color(0x1A000000);
  static const lightHairline = Color(0x0D000000);
  static const lightShadow = Color(0x1A000000); // Softer shadows
  static const lightDimOverlay = Color(0x66000000);

  static const lightTextPrimary = Color(0xFF18181B); // Improved contrast
  static const lightTextSecondary = Color(0xFF52525B);
  static const lightTextTertiary = Color(0xFF71717A);
  static const lightTextMuted = Color(0xFFA1A1AA);

  static const expenseGradient = [Color(0xFFEF4444), Color(0xFFDC2626)];
  static const incomeGradient = [Color(0xFF22C55E), Color(0xFF16A34A)];
  static const fabGradient = [Color(0xFFF3D24A), Color(0xFFEDC100)];
  
  // Balance card gradients
  static const balanceGradientDark = [Color(0xFF1E293B), Color(0xFF0F172A)]; // Slate
  static const balanceGradientLight = [Color(0xFFF3D24A), Color(0xFFEDC100)];
  static const cardGradientDark = [Color(0xFF1C1C1F), Color(0xFF0A0A0B)];
  static const cardGradientLight = [Color(0xFFFFFFFF), Color(0xFFFAFAFA)];

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

  // 8pt Grid System
  static const unit = 8.0;
  
  static const xxs = 4.0;   // 0.5x
  static const xs = 8.0;    // 1x
  static const sm = 12.0;   // 1.5x
  static const md = 16.0;   // 2x
  static const lg = 24.0;   // 3x
  static const xl = 32.0;   // 4x
  static const xxl = 40.0;  // 5x
  static const xxxl = 48.0; // 6x
  
  // Page spacing
  static const pagePadding = 20.0;
  static const pageTop = 16.0;
  static const pageBottom = 110.0;
  
  // Card spacing
  static const cardGap = 16.0;
  static const cardPadding = 20.0;
  
  // List spacing
  static const listItemGap = 12.0;
  static const listSectionGap = 24.0;
}

class AppSize {
  AppSize._();
  
  // Touch targets
  static const minTouchTarget = 44.0;
  
  // Icons
  static const iconXs = 16.0;
  static const iconSm = 20.0;
  static const iconMd = 24.0;
  static const iconLg = 28.0;
  static const iconXl = 32.0;
  
  // Avatars
  static const avatarSm = 32.0;
  static const avatarMd = 48.0;
  static const avatarLg = 64.0;
  
  // Buttons
  static const buttonSm = 36.0;
  static const buttonMd = 44.0;
  static const buttonLg = 52.0;
}

class AppRadius {
  AppRadius._();

  static const xs = 8.0;    // Small components
  static const sm = 12.0;   // Buttons, inputs
  static const md = 16.0;   // Small cards, list items
  static const lg = 20.0;   // Standard cards
  static const xl = 24.0;   // Large cards, balance card
  static const xxl = 28.0;  // Bottom sheets
  
  static const sheet = 24.0;
  static const card = 16.0;
  static const chip = 20.0;
  static const button = 12.0;
  static const round = 999.0;
  static const pill = 100.0;
}
