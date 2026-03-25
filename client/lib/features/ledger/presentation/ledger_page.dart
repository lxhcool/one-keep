import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/date_label.dart';
import '../../../shared/widgets/month_navigator.dart';
import '../../../shared/widgets/states/empty_state.dart';
import '../../../shared/widgets/states/error_state.dart';
import '../../../shared/widgets/states/loading_shimmer.dart';
import '../../transaction/domain/entities/transaction.dart';
import '../../transaction/presentation/widgets/transaction_item.dart';
import '../application/ledger_notifier.dart';
import 'widgets/filter_chip_bar.dart';

class LedgerPage extends ConsumerWidget {
  const LedgerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsync = ref.watch(ledgerNotifierProvider);
    final notifier = ref.read(ledgerNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: ledgerAsync.when(
          loading: () => const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: HomeLoadingShimmer(),
          ),
          error: (e, _) => Center(
            child: ErrorState(
              message: '数据加载失败，请重试',
              onRetry: () => ref.invalidate(ledgerNotifierProvider),
            ),
          ),
          data: (data) => RefreshIndicator(
            color: AppColors.accentGreen,
            onRefresh: () async => ref.invalidate(ledgerNotifierProvider),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const Text(
                        '账单记录',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      MonthNavigator(
                        year: data.year,
                        month: data.month,
                        canGoNext: notifier.canGoNext,
                        onPrevious: () => notifier.previousMonth(),
                        onNext: () => notifier.nextMonth(),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      _SummaryRow(data: data),
                      const SizedBox(height: AppSpacing.section),
                      FilterChipBar(
                        current: data.filter,
                        onChanged: notifier.setFilter,
                      ),
                      const SizedBox(height: 16),
                      if (data.transactions.isEmpty)
                        const EmptyTransactionsState()
                      else
                        ..._buildGroups(data.transactions),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroups(List<Transaction> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <DateTime, List<Transaction>>{};
    for (final t in transactions) {
      final date =
          DateTime(t.occurredAt.year, t.occurredAt.month, t.occurredAt.day);
      groups.putIfAbsent(date, () => []).add(t);
    }

    final sortedDates = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    final widgets = <Widget>[];

    for (final date in sortedDates) {
      final String label;
      if (date == today) {
        label = '今天';
      } else if (date == yesterday) {
        label = '昨天';
      } else {
        label = '${date.month}月${date.day}日';
      }
      widgets.add(DateLabel(text: label));
      widgets.add(const SizedBox(height: 8));
      for (final txn in groups[date]!) {
        widgets.add(TransactionItem(transaction: txn));
        widgets.add(const SizedBox(height: 8));
      }
    }

    return widgets;
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.data});

  final LedgerData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: [
          Expanded(child: _item('共收入', data.totalIncome.format(), AppColors.accentGreen)),
          Container(width: 1, height: 32, color: AppColors.borderSubtle),
          Expanded(child: _item('共支出', data.totalExpense.format(), AppColors.accentRed)),
        ],
      ),
    );
  }

  Widget _item(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
