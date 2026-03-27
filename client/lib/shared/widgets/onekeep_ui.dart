import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

enum OneKeepPageVariant { home, stats, bills }

TextStyle oneKeepGrotesk({
  required Color color,
  double size = 16,
  FontWeight weight = FontWeight.w600,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.spaceGrotesk(
    color: color,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
  );
}

TextStyle oneKeepManrope({
  required Color color,
  double size = 14,
  FontWeight weight = FontWeight.w500,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.manrope(
    color: color,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
  );
}

TextStyle oneKeepInter({
  required Color color,
  double size = 13,
  FontWeight weight = FontWeight.w500,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.inter(
    color: color,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
  );
}

TextStyle oneKeepMono({
  required Color color,
  double size = 12,
  FontWeight weight = FontWeight.w400,
  double? letterSpacing,
  double? height,
}) {
  return GoogleFonts.spaceMono(
    color: color,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
  );
}

class OneKeepGradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign textAlign;

  const OneKeepGradientText({
    super.key,
    required this.text,
    required this.style,
    required this.gradient,
    this.textAlign = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      child: Text(
        text,
        style: style.copyWith(color: Colors.white),
        textAlign: textAlign,
      ),
    );
  }
}

class OneKeepGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blurSigma;
  final Color fillColor;
  final Color borderColor;
  final List<BoxShadow> shadows;

  const OneKeepGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 18,
    this.blurSigma = 14,
    this.fillColor = AppColors.darkGlass,
    this.borderColor = AppColors.darkCardBorder,
    this.shadows = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 0.8),
            boxShadow: shadows,
          ),
          child: child,
        ),
      ),
    );
  }
}

class OneKeepPageBackground extends StatelessWidget {
  final Widget child;
  final OneKeepPageVariant variant;

  const OneKeepPageBackground({
    super.key,
    required this.child,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? AppColors.darkBg : AppColors.lightBg;
    return DecoratedBox(
      decoration: BoxDecoration(color: background),
      child: Stack(children: [..._buildGlows(isDark), child]),
    );
  }

  List<Widget> _buildGlows(bool isDark) {
    final light = [
      _glow(
        left: -40,
        top: 80,
        width: 220,
        height: 220,
        color: const Color(0x108B5CF6),
      ),
      _glow(
        right: -10,
        top: 180,
        width: 260,
        height: 260,
        color: const Color(0x104F46E5),
      ),
      _glow(
        left: 100,
        top: 450,
        width: 280,
        height: 280,
        color: const Color(0x08EF4444),
      ),
      _glow(
        right: -20,
        bottom: 40,
        width: 200,
        height: 200,
        color: const Color(0x083B82F6),
      ),
    ];

    switch (variant) {
      case OneKeepPageVariant.home:
        if (!isDark) return light;
        return [
          _glow(
            left: -40,
            top: 80,
            width: 220,
            height: 220,
            color: AppColors.purple.withValues(alpha: 0.22),
          ),
          _glow(
            right: -10,
            top: 180,
            width: 260,
            height: 260,
            color: AppColors.teal.withValues(alpha: 0.22),
          ),
          _glow(
            left: 100,
            top: 450,
            width: 280,
            height: 280,
            color: AppColors.expensePink.withValues(alpha: 0.18),
          ),
          _glow(
            right: -20,
            bottom: 40,
            width: 200,
            height: 200,
            color: AppColors.blue.withValues(alpha: 0.16),
          ),
        ];
      case OneKeepPageVariant.stats:
        if (!isDark) {
          return [
            _glow(
              right: -20,
              top: 120,
              width: 240,
              height: 240,
              color: const Color(0x104F46E5),
            ),
            _glow(
              left: -30,
              top: 300,
              width: 200,
              height: 200,
              color: const Color(0x108B5CF6),
            ),
          ];
        }
        return [
          _glow(
            right: -20,
            top: 120,
            width: 240,
            height: 240,
            color: AppColors.teal.withValues(alpha: 0.18),
          ),
          _glow(
            left: -30,
            top: 300,
            width: 200,
            height: 200,
            color: AppColors.purple.withValues(alpha: 0.16),
          ),
        ];
      case OneKeepPageVariant.bills:
        if (!isDark) {
          return [
            _glow(
              right: -20,
              top: 100,
              width: 200,
              height: 200,
              color: const Color(0x104F46E5),
            ),
            _glow(
              left: -40,
              top: 350,
              width: 180,
              height: 180,
              color: const Color(0x108B5CF6),
            ),
          ];
        }
        return [
          _glow(
            right: -20,
            top: 100,
            width: 200,
            height: 200,
            color: AppColors.teal.withValues(alpha: 0.14),
          ),
          _glow(
            left: -40,
            top: 350,
            width: 180,
            height: 180,
            color: AppColors.purple.withValues(alpha: 0.14),
          ),
        ];
    }
  }

  Widget _glow({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double width,
    required double height,
    required Color color,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: IgnorePointer(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}

String oneKeepCurrency(double value, {int decimals = 2}) {
  final fixed = value.toStringAsFixed(decimals);
  return fixed.replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+\.)'),
    (match) => '${match[1]},',
  );
}

String oneKeepDayTime(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);
  final prefix = day == today
      ? '今天'
      : day == today.subtract(const Duration(days: 1))
      ? '昨天'
      : '${dt.month}/${dt.day}';
  final hour = dt.hour.toString().padLeft(2, '0');
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$prefix $hour:$minute';
}

Color oneKeepTextPrimary(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
}

Color oneKeepTextSecondary(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
}

Color oneKeepTextTertiary(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
}

Color oneKeepSurface(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkSurface : AppColors.lightSurface;
}

Color oneKeepGlass(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkGlass : AppColors.lightSurface;
}

Color oneKeepGlassStrong(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkGlassStrong : AppColors.lightSurface;
}

Color oneKeepBorder(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkCardBorder : AppColors.lightHairline;
}

Color oneKeepBorderStrong(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkCardBorderStrong : AppColors.lightHairline;
}

Color oneKeepAccent(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.teal : AppColors.indigo;
}

class OneKeepAvatarPreset {
  final List<Color> colors;
  final IconData icon;

