import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:liqing/core/theme/lucide_icons_compat.dart';

import '../../core/config/feature_flags.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/providers/preferences_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/category_icons.dart';
import '../../core/theme/onekeep_iconfont.dart';
import '../../features/chat/chat_page.dart';
import '../models/models.dart';
import 'onekeep_ui.dart';

class MainShell extends ConsumerStatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  bool _isOpeningSheet = false;

  static const _paths = ['/home', '/stats', '/bills', '/profile'];
  static const _navAccent = AppColors.emerald;
  static const _sheetAnimationStyle = AnimationStyle(
    duration: Duration(milliseconds: 380),
    reverseDuration: Duration(milliseconds: 240),
  );

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration.zero, () {
      if (!mounted) return;
      ref.read(categoriesProvider);
    });
  }

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(_paths[index]);
    _refreshTab(index);
  }

  void _refreshTab(int index) {
    switch (index) {
      case 1:
        ref.read(statsProvider.notifier).load();
        break;
      case 2:
        ref.read(billsProvider.notifier).load();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).matchedLocation;

    if (location.startsWith('/home')) {
      _currentIndex = 0;
    } else if (location.startsWith('/stats')) {
      _currentIndex = 1;
    } else if (location.startsWith('/bills')) {
      _currentIndex = 2;
    } else if (location.startsWith('/profile')) {
      _currentIndex = 3;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final active = _navAccent;
    final inactive = isDark
        ? AppColors.darkTextTertiary
        : AppColors.lightTextTertiary;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 64.0;
    const fabLift = 32.0;

    return SizedBox(
      height: barHeight + bottomInset + fabLift,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: barHeight + bottomInset,
              decoration: BoxDecoration(
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkBg.withValues(alpha: 0.8)
                          : AppColors.lightSurface.withValues(alpha: 0.85),
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _NavSlot(
                              icon: oneKeepIconFont('a-202_xiaomao')!,
                              label: '首页',
                              active: _currentIndex == 0,
                              activeColor: active,
                              inactiveColor: inactive,
                              onTap: () => _onTap(0),
                            ),
                            _NavSlot(
                              icon: oneKeepIconFont('a-064_shuidi')!,
                              label: '统计',
                              active: _currentIndex == 1,
                              activeColor: active,
                              inactiveColor: inactive,
                              onTap: () => _onTap(1),
                            ),
                            const SizedBox(width: 76),
                            _NavSlot(
                              icon: oneKeepIconFont('a-064_wenben')!,
                              label: '账单',
                              active: _currentIndex == 2,
                              activeColor: active,
                              inactiveColor: inactive,
                              onTap: () => _onTap(2),
                            ),
                            _NavSlot(
                              icon: oneKeepIconFont('a-064_wode')!,
                              label: '我的',
                              active: _currentIndex == 3,
                              activeColor: active,
                              inactiveColor: inactive,
                              onTap: () => _onTap(3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(top: 0, child: _buildFabItem(isDark)),
        ],
      ),
    );
  }

  void _showManualEntrySheet(BuildContext context) {
    ref.read(categoriesProvider);
    _openSheetOnce(() => _showQuickAddSheet(context));
  }

  void _openSheetOnce(Future<void> Function() openSheet) {
    if (_isOpeningSheet) return;
    _isOpeningSheet = true;
    Future<void>.delayed(Duration.zero, () async {
      if (!mounted) {
        _isOpeningSheet = false;
        return;
      }
      try {
        await openSheet();
      } finally {
        if (mounted) _isOpeningSheet = false;
      }
    });
  }

  Widget _buildFabItem(bool isDark) {
    return Tooltip(
      message: FeatureFlags.aiFeaturesEnabled ? '选择记账方式' : '手动记账',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (FeatureFlags.aiFeaturesEnabled) {
            _openSheetOnce(() => _showAddMethodSheet(context));
          } else {
            _showManualEntrySheet(context);
          }
        },
        onLongPress: FeatureFlags.aiFeaturesEnabled
            ? () {
                HapticFeedback.mediumImpact();
                _showManualEntrySheet(context);
              }
            : null,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.emerald,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withValues(alpha: 0.28),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.emeraldLight, AppColors.emerald],
            ),
          ),
          child: const Icon(LucideIcons.plus, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Future<void> _showAddMethodSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      sheetAnimationStyle: _sheetAnimationStyle,
      builder: (_) => const _AddMethodSheet(),
    );
  }
}

