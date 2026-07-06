import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

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

  static const _paths = ['/home', '/stats', '/bills', '/profile'];
  static const _navAccent = AppColors.emerald;

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(_paths[index]);
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => const _QuickAddSheet(),
    );
  }

  Widget _buildFabItem(bool isDark) {
    return Tooltip(
      message: FeatureFlags.aiFeaturesEnabled ? '选择记账方式' : '手动记账',
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (FeatureFlags.aiFeaturesEnabled) {
            _showAddMethodSheet(context);
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

  void _showAddMethodSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
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
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        barrierColor: Colors.black.withValues(alpha: 0.3),
                        builder: (_) => const _QuickAddSheet(),
                      );
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
  String _direction = 'expense';
  String _amount = '';
  String? _selectedCategoryId;
  String _remark = '';
  DateTime _occurredAt = DateTime.now();
  bool _isSubmitting = false;

  late AnimationController _cursorController;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];

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

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        // Amount Area
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '¥',
                                      style: oneKeepGrotesk(
                                        color: accentColor.withValues(
                                          alpha: 0.5,
                                        ),
                                        size: 26,
                                        weight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 150),
                                    transitionBuilder:
                                        (
                                          Widget child,
                                          Animation<double> animation,
                                        ) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                    child: OneKeepGradientText(
                                      key: ValueKey<String>(
                                        _amount.isEmpty ? '0.00' : _amount,
                                      ),
                                      text: _amount.isEmpty ? '0.00' : _amount,
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: isDark
                                            ? [Colors.white, accentColor]
                                            : [
                                                AppColors.lightTextPrimary,
                                                accentColor,
                                              ],
                                      ),
                                      style: oneKeepGrotesk(
                                        color: oneKeepTextPrimary(context),
                                        size: 56,
                                        weight: FontWeight.w700,
                                        letterSpacing: -1.5,
                                      ),
                                    ),
                                  ),
                                  AnimatedBuilder(
                                    animation: _cursorController,
                                    builder: (context, child) {
                                      return Opacity(
                                        opacity: _cursorController.value,
                                        child: SizedBox(
                                          height: 56,
                                          child: Center(
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                left: 4,
                                              ),
                                              width: 2.5,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: accentColor,
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              if (_amount.isNotEmpty)
                                Positioned(
                                  right: 0,
                                  child: OneKeepBouncingCard(
                                    onTap: () => setState(() => _amount = ''),
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

                        // Toggle Buttons
                        Container(
                          height: 38,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _QuickAddToggle(
                                  label: '支出',
                                  active: _direction == 'expense',
                                  activeColor: AppColors.expense,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _direction = 'expense';
                                      _selectedCategoryId = null;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: _QuickAddToggle(
                                  label: '收入',
                                  active: _direction == 'income',
                                  activeColor: AppColors.emerald,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    setState(() {
                                      _direction = 'income';
                                      _selectedCategoryId = null;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
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
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.05),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      LucideIcons.pencil,
                                      size: 14,
                                      color: accentColor.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        onChanged: (v) => _remark = v,
                                        style: oneKeepInter(
                                          color: oneKeepTextPrimary(context),
                                          size: 14,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: '备注...',
                                          hintStyle: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          filled:
                                              false, // Ensure no grey background
                                          isDense: true,
                                          contentPadding: EdgeInsets.zero,
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
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        (isDark ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.05),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      LucideIcons.calendar,
                                      size: 14,
                                      color: accentColor.withValues(alpha: 0.5),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('MM-dd').format(_occurredAt),
                                      style: oneKeepInter(
                                        color: oneKeepTextSecondary(context),
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
                  Container(
                    constraints: const BoxConstraints(maxHeight: 240),
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
                  const SizedBox(height: 8),

                  // Premium Aligned Keyboard
                  _NumericKeyboard(
                    onKeyPress: _onKeyPress,
                    onDelete: _onDelete,
                    onConfirm: canSubmit ? _submit : null,
                    activeColor: accentColor,
                    isSubmitting: _isSubmitting,
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    const crossAxisCount = 4;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        childAspectRatio: 1.1,
      ),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final selected = item.id == _selectedCategoryId;
        final tone = oneKeepCategoryTone(
          colorHex: item.color,
          categoryId: item.id,
          categoryName: item.name,
          categoryIcon: item.icon,
        );

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedCategoryId = item.id);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
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
                      ? Border.all(
                          color: tone.withValues(alpha: 0.4),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Image.asset(
                  resolveCategoryIconAsset(
                    item.icon.isNotEmpty ? item.icon : item.name,
                  ),
                  width: 22,
                  height: 22,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.receipt_long_rounded,
                    size: 22,
                    color: selected ? tone : oneKeepTextSecondary(context),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
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
            ],
          ),
        );
      },
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

class _QuickAddToggle extends StatelessWidget {
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _QuickAddToggle({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: active ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: oneKeepManrope(
            color: active ? Colors.white : oneKeepTextSecondary(context),
            size: 13,
            weight: active ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
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

class _Key extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return OneKeepBouncingCard(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: label != null
              ? Text(
                  label!,
                  style: oneKeepGrotesk(
                    color: oneKeepTextPrimary(context),
                    size: isOperator ? 24 : 22,
                    weight: isOperator ? FontWeight.w400 : FontWeight.w600,
                  ),
                )
              : Icon(
                  icon,
                  color: (icon == LucideIcons.delete)
                      ? Colors.redAccent.withValues(alpha: 0.7)
                      : oneKeepTextPrimary(context),
                  size: 20,
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
