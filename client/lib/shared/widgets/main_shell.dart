import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/onekeep_iconfont.dart';
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
  static const _navAccent = Color(0xFF308781);

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
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final active = _navAccent;
    final inactive = isDark
        ? AppColors.darkTextTertiary
        : AppColors.lightTextSecondary;
    final bottomInset = MediaQuery.of(context).padding.bottom;
    const barHeight = 62.0;
    const fabLift = 24.0;

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
              color: Colors.transparent,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 38, sigmaY: 38),
                  child: Container(
                    height: barHeight + bottomInset,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [
                                AppColors.darkBg.withValues(alpha: 0.34),
                                AppColors.darkBg.withValues(alpha: 0.22),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.34),
                                Colors.white.withValues(alpha: 0.18),
                              ],
                      ),
                    ),
                      child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 6,
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
          Positioned(
            top: 0,
            child: _buildFabItem(),
          ),
        ],
      ),
    );
  }

  Widget _buildFabItem() {
    return GestureDetector(
      onTap: () => _showQuickAddSheet(context),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: _navAccent,
          borderRadius: BorderRadius.circular(36),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
      ),
    );
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
      builder: (_) => const _QuickAddSheet(),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: oneKeepInter(
              color: color,
              size: 11,
              weight: active ? FontWeight.w600 : FontWeight.w400,
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

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  String _direction = 'expense';
  String _amount = '';
  String? _selectedCategoryId;

  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = ref.watch(categoriesProvider);
    final activeColor = _direction == 'expense'
        ? AppColors.expense
        : AppColors.income;
    final canSubmit =
        double.tryParse(_amount) != null &&
        double.parse(_amount) > 0 &&
        _selectedCategoryId != null;

    return OneKeepSheetSurface(
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 520,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: oneKeepTextTertiary(
                        context,
                      ).withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      '快速记账',
                      style: oneKeepManrope(
                        color: oneKeepTextPrimary(context),
                        size: 18,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        color: oneKeepTextSecondary(context),
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  height: 42,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: oneKeepGlassStrong(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickAddToggle(
                          label: '支出',
                          active: _direction == 'expense',
                          activeColor: AppColors.expense,
                          onTap: () => setState(() {
                            _direction = 'expense';
                            _selectedCategoryId = null;
                          }),
                        ),
                      ),
                      Expanded(
                        child: _QuickAddToggle(
                          label: '收入',
                          active: _direction == 'income',
                          activeColor: AppColors.teal,
                          onTap: () => setState(() {
                            _direction = 'income';
                            _selectedCategoryId = null;
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => _amountFocusNode.requestFocus(),
                  child: SizedBox(
                    width: double.infinity,
                    child: OneKeepGradientText(
                      text: '¥ $_displayAmount',
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [Colors.white, activeColor]
                            : [AppColors.lightTextPrimary, activeColor],
                      ),
                      style: oneKeepGrotesk(
                        color: oneKeepTextPrimary(context),
                        size: 40,
                        weight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Opacity(
                  opacity: 0,
                  child: SizedBox(
                    height: 1,
                    child: TextField(
                      controller: _amountController,
                      focusNode: _amountFocusNode,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      onChanged: _onAmountChanged,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                categories.when(
                  data: (items) {
                    _syncSelectedCategory(items);
                    return _buildCategoryGrid(items, activeColor);
                  },
                  loading: () => const SizedBox(height: 72),
                  error: (error, stackTrace) => const SizedBox(height: 72),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: canSubmit ? _submit : null,
                  child: Opacity(
                    opacity: canSubmit ? 1 : 0.5,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '确认记账',
                          style: oneKeepManrope(
                            color: AppColors.darkBg,
                            size: 16,
                            weight: FontWeight.w700,
                          ),
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
    );
  }

  Widget _buildCategoryGrid(List<Category> items, Color activeColor) {
    final filtered = items.where((item) => item.type == _direction).toList();
    if (filtered.isEmpty) return const SizedBox(height: 72);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 144),
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: filtered.map((item) {
            final selected = item.id == _selectedCategoryId;
            return GestureDetector(
              onTap: () => setState(() => _selectedCategoryId = item.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? activeColor.withValues(alpha: 0.15)
                      : oneKeepGlassStrong(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected
                        ? activeColor.withValues(alpha: 0.32)
                        : oneKeepBorder(context),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      oneKeepResolvedCategoryIcon(
                        item.name,
                        item.name,
                        item.icon,
                      ),
                      size: 16,
                      color: selected
                          ? activeColor
                          : oneKeepTextSecondary(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.name,
                      style: oneKeepInter(
                        color: selected
                            ? activeColor
                            : oneKeepTextSecondary(context),
                        size: 12,
                        weight: selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String get _displayAmount => _amount.isEmpty ? '0.00' : _amount;

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

  void _onAmountChanged(String value) {
    final sanitized = _sanitizeAmount(value);
    if (sanitized != value) {
      _amountController.value = TextEditingValue(
        text: sanitized,
        selection: TextSelection.collapsed(offset: sanitized.length),
      );
    }
    setState(() => _amount = sanitized);
  }

  String _sanitizeAmount(String input) {
    final buffer = StringBuffer();
    var seenDot = false;
    var decimals = 0;

    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      if (char == '.') {
        if (seenDot) continue;
        seenDot = true;
        if (buffer.isEmpty) {
          buffer.write('0');
        }
        buffer.write('.');
        continue;
      }
      if (char.codeUnitAt(0) < 48 || char.codeUnitAt(0) > 57) {
        continue;
      }
      if (seenDot) {
        if (decimals >= 2) continue;
        decimals += 1;
      }
      buffer.write(char);
    }

    return buffer.toString();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amount);
    if (amount == null || amount <= 0 || _selectedCategoryId == null) {
      return;
    }

    final categories = ref.read(categoriesProvider).valueOrNull;
    final category = categories
        ?.where((item) => item.id == _selectedCategoryId)
        .firstOrNull;
    final title = category?.name ?? '未分类';

    try {
      final api = ref.read(apiClientProvider);
      await api.dio.post(
        '/api/transactions',
        data: {
          'title': title,
          'amount': amount,
          'direction': _direction,
          'categoryId': _selectedCategoryId,
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
        },
      );
      if (!mounted) return;
      Navigator.pop(context);
      ref.read(homeProvider.notifier).load();
      ref.read(billsProvider.notifier).load();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiClient.readableError(error, fallback: '记账失败')),
        ),
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
      child: Container(
        decoration: BoxDecoration(
          color: active
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? activeColor.withValues(alpha: 0.28)
                : Colors.transparent,
            width: 0.8,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: oneKeepManrope(
            color: active ? activeColor : oneKeepTextTertiary(context),
            size: 14,
            weight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
