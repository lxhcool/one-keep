import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/month_navigator.dart';
import '../../../shared/widgets/states/error_state.dart';
import '../../../shared/widgets/states/loading_shimmer.dart';
import '../application/statistics_notifier.dart';
import 'widgets/category_stat_row.dart';
import 'widgets/stat_type_toggle.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  bool _isExpense = true;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(statisticsNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: statsAsync.when(
          loading: () => const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: HomeLoadingShimmer(),
          ),
          error: (e, _) => Center(
            child: ErrorState(
              message: '数据加载失败，请重试',
              onRetry: () => ref.invalidate(statisticsNotifierProvider),
            ),
          ),
          data: (data) {
            final notifier = ref.read(statisticsNotifierProvider.notifier);
            return RefreshIndicator(
              color: AppColors.accentGreen,
              onRefresh: () async =>
                  ref.invalidate(statisticsNotifierProvider),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const Text(
                          '收支统计',
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
                        // Overview cards
                        Row(
                          children: [
                            _OverviewCard(
                              label: '收入',
                              value: data.totalIncome.format(),
                              color: AppColors.accentGreen,
                              bgColor: AppColors.bgIncome,
                            ),
                            const SizedBox(width: AppSpacing.card),
                            _OverviewCard(
                              label: '支出',
                              value: data.totalExpense.format(),
                              color: AppColors.accentRed,
                              bgColor: AppColors.bgExpense,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.section),
                        // Type toggle
                        Center(
                          child: StatTypeToggle(
                            isExpense: _isExpense,
                            onChanged: (v) => setState(() => _isExpense = v),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.section),
                        // Category breakdown
                        Container(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius:
                                BorderRadius.circular(AppRadius.large),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isExpense ? '支出分类' : '收入分类',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Divider(
                                height: 20,
                                color: AppColors.borderSubtle,
                              ),
                              ...(_isExpense
                                      ? data.expenseStats
                                      : data.incomeStats)
                                  .map((s) => CategoryStatRow(stat: s)),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final String value;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
