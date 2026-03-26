import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/api_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/theme/app_colors.dart';
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
      floatingActionButton: _buildFab(isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final active = isDark ? AppColors.teal : AppColors.indigo;
    final inactive = isDark
        ? AppColors.darkTextTertiary
        : AppColors.lightTextTertiary;

    return Container(
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [bg.withValues(alpha: 0), bg.withValues(alpha: 0.84), bg],
          stops: const [0, 0.3, 1],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: SizedBox(
            height: 54,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: _NavSlot(
                      icon: Icons.home_rounded,
                      label: '首页',
                      active: _currentIndex == 0,
                      activeColor: active,
                      inactiveColor: inactive,
                      onTap: () => _onTap(0),
                    ),
                  ),
                  Expanded(
                    child: _NavSlot(
                      icon: Icons.bar_chart_rounded,
                      label: '统计',
                      active: _currentIndex == 1,
                      activeColor: active,
                      inactiveColor: inactive,
                      onTap: () => _onTap(1),
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                  Expanded(
                    child: _NavSlot(
                      icon: Icons.receipt_long_rounded,
                      label: '账单',
                      active: _currentIndex == 2,
                      activeColor: active,
                      inactiveColor: inactive,
                      onTap: () => _onTap(2),
                    ),
                  ),
                  Expanded(
                    child: _NavSlot(
                      icon: Icons.person_rounded,
                      label: '我的',
                      active: _currentIndex == 3,
                      activeColor: active,
                      inactiveColor: inactive,
                      onTap: () => _onTap(3),
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

  Widget _buildFab(bool isDark) {
    final colors = isDark
        ? AppColors.fabGradientDark
        : AppColors.fabGradientLight;
    return GestureDetector(
      onTap: () => _showQuickAddSheet(context),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.32),
              blurRadius: 14,
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
      ),
    );
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.darkDimOverlay,
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
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: oneKeepInter(
              color: color,
              size: 10,
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
        ? AppColors.expensePink
        : AppColors.teal;
    final canSubmit =
        double.tryParse(_amount) != null &&
        double.parse(_amount) > 0 &&
        _selectedCategoryId != null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: const Border(
          top: BorderSide(color: AppColors.darkHairline, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 450,
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
                      color: Colors.white.withValues(alpha: 0.18),
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
                        color: AppColors.darkTextPrimary,
                        size: 18,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.32),
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
                    color: AppColors.darkGlassStrong,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuickAddToggle(
                          label: '支出',
                          active: _direction == 'expense',
                          activeColor: AppColors.expensePink,
                          onTap: () => setState(() => _direction = 'expense'),
                        ),
                      ),
                      Expanded(
                        child: _QuickAddToggle(
                          label: '收入',
                          active: _direction == 'income',
                          activeColor: AppColors.teal,
                          onTap: () => setState(() => _direction = 'income'),
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
                        colors: [Colors.white, activeColor],
                      ),
                      style: oneKeepGrotesk(
                        color: Colors.white,
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
                  data: (items) => _buildCategoryRow(items, activeColor),
                  loading: () => const SizedBox(height: 36),
                  error: (error, stackTrace) => const SizedBox(height: 36),
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

  Widget _buildCategoryRow(List<Category> items, Color activeColor) {
    final filtered = items
        .where((item) => item.type == _direction)
        .take(4)
        .toList();
    if (filtered.isEmpty) return const SizedBox(height: 36);

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filtered[index];
          final selected = item.id == _selectedCategoryId;

          return GestureDetector(
            onTap: () => setState(() => _selectedCategoryId = item.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: selected
                    ? activeColor.withValues(alpha: 0.15)
                    : AppColors.darkGlassStrong,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected
                      ? activeColor.withValues(alpha: 0.32)
                      : Colors.transparent,
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    oneKeepCategoryIcon(item.name, item.name, item.icon),
                    size: 16,
                    color: selected ? activeColor : AppColors.darkTextSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.name,
                    style: oneKeepInter(
                      color: selected
                          ? activeColor
                          : AppColors.darkTextSecondary,
                      size: 12,
                      weight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String get _displayAmount => _amount.isEmpty ? '0.00' : _amount;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('记账失败: $error')));
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
            color: active ? activeColor : AppColors.darkTextTertiary,
            size: 14,
            weight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