/// 记账方式选择弹窗
class _AddMethodSheet extends ConsumerWidget {
  const _AddMethodSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prefs = ref.watch(preferencesProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.85),
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
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 拖拽条
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

                  // ── 主按钮：AI 聊天记账 ───────────────────────────
                  OneKeepBouncingCard(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const ChatPage()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        gradient: prefs.hasAiConfigured
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF34D399), Color(0xFF059669)],
                              )
                            : null,
                        color: prefs.hasAiConfigured
                            ? null
                            : (isDark
                                  ? const Color(0xFF2C2C2E)
                                  : const Color(0xFFF3F4F6)),
                        borderRadius: BorderRadius.circular(20),
                        border: prefs.hasAiConfigured
                            ? null
                            : Border.all(
                                color: (isDark ? Colors.white : Colors.black)
                                    .withValues(alpha: 0.06),
                                width: 0.5,
                              ),
                        boxShadow: prefs.hasAiConfigured
                            ? [
                                BoxShadow(
                                  color: AppColors.emerald.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(
                                alpha: prefs.hasAiConfigured ? 0.18 : 0.0,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.smart_toy_rounded,
                              size: 28,
                              color: prefs.hasAiConfigured
                                  ? Colors.white
                                  : AppColors.emerald,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI 聊天记账',
                                  style: oneKeepManrope(
                                    color: prefs.hasAiConfigured
                                        ? Colors.white
                                        : oneKeepTextPrimary(context),
                                    size: 18,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  prefs.hasAiConfigured
                                      ? '说出消费，AI 自动识别分类'
                                      : '需先在「我的 → AI 设置」中配置',
                                  style: oneKeepInter(
                                    color: prefs.hasAiConfigured
                                        ? Colors.white.withValues(alpha: 0.75)
                                        : oneKeepTextSecondary(context),
                                    size: 13,
                                    weight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                            color: prefs.hasAiConfigured
                                ? Colors.white.withValues(alpha: 0.5)
                                : oneKeepTextTertiary(context),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── 分割线 ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 0.5,
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.07),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          '或',
                          style: oneKeepInter(
                            color: oneKeepTextTertiary(context),
                            size: 12,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 0.5,
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.07),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── 次级按钮：手动记账 ──────────────────────────
                  OneKeepBouncingCard(
                    onTap: () {
                      Navigator.pop(context);
                      _showQuickAddSheet(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: (isDark ? Colors.white : Colors.black)
                              .withValues(alpha: 0.06),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.pencil,
                            size: 18,
                            color: oneKeepTextSecondary(context),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '手动记账',
                            style: oneKeepManrope(
                              color: oneKeepTextSecondary(context),
                              size: 15,
                              weight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '快速输入金额',
                            style: oneKeepInter(
                              color: oneKeepTextTertiary(context),
                              size: 12,
                              weight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: oneKeepTextTertiary(context),
                          ),
                        ],
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

class _NavSlot extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavSlot({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : inactiveColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: oneKeepInter(
              color: color,
              size: 12,
              weight: active ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet>
    with SingleTickerProviderStateMixin {
  static bool _hasRenderedHeavyContent = false;

  String _direction = 'expense';
  String _amount = '';
  String? _selectedCategoryId;
  String _remark = '';
  DateTime _occurredAt = DateTime.now();
  bool _isSubmitting = false;
  late bool _contentReady;

  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _contentReady = _hasRenderedHeavyContent;
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
    if (!_contentReady) {
      Future<void>.delayed(const Duration(milliseconds: 420), () {
        if (!mounted) return;
        setState(() {
          _contentReady = true;
          _hasRenderedHeavyContent = true;
        });
      });
    }
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _contentReady
        ? ref.watch(categoriesProvider).valueOrNull ?? []
        : const <Category>[];

    final selectedCategory = categories
        .where((c) => c.id == _selectedCategoryId)
        .firstOrNull;
    final categoryColor = selectedCategory != null
        ? oneKeepCategoryTone(
            colorHex: selectedCategory.color,
            categoryId: selectedCategory.id,
            categoryName: selectedCategory.name,
            categoryIcon: selectedCategory.icon,
          )
        : null;

    final accentColor =
        categoryColor ??
        (_direction == 'expense' ? AppColors.expense : AppColors.emerald);
    final currentAmountValue = _evaluateAmount();
    final canSubmit =
        currentAmountValue > 0 && _selectedCategoryId != null && !_isSubmitting;
    final reduceMotion = oneKeepReduceMotion(context);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.75)
                : Colors.white.withValues(alpha: 0.8),
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
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  AnimatedSwitcher(
                    duration: reduceMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0, 0.03),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: _contentReady
                        ? Column(
                            key: const ValueKey('quick-add-content'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  children: [
                                    // Amount Area
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      width: double.infinity,
                                      child: SizedBox(
                                        height: 68,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Positioned.fill(
                                              right: _amount.isNotEmpty
                                                  ? 40
                                                  : 0,
                                              child: Center(
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Transform.translate(
                                                        offset: const Offset(
                                                          0,
                                                          8,
                                                        ),
                                                        child: Text(
                                                          '¥',
                                                          style: oneKeepGrotesk(
                                                            color: accentColor
                                                                .withValues(
                                                                  alpha: 0.5,
                                                                ),
                                                            size: 26,
                                                            weight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      AnimatedSwitcher(
                                                        duration:
                                                            const Duration(
                                                              milliseconds: 150,
                                                            ),
                                                        transitionBuilder:
                                                            (
                                                              Widget child,
                                                              Animation<double>
                                                              animation,
                                                            ) {
                                                              return FadeTransition(
                                                                opacity:
                                                                    animation,
                                                                child: child,
                                                              );
                                                            },
                                                        child: OneKeepGradientText(
                                                          key: ValueKey<String>(
                                                            _amount.isEmpty
                                                                ? '0.00'
                                                                : _amount,
                                                          ),
                                                          text: _amount.isEmpty
                                                              ? '0.00'
                                                              : _amount,
                                                          gradient: LinearGradient(
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter,
                                                            colors: isDark
                                                                ? [
                                                                    Colors
                                                                        .white,
                                                                    accentColor,
                                                                  ]
                                                                : [
                                                                    AppColors
                                                                        .lightTextPrimary,
                                                                    accentColor,
                                                                  ],
                                                          ),
                                                          style: oneKeepGrotesk(
                                                            color:
                                                                oneKeepTextPrimary(
                                                                  context,
                                                                ),
                                                            size: 56,
                                                            weight:
                                                                FontWeight.w700,
                                                            letterSpacing: -1.5,
                                                          ),
                                                        ),
                                                      ),
                                                      AnimatedBuilder(
                                                        animation:
                                                            _cursorController,
                                                        builder: (context, child) {
                                                          return Opacity(
                                                            opacity:
                                                                _cursorController
                                                                    .value,
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets.only(
                                                                    left: 5,
                                                                  ),
                                                              width: 2.5,
                                                              height: 36,
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    accentColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      2,
                                                                    ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (_amount.isNotEmpty)
                                              Positioned(
                                                right: 0,
                                                child: OneKeepBouncingCard(
                                                  onTap: () => setState(
                                                    () => _amount = '',
                                                  ),
                                                  child: Icon(
                                                    Icons.backspace_rounded,
                                                    size: 18,
                                                    color: oneKeepTextTertiary(
                                                      context,
                                                    ).withValues(alpha: 0.4),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Toggle Buttons
                                    _QuickAddDirectionToggle(
                                      direction: _direction,
                                      onChanged: (value) {
                                        if (value == _direction) return;
                                        HapticFeedback.selectionClick();
                                        setState(() {
                                          _direction = value;
                                          _selectedCategoryId = null;
                                        });
                                      },
                                    ),
                                    const SizedBox(height: 16),

                                    // Remark and Date (Separated Boxes)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 44,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF2C2C2E)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color:
                                                    (isDark
                                                            ? Colors.white
                                                            : Colors.black)
                                                        .withValues(
                                                          alpha: 0.05,
                                                        ),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  LucideIcons.pencil,
                                                  size: 14,
                                                  color: accentColor.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: TextField(
                                                    onChanged: (v) =>
                                                        _remark = v,
                                                    style: oneKeepInter(
                                                      color: oneKeepTextPrimary(
                                                        context,
                                                      ),
                                                      size: 14,
                                                    ),
                                                    decoration:
                                                        const InputDecoration(
                                                          hintText: '备注...',
                                                          hintStyle: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.grey,
                                                          ),
                                                          border:
                                                              InputBorder.none,
                                                          enabledBorder:
                                                              InputBorder.none,
                                                          focusedBorder:
                                                              InputBorder.none,
                                                          filled:
                                                              false, // Ensure no grey background
                                                          isDense: true,
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        OneKeepBouncingCard(
                                          onTap: _pickDate,
                                          child: Container(
                                            height: 44,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? const Color(0xFF2C2C2E)
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color:
                                                    (isDark
                                                            ? Colors.white
                                                            : Colors.black)
                                                        .withValues(
                                                          alpha: 0.05,
                                                        ),
                                                width: 0.5,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  LucideIcons.calendar,
                                                  size: 14,
                                                  color: accentColor.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  DateFormat(
                                                    'MM-dd',
                                                  ).format(_occurredAt),
                                                  style: oneKeepInter(
                                                    color: oneKeepTextSecondary(
                                                      context,
                                                    ),
                                                    size: 14,
                                                    weight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),

                              // Category Grid
                              AnimatedSize(
                                duration: reduceMotion
                                    ? Duration.zero
                                    : const Duration(milliseconds: 260),
                                curve: Curves.easeOutCubic,
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  constraints: const BoxConstraints(
                                    maxHeight: 184,
                                  ),
                                  child: ref
                                      .watch(categoriesProvider)
                                      .when(
                                        data: (items) {
                                          _syncSelectedCategory(items);
                                          return _buildCategoryGrid(items);
                                        },
                                        loading: () => const SizedBox(),
                                        error: (error, _) => const SizedBox(),
                                      ),
                                ),
                              ),
                              // Premium Aligned Keyboard
                              _NumericKeyboard(
                                onKeyPress: _onKeyPress,
                                onDelete: _onDelete,
                                onConfirm: canSubmit ? _submit : null,
                                activeColor: accentColor,
                                isSubmitting: _isSubmitting,
                              ),
                            ],
                          )
                        : _QuickAddSheetSkeleton(
                            key: const ValueKey('quick-add-skeleton'),
                            isDark: isDark,
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

  Widget _buildCategoryGrid(List<Category> items) {
    final filtered = items.where((item) => item.type == _direction).toList();
    if (filtered.isEmpty) return const SizedBox();

    const columns = 5;
    final rows = <List<Category>>[
      for (var i = 0; i < filtered.length; i += columns)
        filtered.sublist(i, math.min(i + columns, filtered.length)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var index = 0; index < columns; index++)
                    index < rows[rowIndex].length
                        ? _ManualEntryCategoryItem(
                            item: rows[rowIndex][index],
                            selected:
                                rows[rowIndex][index].id == _selectedCategoryId,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(
                                () => _selectedCategoryId =
                                    rows[rowIndex][index].id,
                              );
                            },
                          )
                        : const SizedBox(width: 46),
                ],
              ),
              if (rowIndex < rows.length - 1) const SizedBox(height: 6),
            ],
          ],
        ),
      ),
    );
  }

  void _syncSelectedCategory(List<Category> items) {
    final filtered = items.where((item) => item.type == _direction).toList();
    if (filtered.isEmpty) {
      _selectedCategoryId = null;
      return;
    }
    if (!filtered.any((item) => item.id == _selectedCategoryId)) {
      _selectedCategoryId = filtered.first.id;
    }
  }

  void _onKeyPress(String key) {
    HapticFeedback.lightImpact();
    setState(() {
      if (key == '.') {
        if (_amount.contains('.') || _isLastCharOperator()) return;
        if (_amount.isEmpty) _amount = '0';
        _amount += '.';
      } else if (key == '+' || key == '-') {
        if (_amount.isEmpty || _isLastCharOperator()) return;
        _amount += key;
      } else {
        _amount += key;
      }
    });
  }

  bool _isLastCharOperator() {
    if (_amount.isEmpty) return false;
    final last = _amount[_amount.length - 1];
    return last == '+' || last == '-';
  }

  double _evaluateAmount() {
    if (_amount.isEmpty) return 0.0;
    try {
      final sanitized = _amount.replaceAll('-', '+-');
      final parts = sanitized.split('+');
      double total = 0;
      for (final p in parts) {
        if (p.isEmpty || p == '-') continue;
        total += double.tryParse(p) ?? 0.0;
      }
      return total < 0 ? 0.0 : total;
    } catch (_) {
      return 0.0;
    }
  }

  void _onDelete() {
    if (_amount.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() {
      _amount = _amount.substring(0, _amount.length - 1);
    });
  }

  Future<void> _pickDate() async {
    final date = await showOneKeepDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) setState(() => _occurredAt = date);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final amountValue = _evaluateAmount();
    if (amountValue <= 0 || _selectedCategoryId == null) return;
    setState(() => _isSubmitting = true);
    final categories = ref.read(categoriesProvider).valueOrNull;
    final category = categories
        ?.where((item) => item.id == _selectedCategoryId)
        .firstOrNull;
    final title = _remark.isNotEmpty ? _remark : (category?.name ?? '未分类');
    try {
      final api = ref.read(apiClientProvider);
      await api.dio.post(
        '/api/transactions',
        data: {
          'title': title,
          'amount': amountValue,
          'direction': _direction,
          'categoryId': _selectedCategoryId,
          'occurredAt': _occurredAt.toUtc().toIso8601String(),
        },
      );
      if (!mounted) return;
      Navigator.pop(context);
      ref.read(homeProvider.notifier).load();
      ref.read(billsProvider.notifier).load();
    } catch (error) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      showOneKeepToast(
        context,
        message: ApiClient.readableError(error, fallback: '记账失败'),
        type: OneKeepToastType.error,
      );
    }
  }
}

Future<void> _showQuickAddSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    sheetAnimationStyle: _MainShellState._sheetAnimationStyle,
    builder: (_) => const _QuickAddSheet(),
  );
}

class _QuickAddSheetSkeleton extends StatelessWidget {
  final bool isDark;

  const _QuickAddSheetSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.04);
    final itemColor = isDark
        ? Colors.white.withValues(alpha: 0.09)
        : Colors.black.withValues(alpha: 0.055);

    Widget block({
      required double height,
      required double width,
      double radius = 14,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: itemColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          block(height: 54, width: 190, radius: 18),
          const SizedBox(height: 20),
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: block(height: 44, width: double.infinity)),
              const SizedBox(width: 12),
              block(height: 44, width: 88),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 20,
            runSpacing: 14,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < 10; i++)
                block(height: 46, width: 46, radius: 16),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.75,
            children: [
              for (var i = 0; i < 12; i++)
                Container(
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAddDirectionToggle extends StatelessWidget {
  final String direction;
  final ValueChanged<String> onChanged;

  const _QuickAddDirectionToggle({
    required this.direction,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = direction == 'expense';
    final activeColor = isExpense ? AppColors.expense : AppColors.emerald;
    final reduceMotion = oneKeepReduceMotion(context);

    return Container(
      height: 38,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final thumbWidth = (constraints.maxWidth - 4) / 2;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                left: isExpense ? 0 : thumbWidth,
                top: 0,
                bottom: 0,
                width: thumbWidth,
                child: AnimatedContainer(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _QuickAddToggleLabel(
                      label: '支出',
                      active: isExpense,
                      onTap: () => onChanged('expense'),
                    ),
                  ),
                  Expanded(
                    child: _QuickAddToggleLabel(
                      label: '收入',
                      active: !isExpense,
                      onTap: () => onChanged('income'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickAddToggleLabel extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _QuickAddToggleLabel({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion = oneKeepReduceMotion(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedDefaultTextStyle(
          duration: reduceMotion
              ? Duration.zero
              : const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          style: oneKeepManrope(
            color: active ? Colors.white : oneKeepTextSecondary(context),
            size: 13,
            weight: active ? FontWeight.w700 : FontWeight.w500,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}

class _ManualEntryCategoryItem extends StatelessWidget {
  final Category item;
  final bool selected;
  final VoidCallback onTap;

  const _ManualEntryCategoryItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = oneKeepCategoryTone(
      colorHex: item.color,
      categoryId: item.id,
      categoryName: item.name,
      categoryIcon: item.icon,
    );
    final iconCacheSize = (24 * MediaQuery.devicePixelRatioOf(context)).round();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: selected
                  ? tone.withValues(alpha: 0.2)
                  : (isDark
                        ? Colors.white10
                        : Colors.black.withValues(alpha: 0.05)),
              borderRadius: BorderRadius.circular(14),
              border: selected
                  ? Border.all(color: tone.withValues(alpha: 0.4), width: 1.5)
                  : null,
            ),
            child: Center(
              child: Image.asset(
                resolveCategoryIconAsset(
                  item.icon.isNotEmpty ? item.icon : item.name,
                ),
                width: 24,
                height: 24,
                cacheWidth: iconCacheSize,
                cacheHeight: iconCacheSize,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.receipt_long_rounded,
                  size: 24,
                  color: selected ? tone : oneKeepTextSecondary(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 46,
            child: Text(
              item.name,
              style: oneKeepInter(
                color: selected ? tone : oneKeepTextSecondary(context),
                size: 10,
                weight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumericKeyboard extends StatelessWidget {
  final Function(String) onKeyPress;
  final VoidCallback onDelete;
  final VoidCallback? onConfirm;
  final Color activeColor;
  final bool isSubmitting;

  const _NumericKeyboard({
    required this.onKeyPress,
    required this.onDelete,
    required this.onConfirm,
    required this.activeColor,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildRow(['1', '2', '3']),
                const SizedBox(height: 10),
                _buildRow(['4', '5', '6']),
                const SizedBox(height: 10),
                _buildRow(['7', '8', '9']),
                const SizedBox(height: 10),
                _buildRow(['+', '0', '-']),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _Key(icon: LucideIcons.delete, onTap: onDelete, height: 49),
                const SizedBox(height: 10),
                _Key(label: '.', onTap: () => onKeyPress('.'), height: 49),
                const SizedBox(height: 10),
                _ConfirmKey(
                  onTap: onConfirm,
                  activeColor: activeColor,
                  height: 108,
                  isLoading: isSubmitting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      children: [
        for (int i = 0; i < keys.length; i++) ...[
          Expanded(
            child: _Key(
              label: keys[i],
              onTap: () => onKeyPress(keys[i]),
              isOperator: keys[i] == '+' || keys[i] == '-',
            ),
          ),
          if (i < keys.length - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _Key extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final double height;
  final bool isOperator;

  const _Key({
    this.label,
    this.icon,
    required this.onTap,
    this.height = 48,
    this.isOperator = false,
  });

  @override
  State<_Key> createState() => _KeyState();
}

class _KeyState extends State<_Key> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTapDown(TapDownDetails _) {
    HapticFeedback.selectionClick();
    _setPressed(true);
  }

  Future<void> _handleTapUp(TapUpDetails _) async {
    widget.onTap();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    if (!mounted) return;
    _setPressed(false);
  }

  void _handleTapCancel() {
    _setPressed(false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: _pressed ? 0.12 : 0.06,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutCubic,
        scale: _pressed ? 0.93 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: widget.label != null
                ? Text(
                    widget.label!,
                    style: oneKeepGrotesk(
                      color: oneKeepTextPrimary(context),
                      size: widget.isOperator ? 24 : 22,
                      weight: widget.isOperator
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                  )
                : Icon(
                    widget.icon,
                    color: (widget.icon == LucideIcons.delete)
                        ? Colors.redAccent.withValues(alpha: 0.7)
                        : oneKeepTextPrimary(context),
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmKey extends StatelessWidget {
  final VoidCallback? onTap;
  final Color activeColor;
  final double height;
  final bool isLoading;

  const _ConfirmKey({
    required this.onTap,
    required this.activeColor,
    required this.height,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !isLoading;
    return OneKeepBouncingCard(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: height,
        decoration: BoxDecoration(
          color: enabled ? activeColor : activeColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.check, color: Colors.white, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      '确认',
                      style: oneKeepManrope(
                        color: Colors.white,
                        size: 14,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
