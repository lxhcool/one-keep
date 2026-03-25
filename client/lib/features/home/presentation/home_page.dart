import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../application/home_notifier.dart';
import '../application/home_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/date_label.dart';
import '../../../shared/widgets/states/loading_shimmer.dart';
import '../../../shared/widgets/states/empty_state.dart';
import '../../../shared/widgets/states/error_state.dart';
import '../../transaction/domain/entities/transaction.dart';
import '../../transaction/presentation/widgets/transaction_item.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_card.dart';
import 'widgets/user_greeting.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: homeAsync.when(
          loading: () => const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: HomeLoadingShimmer(),
          ),
          error: (e, _) => Center(
            child: ErrorState(
              message: '数据加载失败，请重试',
              onRetry: () => ref.invalidate(homeNotifierProvider),
            ),
          ),
          data: (data) => _SuccessBody(data: data),
        ),
      ),
    );
  }
}

class _SuccessBody extends ConsumerWidget {
  const _SuccessBody({required this.data});

  final HomeData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.accentGreen,
      onRefresh: () => ref.read(homeNotifierProvider.notifier).refresh(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                UserGreeting(
                  userProfile: data.userProfile,
                  onSearchTap: () => _showToast(context, '搜索功能即将上线'),
                  onNotificationTap: () =>
                      _showToast(context, '通知功能即将上线'),
                ),
                const SizedBox(height: AppSpacing.section),

                BalanceCard(balance: data.balance),
                const SizedBox(height: AppSpacing.section),

                Row(
                  children: [
                    SummaryCard(
                      icon: Icons.arrow_downward_rounded,
                      iconColor: AppColors.accentGreen,
                      iconBgColor: AppColors.bgIncome,
                      label: '收入',
                      amount: data.summary.totalIncome,
                    ),
                    const SizedBox(width: AppSpacing.card),
                    SummaryCard(
                      icon: Icons.arrow_upward_rounded,
                      iconColor: AppColors.accentRed,
                      iconBgColor: AppColors.bgExpense,
                      label: '支出',
                      amount: data.summary.totalExpense,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.section),

                SectionHeader(
                  title: '近期账单',
                  actionText: '查看全部',
                  onAction: () => _showToast(context, '账单页面即将上线'),
                ),
                const SizedBox(height: 16),

                if (data.recentTransactions.isEmpty)
                  const EmptyTransactionsState()
                else
                  ..._buildTransactionGroups(data.recentTransactions),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTransactionGroups(List<Transaction> transactions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <DateTime, List<Transaction>>{};
    for (final t in transactions) {
      final date =
          DateTime(t.occurredAt.year, t.occurredAt.month, t.occurredAt.day);
      groups.putIfAbsent(date, () => []).add(t);
    }

    final sortedDates = groups.keys.toList()
      ..sort((a, b) => b.compareTo(a));

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

      for (final transaction in groups[date]!) {
        widgets.add(TransactionItem(transaction: transaction));
        widgets.add(const SizedBox(height: 8));
      }
    }

    return widgets;
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
    );
  }
}