  const OneKeepAvatarPreset({required this.colors, required this.icon});
}

const oneKeepAvatarPresets = <OneKeepAvatarPreset>[
  OneKeepAvatarPreset(
    colors: [AppColors.teal, AppColors.indigo],
    icon: Icons.person_outline_rounded,
  ),
  OneKeepAvatarPreset(
    colors: [AppColors.purple, AppColors.indigo],
    icon: Icons.star_outline_rounded,
  ),
  OneKeepAvatarPreset(
    colors: [AppColors.expensePink, AppColors.purple],
    icon: Icons.favorite_border_rounded,
  ),
  OneKeepAvatarPreset(
    colors: [AppColors.tealLight, AppColors.teal],
    icon: Icons.bolt_rounded,
  ),
  OneKeepAvatarPreset(
    colors: [AppColors.warning, AppColors.expensePink],
    icon: Icons.wb_sunny_outlined,
  ),
  OneKeepAvatarPreset(
    colors: [AppColors.blue, AppColors.purple],
    icon: Icons.auto_awesome_rounded,
  ),
];

class OneKeepAvatar extends StatelessWidget {
  final int avatarIndex;
  final double size;
  final double iconSize;
  final String? avatarImageData;

  const OneKeepAvatar({
    super.key,
    required this.avatarIndex,
    this.size = 48,
    this.iconSize = 24,
    this.avatarImageData,
  });

  @override
  Widget build(BuildContext context) {
    final preset =
        oneKeepAvatarPresets[avatarIndex % oneKeepAvatarPresets.length];
    final imageBytes = _decodeAvatarBytes(avatarImageData);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: preset.colors,
        ),
        boxShadow: [
          BoxShadow(
            color: preset.colors.first.withValues(alpha: 0.3),
            blurRadius: size * 0.24,
          ),
        ],
      ),
      child: ClipOval(
        child: imageBytes != null
            ? Image.memory(imageBytes, fit: BoxFit.cover)
            : Icon(preset.icon, size: iconSize, color: Colors.white),
      ),
    );
  }

  Uint8List? _decodeAvatarBytes(String? data) {
    if (data == null || data.isEmpty) return null;
    final normalized = data.contains(',')
        ? data.substring(data.indexOf(',') + 1)
        : data;
    try {
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }
}

IconData oneKeepCategoryIcon(String title, String category, String fallback) {
  final haystack = '$title $category $fallback';
  if (haystack.contains('午餐') ||
      haystack.contains('餐') ||
      haystack.contains('食') ||
      haystack.contains('restaurant')) {
    return Icons.restaurant_rounded;
  }
  if (haystack.contains('地铁') ||
      haystack.contains('交通') ||
      haystack.contains('公交') ||
      haystack.contains('subway') ||
      haystack.contains('bus')) {
    return Icons.directions_subway_rounded;
  }
  if (haystack.contains('工资') ||
      haystack.contains('薪') ||
      haystack.contains('salary') ||
      haystack.contains('wallet')) {
    return Icons.account_balance_wallet_rounded;
  }
  if (haystack.contains('咖啡') || haystack.contains('coffee')) {
    return Icons.local_cafe_rounded;
  }
  if (haystack.contains('购物') ||
      haystack.contains('超市') ||
      haystack.contains('shopping') ||
      haystack.contains('bag')) {
    return Icons.shopping_bag_rounded;
  }
  if (haystack.contains('bank')) {
    return Icons.account_balance_rounded;
  }
  return Icons.receipt_long_rounded;
}
