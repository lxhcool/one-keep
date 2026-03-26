import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/data_providers.dart';
import '../../shared/models/models.dart';

class BillsPage extends ConsumerStatefulWidget {
  const BillsPage({super.key});

  @override
  ConsumerState<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends ConsumerState<BillsPage> {
  final String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  String _filterType = 'all';
  bool _searchExpanded = false;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _reload());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _reload() {
    ref.read(billsProvider.notifier).load(
          month: _selectedMonth,
          filterType: _filterType,
          query: _searchController.text,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(billsProvider.notifier).loadMore(
            month: _selectedMonth,
            filterType: _filterType,
            query: _searchController.text,
          );
    }
  }

  void _setFilter(String type) {
    setState(() => _filterType = type);
    ref.read(billsProvider.notifier).load(
          month: _selectedMonth,
          filterType: type,
          query: _searchController.text,
        );
  }

  static const _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  String _formatDateHeader(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    final wd = _weekdays[d.weekday - 1];
    return '${d.month}月${d.day}日 $wd';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(isDark),
                  if (_searchExpanded) ...[
                    const SizedBox(height: 12),
                    _buildSearchBar(isDark),
                  ],
                  const SizedBox(height: 16),
                  _buildFilterChips(isDark),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            Expanded(
              child: state.isLoading && state.groups.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && state.groups.isEmpty
                      ? Center(child: Text(state.error!))
                      : state.groups.isEmpty
                          ? Center(
                              child: Text(
                                '暂无账单记录',
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                                ),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: state.groups.length,
                              itemBuilder: (context, index) => _buildDateGroup(
                                  state.groups[index], isDark),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header: "账单" + search icon ──
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Text(
          '账单',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() {
              _searchExpanded = !_searchExpanded;
              if (!_searchExpanded) {
                _searchController.clear();
                _reload();
              }
            });
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _searchExpanded ? LucideIcons.x : LucideIcons.search,
              size: 20,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  // ── Search bar ──
  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _reload(),
        style: TextStyle(
          fontSize: 14,
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
        decoration: InputDecoration(
          hintText: '搜索账单...',
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.darkTextTertiary
                : AppColors.lightTextTertiary,
            fontSize: 14,
          ),
          prefixIcon: Icon(LucideIcons.search,
              size: 18,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.lightTextTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 11),
        ),
      ),
    );
  }

  // ── Filter chips: 全部 / 支出 / 收入 ──
  Widget _buildFilterChips(bool isDark) {
    return Row(
      children: [
        _FilterChip(
            label: '全部',
            active: _filterType == 'all',
            isDark: isDark,
            onTap: () => _setFilter('all')),
        const SizedBox(width: 8),
        _FilterChip(
            label: '支出',
            active: _filterType == 'expense',
            isDark: isDark,
            onTap: () => _setFilter('expense')),
        const SizedBox(width: 8),
        _FilterChip(
            label: '收入',
            active: _filterType == 'income',
            isDark: isDark,
            onTap: () => _setFilter('income')),
      ],
    );
  }

  // ── Date group card ──
  Widget _buildDateGroup(BillGroup group, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkCardBorder
              : const Color(0xFFE5E7EB),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          // Date header row
          Row(
            children: [
              Text(
                _formatDateHeader(group.date),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              if (group.expenseTotal > 0)
                Text(
                  '支出 ¥${group.expenseTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.expensePink,
                  ),
                ),
              if (group.expenseTotal > 0 && group.incomeTotal > 0)
                const SizedBox(width: 10),
              if (group.incomeTotal > 0)
                Text(
                  '收入 ¥${group.incomeTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.incomeTeal,
                  ),
                ),
            ],
          ),
          if (group.items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: isDark
                  ? AppColors.darkCardBorder
                  : const Color(0xFFE5E7EB),
            ),
            const SizedBox(height: 4),
            ...group.items.map((tx) => _buildTransactionRow(tx, isDark)),
          ],
        ],
      ),
    );
  }

  // ── Transaction row matching design ──
  Widget _buildTransactionRow(Transaction tx, bool isDark) {
    final isExp = tx.isExpense;
    final amountColor = isExp ? AppColors.expensePink : AppColors.incomeTeal;
    final sign = isExp ? '-' : '+';
    final timeStr = DateFormat('HH:mm').format(tx.occurredAt);

    // Title format: "Title - Subtitle" where subtitle is merchant/note
    final subtitle = tx.merchant ?? tx.note;
    final displayTitle =
        subtitle != null ? '${tx.title} - $subtitle' : tx.title;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Category icon in colored circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: amountColor.withValues(alpha: isDark ? 0.12 : 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(tx.categoryIcon, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$timeStr · ${tx.categoryName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign¥${tx.amount.toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter chip pill ──
class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColors.teal : AppColors.indigo;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? accent.withValues(alpha: 0.12)
              : (isDark ? AppColors.darkInputBg : AppColors.lightInputBg),
          borderRadius: BorderRadius.circular(20),
          border: active ? Border.all(color: accent, width: 1) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w600 : FontWeight.w400,
            color: active
                ? accent
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }
}
