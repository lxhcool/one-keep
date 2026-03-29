import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/network/api_client.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/onekeep_ui.dart';
import '../../shared/widgets/transaction_editor_sheet.dart';

const _billsPageBackground = Color(0xFFF2F3F5);

class BillsPage extends ConsumerStatefulWidget {
  const BillsPage({super.key});

  @override
  ConsumerState<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends ConsumerState<BillsPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  final ScrollController _scrollController = ScrollController();

  String _filterType = 'all';

  static const _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  String get _monthKey => DateFormat('yyyy-MM').format(_selectedMonth);

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billsProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    final categoryColors = <String, String?>{
      for (final item in categories) item.id: item.color,
    };
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : _billsPageBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildFilterRow(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.isLoading && state.groups.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && state.groups.isEmpty
                  ? Center(child: Text(state.error!))
                  : state.groups.isEmpty
                  ? Center(
                      child: Text(
                        '暂无账单记录',
                        style: oneKeepInter(
                          color: oneKeepTextSecondary(context),
                          size: 12,
                          weight: FontWeight.w400,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
                      itemCount:
                          state.groups.length + (state.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.groups.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == state.groups.length - 1 ? 0 : 16,
                          ),
                          child: _buildDateGroup(state.groups[index], categoryColors),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          '账单',
          style: oneKeepGrotesk(
            color: oneKeepTextPrimary(context),
            size: 28,
            weight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _showMonthPicker,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: oneKeepGlassStrong(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  [_selectedMonth.year, _selectedMonth.month.toString().padLeft(2, '0')].join('/'),
                  style: oneKeepInter(
                    color: oneKeepTextSecondary(context),
                    size: 13,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.expand_more_rounded,
                  size: 14,
                  color: oneKeepTextSecondary(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        _FilterChip(
          label: '全部',
          active: _filterType == 'all',
          onTap: () => _setFilter('all'),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: '支出',
          active: _filterType == 'expense',
          onTap: () => _setFilter('expense'),
        ),
        const SizedBox(width: 12),
        _FilterChip(
          label: '收入',
          active: _filterType == 'income',
          onTap: () => _setFilter('income'),
        ),
      ],
    );
  }

  Widget _buildDateGroup(BillGroup group, Map<String, String?> categoryColors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              _formatDateHeader(group.date),
              style: oneKeepInter(
                color: oneKeepTextSecondary(context),
                size: 13,
                weight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (group.expenseTotal > 0)
              Text(
                '支出 ¥${oneKeepCurrency(group.expenseTotal)}',
                style: oneKeepInter(
                  color: oneKeepTextTertiary(context),
                  size: 12,
                  weight: FontWeight.w400,
                ),
              ),
            if (group.incomeTotal > 0)
              Padding(
                padding: EdgeInsets.only(left: group.expenseTotal > 0 ? 10 : 0),
                child: Text(
                  '收入 ¥${oneKeepCurrency(group.incomeTotal)}',
                  style: oneKeepInter(
                    color: oneKeepTextTertiary(context),
                    size: 12,
                    weight: FontWeight.w400,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ...group.items.map(
          (tx) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _BillRow(
              transaction: tx,
              categoryColor: categoryColors[tx.categoryId] ?? tx.categoryColor,
              onTap: () => _showDetailSheet(
                tx,
                categoryColors[tx.categoryId] ?? tx.categoryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _reload() {
    ref
        .read(billsProvider.notifier)
        .load(
          month: _monthKey,
          filterType: _filterType,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(billsProvider.notifier)
          .loadMore(
            month: _monthKey,
            filterType: _filterType,
          );
    }
  }

  void _setFilter(String filterType) {
    if (_filterType == filterType) return;
    setState(() => _filterType = filterType);
    _reload();
  }

  void _showMonthPicker() {
    var displayYear = _selectedMonth.year;
    final now = DateTime.now();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return OneKeepSheetSurface(
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 374,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: oneKeepTextTertiary(context).withValues(alpha: 0.32),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Text(
                              '选择月份',
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => setModalState(() => displayYear -= 1),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: oneKeepTextSecondary(context),
                                size: 20,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$displayYear',
                              style: oneKeepManrope(
                                color: oneKeepTextPrimary(context),
                                size: 16,
                                weight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: displayYear < now.year
                                  ? () => setModalState(() => displayYear += 1)
                                  : null,
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: displayYear < now.year
                                    ? oneKeepTextSecondary(context)
                                    : oneKeepTextTertiary(context).withValues(alpha: 0.5),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 12,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              mainAxisExtent: 32,
                            ),
                            itemBuilder: (context, index) {
                              final month = index + 1;
                              final disabled = displayYear == now.year && month > now.month;
                              final selected =
                                  displayYear == _selectedMonth.year &&
                                  month == _selectedMonth.month;

                              return GestureDetector(
                                onTap: disabled
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedMonth = DateTime(displayYear, month);
                                        });
                                        Navigator.pop(context);
                                        _reload();
                                      },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.teal.withValues(alpha: 0.18)
                                        : oneKeepGlassStrong(context),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.teal.withValues(alpha: 0.32)
                                          : Colors.transparent,
                                      width: 0.8,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$month月',
                                    style: oneKeepInter(
                                      color: selected
                                          ? AppColors.tealDark
                                          : disabled
                                          ? oneKeepTextTertiary(context).withValues(alpha: 0.5)
                                          : oneKeepTextTertiary(context),
                                      size: 12,
                                      weight: selected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showDetailSheet(Transaction tx, String? categoryColor) async {
    final action = await showModalBottomSheet<_TransactionDetailAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
      builder: (_) => _BillDetailSheet(
        transaction: tx,
        categoryColor: categoryColor,
      ),
    );
    if (!mounted || action == null) return;

    if (action == _TransactionDetailAction.edit) {
      await _editTransaction(tx);
    } else if (action == _TransactionDetailAction.delete) {
      await _deleteTransaction(tx);
    }
  }

  Future<void> _editTransaction(Transaction tx) async {
    final draft = await showModalBottomSheet<TransactionEditDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
      builder: (_) => OneKeepTransactionEditorSheet(transaction: tx),
    );
    if (!mounted || draft == null) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.dio.put(
        '/api/transactions/${tx.transactionId}',
        data: draft.toJson(),
      );
      _reload();
      ref.read(homeProvider.notifier).load();
      ref.read(statsProvider.notifier).load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('账单已更新')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiClient.readableError(error, fallback: '更新失败')),
        ),
      );
    }
  }

  Future<void> _deleteTransaction(Transaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: oneKeepSurface(dialogContext),
        title: Text(
          '删除这条记录？',
          style: oneKeepManrope(
            color: oneKeepTextPrimary(dialogContext),
            size: 18,
            weight: FontWeight.w700,
          ),
        ),
        content: Text(
          '删除后将无法恢复。',
          style: oneKeepInter(
            color: oneKeepTextSecondary(dialogContext),
            size: 13,
            weight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              '取消',
              style: oneKeepInter(
                color: oneKeepTextSecondary(dialogContext),
                size: 14,
                weight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              '删除',
              style: oneKeepInter(
                color: AppColors.expense,
                size: 14,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.dio.delete(
        '/api/transactions/${tx.transactionId}',
        data: const <String, dynamic>{},
      );
      _reload();
      ref.read(homeProvider.notifier).load();
      ref.read(statsProvider.notifier).load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('账单已删除')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiClient.readableError(error, fallback: '删除失败')),
        ),
      );
    }
  }

  String _formatDateHeader(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.month}月${date.day}日 ${_weekdays[date.weekday - 1]}';
  }
}

enum _TransactionDetailAction { edit, delete }

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.teal.withValues(alpha: 0.15)
              : (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkElevated
                  : AppColors.lightBgSecondary),
          borderRadius: BorderRadius.circular(20),
          border: active
              ? Border.all(color: AppColors.teal, width: 1.5)
              : null,
        ),
        child: Text(
          label,
          style: oneKeepInter(
            color: active ? AppColors.teal : oneKeepTextTertiary(context),
            size: 12,
            weight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  final Transaction transaction;
  final String? categoryColor;
  final VoidCallback onTap;

  const _BillRow({
    required this.transaction,
    required this.categoryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = transaction.isExpense;
    final tone = isExpense ? AppColors.expense : AppColors.income;
    final detail = transaction.merchant ?? transaction.note;
    final title = detail != null && detail.isNotEmpty
        ? '${transaction.title} - $detail'
        : transaction.title;
    final normalizedTitle = title.trim();
    final normalizedCategory = transaction.categoryName.trim();
    final subtitleParts = <String>[
      DateFormat('HH:mm').format(transaction.occurredAt),
      if (normalizedCategory.isNotEmpty && normalizedCategory != normalizedTitle)
        normalizedCategory,
    ];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isDark
              ? Border.all(
                  color: AppColors.darkCardBorder,
                  width: 0.8,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            OneKeepCategoryBadge(
              title: transaction.title,
              categoryName: transaction.categoryName,
              categoryIcon: transaction.categoryIcon,
              categoryId: transaction.categoryId,
              colorHex: categoryColor,
              size: 40,
              iconSize: 18,
              radius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: oneKeepManrope(
                      color: oneKeepTextPrimary(context),
                      size: 14,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitleParts.join(' · '),
                    style: oneKeepInter(
                      color: oneKeepTextSecondary(context),
                      size: 12,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isExpense ? '-' : '+'} ¥${oneKeepCurrency(transaction.amount)}',
              style: oneKeepGrotesk(
                color: tone,
                size: 16,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BillDetailSheet extends StatelessWidget {
  final Transaction transaction;
  final String? categoryColor;

  const _BillDetailSheet({
    required this.transaction,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final tone = isExpense ? AppColors.expense : AppColors.income;
    final detail = transaction.merchant ?? transaction.note;
    final title = detail != null && detail.isNotEmpty
        ? '${transaction.title} - $detail'
        : transaction.title;

    return OneKeepSheetSurface(
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 420,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
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
                    OneKeepCategoryBadge(
                      title: transaction.title,
                      categoryName: transaction.categoryName,
                      categoryIcon: transaction.categoryIcon,
                      categoryId: transaction.categoryId,
                      colorHex: categoryColor,
                      size: 40,
                      iconSize: 20,
                      radius: 12,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: oneKeepManrope(
                              color: oneKeepTextPrimary(context),
                              size: 18,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            transaction.categoryName,
                            style: oneKeepInter(
                              color: oneKeepTextTertiary(context),
                              size: 12,
                              weight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${isExpense ? '-' : '+'}¥${oneKeepCurrency(transaction.amount)}',
                      style: oneKeepGrotesk(
                        color: tone,
                        size: 22,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: oneKeepBorder(context), height: 1),
                const SizedBox(height: 16),
                _SheetRow(
                  label: '日期',
                  value:
                      '${transaction.occurredAt.month}/${transaction.occurredAt.day} ${DateFormat('HH:mm').format(transaction.occurredAt)}',
                ),
                const SizedBox(height: 14),
                _SheetRow(label: '分类', value: transaction.categoryName),
                const SizedBox(height: 14),
                _SheetRow(label: '账户', value: isExpense ? '微信支付' : '银行卡'),
                const SizedBox(height: 14),
                _SheetRow(label: '备注', value: transaction.note ?? '暂无备注'),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: '编辑',
                        icon: Icons.edit_outlined,
                        tone: AppColors.teal,
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_TransactionDetailAction.edit),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ActionButton(
                        label: '删除',
                        icon: Icons.delete_outline_rounded,
                        tone: AppColors.expense,
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_TransactionDetailAction.delete),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  final String label;
  final String value;

  const _SheetRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: oneKeepInter(
            color: oneKeepTextSecondary(context),
            size: 13,
            weight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: oneKeepInter(
            color: oneKeepTextPrimary(context),
            size: 13,
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color tone;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tone.withValues(alpha: 0.24), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: tone),
            const SizedBox(width: 8),
            Text(
              label,
              style: oneKeepManrope(
                color: tone,
                size: 14,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
