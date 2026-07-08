import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/category_icons.dart';
import '../../core/theme/onekeep_iconfont.dart';

enum OneKeepPageVariant { auth, home, stats, bills, profile }

enum OneKeepToastType { success, error, info }

OverlayEntry? _activeOneKeepToastEntry;

// ── Google Fonts 已离线打包 ──
const _fontFamilyInter = 'Inter';
const _fontFamilyManrope = 'Manrope';
const _fontFamilyGrotesk = 'SpaceGrotesk';
const _fontFamilyMono = 'SpaceMono';

TextStyle oneKeepGrotesk({
  required Color color,
  double size = 16,
  FontWeight weight = FontWeight.w600,
  double? letterSpacing,
  double? height,
}) {
  return TextStyle(
    fontFamily: _fontFamilyGrotesk,
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
  return TextStyle(
    fontFamily: _fontFamilyManrope,
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
  return TextStyle(
    fontFamily: _fontFamilyInter,
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
  return TextStyle(
    fontFamily: _fontFamilyMono,
    color: color,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
  );
}

void showOneKeepToast(
  BuildContext context, {
  required String message,
  OneKeepToastType type = OneKeepToastType.info,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  _activeOneKeepToastEntry?.remove();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _OneKeepToastOverlay(
      message: message,
      type: type,
      duration: duration,
      onDismissed: () {
        if (_activeOneKeepToastEntry == entry) {
          _activeOneKeepToastEntry = null;
        }
        entry.remove();
      },
    ),
  );

  _activeOneKeepToastEntry = entry;
  overlay.insert(entry);
}

class _OneKeepToastOverlay extends StatefulWidget {
  final String message;
  final OneKeepToastType type;
  final Duration duration;
  final VoidCallback onDismissed;

  const _OneKeepToastOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_OneKeepToastOverlay> createState() => _OneKeepToastOverlayState();
}

class _OneKeepToastOverlayState extends State<_OneKeepToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 180),
    )..forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _timer?.cancel();
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 12;
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return Positioned(
      left: 16,
      right: 16,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.55),
              end: Offset.zero,
            ).animate(curve),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curve),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _dismiss,
                onVerticalDragEnd: (details) {
                  if ((details.primaryVelocity ?? 0) < -80) {
                    _dismiss();
                  }
                },
                child: OneKeepToast(message: widget.message, type: widget.type),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OneKeepToast extends StatelessWidget {
  final String message;
  final OneKeepToastType type;

  const OneKeepToast({
    super.key,
    required this.message,
    this.type = OneKeepToastType.info,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (type) {
      OneKeepToastType.success => AppColors.success,
      OneKeepToastType.error => AppColors.error,
      OneKeepToastType.info => AppColors.info,
    };
    final icon = switch (type) {
      OneKeepToastType.success => Icons.check_rounded,
      OneKeepToastType.error => Icons.close_rounded,
      OneKeepToastType.info => Icons.info_outline_rounded,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151B1B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: oneKeepInter(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                  size: 13,
                  weight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

  final seed =
      '${categoryId ?? ''}|${categoryName ?? ''}|${categoryIcon ?? ''}';
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
    final assetPath = resolveCategoryIconAsset(
      categoryIcon.isNotEmpty ? categoryIcon : categoryName,
    );
    const uniformBg = Color(0xFFF0F0F0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: uniformBg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Center(
        child: Image.asset(
          assetPath,
          width: iconSize,
          height: iconSize,
          errorBuilder: (_, __, ___) => Icon(
            Icons.receipt_long_rounded,
            size: iconSize,
            color: const Color(0xFF999999),
          ),
        ),
      ),
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

const oneKeepDefaultAvatarAsset = 'assets/images/default-avatar.png';

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
    final showPresetStyle =
        widget.usePresetStyleWhenNoImage && _avatarProvider == null;
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
            : showPresetStyle
            ? Icon(preset.icon, size: widget.iconSize, color: Colors.white)
            : Image.asset(oneKeepDefaultAvatarAsset, fit: BoxFit.cover),
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

class OneKeepEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subtitle;
  final double iconSize;

  const OneKeepEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subtitle,
    this.iconSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.emerald.withValues(alpha: isDark ? 0.25 : 0.15),
                  AppColors.emerald.withValues(alpha: isDark ? 0.08 : 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: AppColors.emerald.withValues(alpha: isDark ? 0.5 : 0.35),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: oneKeepManrope(
              color: oneKeepTextSecondary(context),
              size: 15,
              weight: FontWeight.w600,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: oneKeepInter(
                color: oneKeepTextTertiary(context),
                size: 12,
                weight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }
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
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
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
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: child),
        child: widget.child,
      ),
    );
  }
}

/// Custom date picker that opens as a bottom sheet.
/// Replaces the system [showDatePicker] with an app-styled design.
Future<DateTime?> showOneKeepDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    builder: (_) => _OneKeepDatePickerSheet(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _OneKeepDatePickerSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _OneKeepDatePickerSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_OneKeepDatePickerSheet> createState() =>
      _OneKeepDatePickerSheetState();
}

class _OneKeepDatePickerSheetState extends State<_OneKeepDatePickerSheet> {
  late DateTime _selectedDate;
  late DateTime _viewMonth;
  final _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _viewMonth = DateTime(widget.initialDate.year, widget.initialDate.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysInMonth = DateTime(_viewMonth.year, _viewMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(_viewMonth.year, _viewMonth.month, 1).weekday % 7;
    final weekLabels = ['一', '二', '三', '四', '五', '六', '日'];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.92)
                : Colors.white.withValues(alpha: 0.95),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Year + Month navigation
                  Row(
                    children: [
                      // Previous month
                      _NavButton(
                        icon: Icons.chevron_left_rounded,
                        enabled:
                            _viewMonth.isAfter(
                              DateTime(
                                widget.firstDate.year,
                                widget.firstDate.month,
                                1,
                              ),
                            ) ||
                            _viewMonth ==
                                DateTime(
                                  widget.firstDate.year,
                                  widget.firstDate.month,
                                  1,
                                ),
                        onTap: () => setState(() {
                          _viewMonth = DateTime(
                            _viewMonth.year,
                            _viewMonth.month - 1,
                            1,
                          );
                        }),
                        isDark: isDark,
                      ),
                      const Spacer(),
                      Column(
                        children: [
                          Text(
                            '${_viewMonth.year}年',
                            style: oneKeepManrope(
                              color: oneKeepTextSecondary(context),
                              size: 12,
                              weight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            DateFormat('M月').format(_viewMonth),
                            style: oneKeepGrotesk(
                              color: oneKeepTextPrimary(context),
                              size: 22,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Next month
                      _NavButton(
                        icon: Icons.chevron_right_rounded,
                        enabled: _viewMonth.isBefore(
                          DateTime(
                            widget.lastDate.year,
                            widget.lastDate.month,
                            1,
                          ),
                        ),
                        onTap: () => setState(() {
                          _viewMonth = DateTime(
                            _viewMonth.year,
                            _viewMonth.month + 1,
                            1,
                          );
                        }),
                        isDark: isDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Weekday headers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekLabels.map((label) {
                      final isWeekend = label == '六' || label == '日';
                      return SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            label,
                            style: oneKeepInter(
                              color: isWeekend
                                  ? AppColors.emerald.withValues(alpha: 0.5)
                                  : oneKeepTextTertiary(context),
                              size: 12,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),

                  // Days grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 7,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: firstWeekday + daysInMonth,
                    itemBuilder: (context, index) {
                      if (index < firstWeekday) {
                        return const SizedBox();
                      }
                      final day = index - firstWeekday + 1;
                      final date = DateTime(
                        _viewMonth.year,
                        _viewMonth.month,
                        day,
                      );
                      final isSelected = date == _selectedDate;
                      final isToday =
                          date == DateTime(_now.year, _now.month, _now.day);
                      final isFuture = date.isAfter(_now);
                      final isBeforeMin = date.isBefore(widget.firstDate);
                      final isAfterMax = date.isAfter(widget.lastDate);
                      final disabled = isFuture || isBeforeMin || isAfterMax;

                      return GestureDetector(
                        onTap: disabled
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                setState(() => _selectedDate = date);
                              },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.emerald
                                : isToday
                                ? AppColors.emerald.withValues(alpha: 0.12)
                                : null,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: oneKeepInter(
                                color: disabled
                                    ? oneKeepTextTertiary(
                                        context,
                                      ).withValues(alpha: 0.3)
                                    : isSelected
                                    ? Colors.white
                                    : isToday
                                    ? AppColors.emerald
                                    : oneKeepTextPrimary(context),
                                size: 14,
                                weight: isSelected || isToday
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm button
                  OneKeepBouncingCard(
                    onTap: () => Navigator.pop(context, _selectedDate),
                    child: Container(
                      width: double.infinity,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.emerald,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emerald.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '确认',
                          style: oneKeepManrope(
                            color: Colors.white,
                            size: 15,
                            weight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool isDark;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return OneKeepBouncingCard(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? oneKeepTextPrimary(context)
              : oneKeepTextTertiary(context).withValues(alpha: 0.3),
        ),
      ),
    );
  }
}
