import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/onekeep_iconfont.dart';

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

const List<Color> oneKeepCategoryColorPresets = <Color>[
  Color(0xFFFF8A65),
  Color(0xFFFFB74D),
  Color(0xFFFFD54F),
  Color(0xFF81C784),
  Color(0xFF4DB6AC),
  Color(0xFF4FC3F7),
  Color(0xFF7986CB),
  Color(0xFFBA68C8),
  Color(0xFFF06292),
  Color(0xFFA1887F),
];

Color? oneKeepParseHexColor(String? value) {
  if (value == null || value.isEmpty) return null;
  final normalized = value.trim().replaceAll('#', '');
  if (normalized.length != 6 && normalized.length != 8) return null;
  final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
  final parsed = int.tryParse(hex, radix: 16);
  return parsed == null ? null : Color(parsed);
}

String oneKeepColorToHex(Color color) {
  final rgb = color.toARGB32() & 0x00FFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

Color oneKeepCategoryTone({
  String? colorHex,
  String? categoryId,
  String? categoryName,
  String? categoryIcon,
}) {
  final explicit = oneKeepParseHexColor(colorHex);
  if (explicit != null) return explicit;

  final seed = '${categoryId ?? ''}|${categoryName ?? ''}|${categoryIcon ?? ''}';
  var hash = 0;
  for (final codeUnit in seed.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return oneKeepCategoryColorPresets[hash % oneKeepCategoryColorPresets.length];
}

class OneKeepCategoryBadge extends StatelessWidget {
  final String title;
  final String categoryName;
  final String categoryIcon;
  final String? categoryId;
  final String? colorHex;
  final double size;
  final double iconSize;
  final double radius;
  final double fillOpacity;
  final double borderOpacity;
  final bool showBorder;

  const OneKeepCategoryBadge({
    super.key,
    required this.title,
    required this.categoryName,
    required this.categoryIcon,
    this.categoryId,
    this.colorHex,
    this.size = 44,
    this.iconSize = 22,
    this.radius = 12,
    this.fillOpacity = 0.12,
    this.borderOpacity = 0,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final tone = oneKeepCategoryTone(
      colorHex: colorHex,
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
    );
    final icon = oneKeepResolvedCategoryIcon(title, categoryName, categoryIcon);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tone.withValues(alpha: fillOpacity),
        borderRadius: BorderRadius.circular(radius),
        border: showBorder
            ? Border.all(
                color: tone.withValues(alpha: borderOpacity),
                width: 0.8,
              )
            : null,
      ),
      child: Icon(icon, size: iconSize, color: tone),
    );
  }
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
    this.radius = 24, // Rounder, sleeker corners
    this.blurSigma = 16,
    this.fillColor,
    this.borderColor,
    this.shadows,
    this.gradient,
    this.showHighlight = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedFill =
        fillColor ?? (isDark ? const Color(0xFF18181B) : Colors.white);
    final resolvedBorder = borderColor ?? oneKeepBorder(context);
    final resolvedShadows = shadows ?? oneKeepCardShadows(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: resolvedShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: resolvedFill,
              gradient: gradient,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: resolvedBorder,
                width: isDark ? 0.5 : 1.0,
              ), // Crisper border
            ),
            child: child,
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
          if (isDark) // Only add the top left ambient glow in dark mode
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.75, -0.95),
                    radius: 1.5,
                    colors: [
                      AppColors.teal.withValues(alpha: 0.05),
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
    if (!isDark) return []; // Completely clean in light mode

    // Very subtle ambient lights in dark mode
    switch (variant) {
      case OneKeepPageVariant.auth:
        return [
          _glow(
            left: -80,
            top: -40,
            width: 280,
            height: 280,
            color: AppColors.purple.withValues(alpha: 0.05),
          ),
          _glow(
            right: -60,
            bottom: 40,
            width: 260,
            height: 260,
            color: AppColors.teal.withValues(alpha: 0.05),
          ),
        ];
      case OneKeepPageVariant.home:
        return [
          _glow(
            left: -40,
            top: 80,
            width: 320,
            height: 320,
            color: AppColors.teal.withValues(alpha: 0.06),
          ),
          _glow(
            right: -20,
            bottom: 40,
            width: 300,
            height: 300,
            color: AppColors.purple.withValues(alpha: 0.04),
          ),
        ];
      case OneKeepPageVariant.stats:
      case OneKeepPageVariant.bills:
      case OneKeepPageVariant.profile:
        return [
          _glow(
            right: -20,
            top: 120,
            width: 240,
            height: 240,
            color: AppColors.teal.withValues(alpha: 0.05),
          ),
          _glow(
            left: -30,
            top: 300,
            width: 200,
            height: 200,
            color: AppColors.purple.withValues(alpha: 0.04),
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
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: isDark
        ? const [Color(0xFF09090B), Color(0xFF09090B)] // Solid deep black
        : const [Color(0xFFF4F4F5), Color(0xFFE4E4E7)], // Clean cool light gray
  );
}

Gradient oneKeepPanelGradient(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: isDark
        ? [const Color(0xFF18181B), const Color(0xFF18181B)]
        : [Colors.white, Colors.white],
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

  if (isDark) {
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: prominent ? 0.7 : 0.5),
        blurRadius: prominent ? 36 : 20,
        offset: Offset(0, prominent ? 18 : 10),
      ),
      BoxShadow(
        color: AppColors.teal.withValues(alpha: prominent ? 0.15 : 0.08),
        blurRadius: prominent ? 24 : 12,
        offset: Offset(0, prominent ? 8 : 4),
      ),
    ];
  }

  return [
    BoxShadow(
      color: AppColors.teal.withValues(alpha: prominent ? 0.12 : 0.06),
      blurRadius: prominent ? 28 : 16,
      offset: Offset(0, prominent ? 10 : 6),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: prominent ? 0.04 : 0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
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

class OneKeepAvatar extends StatefulWidget {
  final int avatarIndex;
  final double size;
  final double iconSize;
  final String? avatarImageData;
  final bool usePresetStyleWhenNoImage;

  const OneKeepAvatar({
    super.key,
    required this.avatarIndex,
    this.size = 48,
    this.iconSize = 24,
    this.avatarImageData,
    this.usePresetStyleWhenNoImage = false,
  });

  @override
  State<OneKeepAvatar> createState() => _OneKeepAvatarState();
}

class _OneKeepAvatarState extends State<OneKeepAvatar> {
  MemoryImage? _avatarProvider;

  @override
  void initState() {
    super.initState();
    _syncAvatarProvider();
  }

  @override
  void didUpdateWidget(covariant OneKeepAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarImageData != widget.avatarImageData) {
      _syncAvatarProvider();
    }
  }

  @override
  Widget build(BuildContext context) {
    final preset =
        oneKeepAvatarPresets[widget.avatarIndex % oneKeepAvatarPresets.length];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showPresetStyle = widget.usePresetStyleWhenNoImage && _avatarProvider == null;
    final decoration = BoxDecoration(
      shape: BoxShape.circle,
      color: showPresetStyle
          ? null
          : (isDark ? const Color(0xFF3F3F46) : const Color(0xFFE5E7EB)),
      gradient: showPresetStyle
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: preset.colors,
            )
          : null,
    );

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: decoration,
      child: ClipOval(
        child: _avatarProvider != null
            ? Image(
                image: _avatarProvider!,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              )
            : Icon(
                showPresetStyle
                    ? preset.icon
                    : Icons.person_outline_rounded,
                size: widget.iconSize,
                color: Colors.white,
              ),
      ),
    );
  }

  void _syncAvatarProvider() {
    final bytes = _decodeAvatarBytes(widget.avatarImageData);
    _avatarProvider = bytes == null ? null : MemoryImage(bytes);
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

IconData oneKeepResolvedCategoryIcon(
  String title,
  String category,
  String fallback,
) {
  final iconfontIcon =
      oneKeepIconFont(fallback) ??
      oneKeepIconFont(category) ??
      oneKeepIconFont(title);
  if (iconfontIcon != null) {
    return iconfontIcon;
  }

  final haystack = '$title $category $fallback'.toLowerCase();
  if (haystack.contains('用餐') ||
      haystack.contains('早餐') ||
      haystack.contains('宵夜') ||
      haystack.contains('餐') ||
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

class OneKeepBouncingCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;

  const OneKeepBouncingCard({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<OneKeepBouncingCard> createState() => _OneKeepBouncingCardState();
}

class _OneKeepBouncingCardState extends State<OneKeepBouncingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleFactor)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _controller.reverse();
      widget.onTap!();
    }
  }

  void _onTapCancel() {
    if (widget.onTap != null) _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

