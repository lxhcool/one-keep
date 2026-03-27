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

class BillsPage extends ConsumerStatefulWidget {
  const BillsPage({super.key});

  @override
  ConsumerState<BillsPage> createState() => _BillsPageState();
}

class _BillsPageState extends ConsumerState<BillsPage> {
  final String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _filterType = 'all';
  bool _searchExpanded = false;

  static const _weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(billsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OneKeepPageBackground(
        variant: OneKeepPageVariant.bills,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    _searchExpanded ? _buildSearchHeader() : _buildHeader(),
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
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
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
                            child: _buildDateGroup(state.groups[index]),
                          );
                        },
                      ),
              ),
            ],
          ),
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
          onTap: () => setState(() => _searchExpanded = true),
          child: OneKeepGlassCard(
            radius: 12,
            blurSigma: 10,
            fillColor: oneKeepGlassStrong(context),
            borderColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.search_rounded,
                size: 20,
                color: oneKeepTextSecondary(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: OneKeepGlassCard(
              radius: 12,
              blurSigma: 10,
              fillColor: oneKeepGlassStrong(context),
              borderColor: oneKeepBorderStrong(context),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: oneKeepTextSecondary(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onSubmitted: (_) => _reload(),
                      style: oneKeepInter(
                        color: oneKeepTextPrimary(context),
                        size: 13,
                        weight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: '搜索账单',
                        hintStyle: oneKeepInter(
                          color: oneKeepTextSecondary(context),
                          size: 13,
                          weight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              setState(() {
                _searchExpanded = false;
                _searchController.clear();
              });
              _reload();
            },
            child: Text(
              '取消',
              style: oneKeepManrope(
                color: AppColors.teal,
                size: 14,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
        const SizedBox(width: 8),
        _FilterChip(
          label: '支出',
          active: _filterType == 'expense',
          onTap: () => _setFilter('expense'),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: '收入',
          active: _filterType == 'income',
          onTap: () => _setFilter('income'),
        ),
      ],
    );
  }

  Widget _buildDateGroup(BillGroup group) {
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
            child: _BillRow(transaction: tx, onTap: () => _showDetailSheet(tx)),
          ),
        ),
      ],
    );
  }

  void _reload() {
    ref
        .read(billsProvider.notifier)
        .load(
          month: _selectedMonth,
          filterType: _filterType,
          query: _searchController.text.trim(),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(billsProvider.notifier)
          .loadMore(
            month: _selectedMonth,
            filterType: _filterType,
            query: _searchController.text.trim(),
          );
    }
  }

  void _setFilter(String filterType) {
    if (_filterType == filterType) return;
    setState(() => _filterType = filterType);
    _reload();
  }

  Future<void> _showDetailSheet(Transaction tx) async {
    final action = await showModalBottomSheet<_TransactionDetailAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.darkDimOverlay,
      builder: (_) => _BillDetailSheet(transaction: tx),
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
      barrierColor: AppColors.darkDimOverlay,
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
          '删除这条记账？',
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? AppColors.teal.withValues(alpha: 0.12)
              : oneKeepGlass(context),
          borderRadius: BorderRadius.circular(20),
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
  final VoidCallback onTap;

  const _BillRow({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final tone = isExpense ? AppColors.expense : AppColors.income;
    final icon = oneKeepCategoryIcon(
      transaction.title,
      transaction.categoryName,
      transaction.categoryIcon,
    );
    final detail = transaction.merchant ?? transaction.note;
    final title = detail != null && detail.isNotEmpty
        ? '${transaction.title} - $detail'
        : transaction.title;

    return GestureDetector(
      onTap: onTap,
      child: OneKeepGlassCard(
        radius: 16,
        blurSigma: 12,
        fillColor: oneKeepGlass(context),
        borderColor: oneKeepBorder(context),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: tone),
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
                    style: oneKeepInter(
                      color: oneKeepTextPrimary(context),
                      size: 14,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${DateFormat('HH:mm').format(transaction.occurredAt)} · ${transaction.categoryName}',
                    style: oneKeepInter(
                      color: oneKeepTextTertiary(context),
                      size: 11,
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isExpense ? '-' : '+'}¥${oneKeepCurrency(transaction.amount)}',
              style: oneKeepGrotesk(
                color: tone,
                size: 16,
                weight: FontWeight.w600,
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

  const _BillDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final tone = isExpense ? AppColors.expense : AppColors.income;
    final icon = oneKeepCategoryIcon(
      transaction.title,
      transaction.categoryName,
      transaction.categoryIcon,
    );
    final detail = transaction.merchant ?? transaction.note;
    final title = detail != null && detail.isNotEmpty
        ? '${transaction.title} - $detail'
        : transaction.title;

    return Container(
      decoration: BoxDecoration(
        color: oneKeepSurface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: oneKeepBorder(context), width: 0.5),
        ),
      ),
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tone.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 20, color: tone),
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
