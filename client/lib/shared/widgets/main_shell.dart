import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/data_providers.dart';
import '../../core/providers/api_provider.dart';


class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  static const _paths = ['/home', '/stats', '/bills'];

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    context.go(_paths[index]);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/home')) {
      _currentIndex = 0;
    } else if (loc.startsWith('/stats')) {
      _currentIndex = 1;
    } else if (loc.startsWith('/bills')) {
      _currentIndex = 2;
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: widget.child,
      bottomNavigationBar: _buildBottomBar(isDark),
      floatingActionButton: _buildFab(isDark),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomBar(bool isDark) {
    final accent = isDark ? AppColors.teal : AppColors.indigo;
    final inactive =
        isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.darkCardBorder
                : const Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: LucideIcons.home,
              label: '首页',
              active: _currentIndex == 0,
              activeColor: accent,
              inactiveColor: inactive,
              onTap: () => _onTap(0),
            ),
            _NavItem(
              icon: LucideIcons.barChart2,
              label: '统计',
              active: _currentIndex == 1,
              activeColor: accent,
              inactiveColor: inactive,
              onTap: () => _onTap(1),
            ),
            const SizedBox(width: 56), // space for FAB
            _NavItem(
              icon: LucideIcons.receipt,
              label: '账单',
              active: _currentIndex == 2,
              activeColor: accent,
              inactiveColor: inactive,
              onTap: () => _onTap(2),
            ),
            _NavItem(
              icon: LucideIcons.user,
              label: '我的',
              active: false,
              activeColor: accent,
              inactiveColor: inactive,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(bool isDark) {
    final gradient =
        isDark ? AppColors.fabGradientDark : AppColors.fabGradientLight;
    return GestureDetector(
      onTap: () => _showQuickAddSheet(context),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(LucideIcons.plus, color: Colors.white, size: 24),
      ),
    );
  }

  void _showQuickAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _QuickAddSheet(),
    );
  }
}

// ── Nav item ──
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavItem({
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
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Add Bottom Sheet ──
class _QuickAddSheet extends ConsumerStatefulWidget {
  const _QuickAddSheet();

  @override
  ConsumerState<_QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<_QuickAddSheet> {
  String _direction = 'expense';
  String _amount = '';
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? AppColors.teal : AppColors.indigo;
    final categories = ref.watch(categoriesProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title row: 快速记账 + X
              Row(
                children: [
                  Text(
                    '快速记账',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkInputBg
                            : AppColors.lightInputBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.x,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 支出/收入 toggle
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkInputBg
                      : AppColors.lightInputBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _toggleBtn('支出', _direction == 'expense',
                          isDark, () => setState(() => _direction = 'expense')),
                    ),
                    Expanded(
                      child: _toggleBtn('收入', _direction == 'income', isDark,
                          () => setState(() => _direction = 'income')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount display
              Text(
                '¥ ${_amount.isEmpty ? '0.00' : _amount}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // Category chips
              categories.when(
                data: (cats) {
                  final filtered = cats
                      .where((c) => c.type == _direction)
                      .toList();
                  if (filtered.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filtered.length,
                      separatorBuilder: (context2, index2) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final cat = filtered[index];
                        final selected = _selectedCategoryId == cat.id;
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedCategoryId = cat.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? accent.withValues(alpha: 0.12)
                                  : (isDark
                                      ? AppColors.darkInputBg
                                      : AppColors.lightInputBg),
                              borderRadius: BorderRadius.circular(20),
                              border: selected
                                  ? Border.all(color: accent, width: 1)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat.icon,
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: selected
                                        ? accent
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, s) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Numpad (simple row of digits)
              _buildNumpad(isDark),
              const SizedBox(height: 16),

              // 确认记账 button
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  debugPrint('[QuickAdd] amount=$_amount, category=$_selectedCategoryId, direction=$_direction');
                  _submit();
                },
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? AppColors.fabGradientDark
                          : AppColors.fabGradientLight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                  child: const Center(
                    child: Text(
                      '确认记账',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleBtn(
      String label, bool active, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? (isDark ? AppColors.darkSurface : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active
                  ? (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary)
                  : (isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad(bool isDark) {
    const keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '.', '0', '⌫',
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 2.2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: keys.map((k) {
        return GestureDetector(
          onTap: () => _onKeyTap(k),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: k == '⌫'
                  ? Icon(LucideIcons.delete,
                      size: 20,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)
                  : Text(
                      k,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onKeyTap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_amount.isNotEmpty) {
          _amount = _amount.substring(0, _amount.length - 1);
        }
      } else if (key == '.') {
        if (!_amount.contains('.')) {
          _amount = _amount.isEmpty ? '0.' : '$_amount.';
        }
      } else {
        // Limit decimal places to 2
        if (_amount.contains('.')) {
          final parts = _amount.split('.');
          if (parts[1].length >= 2) return;
        }
        _amount = '$_amount$key';
      }
    });
  }

  void _submit() async {
    final amt = double.tryParse(_amount);
    if (amt == null || amt <= 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请输入金额')),
        );
      }
      return;
    }
    if (_selectedCategoryId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择分类')),
        );
      }
      return;
    }

    final categories = ref.read(categoriesProvider).valueOrNull;
    final cat = categories?.where((c) => c.id == _selectedCategoryId).firstOrNull;
    final title = cat?.name ?? '未分类';

    try {
      final api = ref.read(apiClientProvider);
      await api.dio.post('/api/transactions', data: {
        'title': title,
        'amount': amt,
        'direction': _direction,
        'categoryId': _selectedCategoryId,
        'occurredAt': DateTime.now().toUtc().toIso8601String(),
      });
      if (mounted) {
        Navigator.pop(context);
        ref.read(homeProvider.notifier).load();
        ref.read(billsProvider.notifier).load();
      }
    } catch (e) {
      debugPrint('[QuickAdd] error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('记账失败: $e')),
        );
      }
    }
  }
}
