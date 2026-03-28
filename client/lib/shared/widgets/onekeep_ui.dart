import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

enum OneKeepPageVariant { auth, home, stats, bills, profile }

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
  final Color? fillColor;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final Gradient? gradient;
  final bool showHighlight;

  const OneKeepGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 18,
    this.blurSigma = 14,
    this.fillColor,
    this.borderColor,
    this.shadows,
    this.gradient,
    this.showHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedFill = fillColor ?? oneKeepGlass(context);
    final resolvedBorder = borderColor ?? oneKeepBorder(context);
    final resolvedShadows = shadows ?? oneKeepCardShadows(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: resolvedShadows,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: resolvedFill,
              gradient: gradient,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: resolvedBorder, width: 0.8),
            ),
            child: Stack(
              children: [
                if (showHighlight)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    child: IgnorePointer(
                      child: Container(
                        height: radius * 1.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(radius),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.18),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OneKeepSheetSurface extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  const OneKeepSheetSurface({
    super.key,
    required this.child,
    this.padding,
    this.radius = AppRadius.sheet,
  });

  @override
  Widget build(BuildContext context) {
    return OneKeepGlassCard(
      radius: radius,
      blurSigma: 28,
      padding: padding ?? EdgeInsets.zero,
      fillColor: oneKeepSurface(context),
      borderColor: oneKeepBorderStrong(context),
      shadows: oneKeepCardShadows(context, prominent: true),
      gradient: oneKeepPanelGradient(context),
      child: child,
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
    return DecoratedBox(
      decoration: BoxDecoration(gradient: oneKeepPageGradient(context)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.75, -0.95),
                  radius: isDark ? 1.25 : 1.1,
                  colors: [
                    (isDark ? AppColors.teal : AppColors.info).withValues(
                      alpha: isDark ? 0.12 : 0.10,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          ..._buildGlows(isDark),
          child,
        ],
      ),
    );
  }

  List<Widget> _buildGlows(bool isDark) {
    switch (variant) {
      case OneKeepPageVariant.auth:
        return [
          _glow(
            left: -80,
            top: -40,
            width: 280,
            height: 280,
            color: isDark
                ? AppColors.purple.withValues(alpha: 0.22)
                : AppColors.purple.withValues(alpha: 0.12),
          ),
          _glow(
            right: -60,
            bottom: 40,
            width: 260,
            height: 260,
            color: isDark
                ? AppColors.teal.withValues(alpha: 0.20)
                : AppColors.teal.withValues(alpha: 0.10),
          ),
        ];
      case OneKeepPageVariant.home:
        if (!isDark) {
          return [
            _glow(
              left: -60,
              top: 40,
              width: 240,
              height: 240,
              color: const Color(0x1C94A3FF),
            ),
            _glow(
              right: -30,
              top: 160,
              width: 280,
              height: 280,
              color: const Color(0x1C7DD3FC),
            ),
            _glow(
              left: 110,
              bottom: 80,
              width: 260,
              height: 260,
              color: const Color(0x17C4B5FD),
            ),
          ];
        }
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
            color: AppColors.expense.withValues(alpha: 0.18),
          ),
          _glow(
            right: -20,
            bottom: 40,
            width: 200,
            height: 200,
            color: AppColors.info.withValues(alpha: 0.16),
          ),
        ];
      case OneKeepPageVariant.stats:
        if (!isDark) {
          return [
            _glow(
              right: -40,
              top: 100,
              width: 260,
              height: 260,
              color: const Color(0x1854C5FF),
            ),
            _glow(
              left: -40,
              top: 320,
              width: 220,
              height: 220,
              color: const Color(0x18A78BFA),
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
              width: 220,
              height: 220,
              color: const Color(0x1660A5FA),
            ),
            _glow(
              left: -50,
              top: 350,
              width: 210,
              height: 210,
              color: const Color(0x1494A3FF),
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
      case OneKeepPageVariant.profile:
        return [
          _glow(
            left: -60,
            top: -40,
            width: 260,
            height: 260,
            color: isDark
                ? AppColors.teal.withValues(alpha: 0.18)
                : AppColors.teal.withValues(alpha: 0.12),
          ),
          _glow(
            right: -40,
            top: 200,
            width: 280,
            height: 280,
            color: isDark
                ? AppColors.purple.withValues(alpha: 0.18)
                : AppColors.purple.withValues(alpha: 0.10),
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

Gradient oneKeepPageGradient(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? const [Color(0xFF07111F), Color(0xFF0C1730), Color(0xFF101C2D)]
        : const [Color(0xFFF6FAFD), Color(0xFFEAF2FF), Color(0xFFF8FBFF)],
  );
}

Gradient oneKeepPanelGradient(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark ? AppColors.cardGradientDark : AppColors.cardGradientLight,
  );
}

Color oneKeepGlass(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkGlass : AppColors.lightGlass;
}

Color oneKeepGlassStrong(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkGlassStrong : AppColors.lightGlassStrong;
}

Color oneKeepBorder(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkCardBorder : AppColors.lightHairline;
}

Color oneKeepBorderStrong(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkCardBorderStrong : AppColors.lightCardBorder;
}

Color oneKeepAccent(BuildContext context) {
  return AppColors.teal;
}

Color oneKeepDimOverlay(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.darkDimOverlay : AppColors.lightDimOverlay;
}

List<BoxShadow> oneKeepCardShadows(
  BuildContext context, {
  bool prominent = false,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final base = isDark ? AppColors.darkShadow : AppColors.lightShadow;

  return [
    BoxShadow(
      color: base.withValues(alpha: prominent ? 0.38 : 0.22),
      blurRadius: prominent ? 40 : 22,
      offset: Offset(0, prominent ? 18 : 10),
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: isDark ? 0.02 : 0.25),
      blurRadius: prominent ? 14 : 8,
      offset: const Offset(0, 1),
      spreadRadius: -2,
    ),
  ];
}

Color oneKeepIncomeTone(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? AppColors.tealLight : AppColors.teal;
}

class OneKeepAvatarPreset {
  final List<Color> colors;
  final IconData icon;

  const OneKeepAvatarPreset({required this.colors, required this.icon});
}

const oneKeepAvatarPresets = <OneKeepAvatarPreset>[
  OneKeepAvatarPreset(
    colors: [AppColors.teal, AppColors.purple],
    icon: Icons.person_outline_rounded,
  ),
  OneKeepAvatarPreset(
    colors: [AppColors.purple, AppColors.teal],
    icon: Icons.star_outline_rounded,
  ),
  OneKeepAvatarPreset(
    colors: [AppColors.expense, AppColors.purple],
    icon: Icons.favorite_border_rounded,
  ),
  OneKeepAvatarPreset(
    colors: [AppColors.tealLight, AppColors.teal],
    icon: Icons.bolt_rounded,
  ),
  OneKeepAvatarPreset(
    colors: [AppColors.amber, AppColors.expense],
    icon: Icons.wb_sunny_outlined,
  ),
  OneKeepAvatarPreset(
    colors: [AppColors.info, AppColors.purple],
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
