import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/data_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/onekeep_ui.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _metricType = 'expense';

  String get _monthKey => DateFormat('yyyy-MM').format(_selectedMonth);

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  void _reload() {
    ref
        .read(statsProvider.notifier)
        .load(month: _monthKey, metricType: _metricType);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OneKeepPageBackground(
        variant: OneKeepPageVariant.stats,
        child: SafeArea(
          bottom: false,
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
              ? Center(child: Text(state.error!))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    if (state.overview != null) ...[
                      _buildSummaryRow(state.overview!),
                      const SizedBox(height: 20),
                      _buildTrendCard(state.overview!),
                      const SizedBox(height: 20),
                      _buildCategoryCard(state.overview!),
                    ],
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
          '统计',
          style: oneKeepGrotesk(
            color: oneKeepTextPrimary(context),
            size: 24,
            weight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _showMonthPicker,
          child: OneKeepGlassCard(
            radius: 12,
            blurSigma: 12,
            fillColor: oneKeepGlass(context),
            borderColor: oneKeepBorder(context),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('yyyy年M月').format(_selectedMonth),
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

  Widget _buildSummaryRow(StatsOverview overview) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: '总支出',
            amount: overview.totalExpense,
            color: AppColors.expensePink,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _SummaryCard(
            label: '总收入',
            amount: overview.totalIncome,
            color: oneKeepIncomeTone(context),
          ),
        ),
      ],
    );
  }

  Widget _buildTrendCard(StatsOverview overview) {
    final isExpense = _metricType == 'expense';
    final series = overview.trendSeries.take(7).toList();

    return OneKeepGlassCard(
      radius: 18,
      blurSigma: 16,
      fillColor: oneKeepGlass(context),
      borderColor: oneKeepBorder(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                isExpense ? '支出趋势' : '收入趋势',
                style: oneKeepManrope(
                  color: oneKeepTextPrimary(context),
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _MetricToggle(
                isExpense: isExpense,
                onChanged: (value) {
                  setState(() => _metricType = value ? 'expense' : 'income');
                  _reload();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TrendBars(
            points: series,
            colors: isExpense
                ? const [AppColors.teal, AppColors.purple]
                : [oneKeepIncomeTone(context), AppColors.teal],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(StatsOverview overview) {
    final ranks = overview.categoryRanks.take(3).toList();
    final tones = _metricType == 'expense'
        ? const [AppColors.expensePink, AppColors.purple, AppColors.teal]
        : [oneKeepIncomeTone(context), AppColors.teal, AppColors.purple];

    return OneKeepGlassCard(
      radius: 18,
      blurSigma: 16,
      fillColor: oneKeepGlass(context),
      borderColor: oneKeepBorder(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '分类排行',
                style: oneKeepManrope(
                  color: oneKeepTextPrimary(context),
                  size: 16,
                  weight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '查看全部',
                style: oneKeepInter(
                  color: oneKeepTextTertiary(context),
                  size: 12,
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (ranks.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '暂无数据',
                  style: oneKeepInter(
                    color: oneKeepTextSecondary(context),
                    size: 12,
                    weight: FontWeight.w400,
                  ),
                ),
              ),
            )
          else
            ...ranks.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == ranks.length - 1 ? 0 : 16,
                ),
                child: _RankRow(
                  rank: entry.value,
                  tone: tones[entry.key % tones.length],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showMonthPicker() {
    var displayYear = _selectedMonth.year;
    final now = DateTime.now();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.darkDimOverlay,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: oneKeepSurface(context),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(color: oneKeepBorder(context), width: 0.5),
                ),
              ),
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
                              onTap: () =>
                                  setModalState(() => displayYear -= 1),
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
                                    : oneKeepTextTertiary(
                                        context,
                                      ).withValues(alpha: 0.5),
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
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  mainAxisExtent: 32,
                                ),
                            itemBuilder: (context, index) {
                              final month = index + 1;
                              final disabled =
                                  displayYear == now.year && month > now.month;
                              final selected =
                                  displayYear == _selectedMonth.year &&
                                  month == _selectedMonth.month;

                              return GestureDetector(
                                onTap: disabled
                                    ? null
                                    : () {
                                        setState(() {
                                          _selectedMonth = DateTime(
                                            displayYear,
                                            month,
                                          );
                                        });
                                        Navigator.pop(context);
                                        _reload();
                                      },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.teal.withValues(alpha: 0.2)
                                        : oneKeepGlassStrong(context),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.teal.withValues(
                                              alpha: 0.28,
                                            )
                                          : Colors.transparent,
                                      width: 0.8,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '$month月',
                                    style: oneKeepInter(
                                      color: selected
                                          ? AppColors.teal
                                          : disabled
                                          ? oneKeepTextTertiary(
                                              context,
                                            ).withValues(alpha: 0.5)
                                          : oneKeepTextTertiary(context),
                                      size: 12,
                                      weight: selected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
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
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OneKeepGlassCard(
      radius: 18,
      blurSigma: 12,
      fillColor: oneKeepGlass(context),
      borderColor: oneKeepBorder(context),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: oneKeepInter(
              color: oneKeepTextSecondary(context),
              size: 12,
              weight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '¥ ${oneKeepCurrency(amount)}',
            style: oneKeepGrotesk(
              color: color,
              size: 20,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricToggle extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;

  const _MetricToggle({required this.isExpense, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: oneKeepGlassStrong(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleChip(
            context: context,
            label: '支出',
            active: isExpense,
            tone: AppColors.teal,
            onTap: () => onChanged(true),
          ),
          _toggleChip(
            context: context,
            label: '收入',
            active: !isExpense,
            tone: AppColors.teal,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _toggleChip({
    required BuildContext context,
    required String label,
    required bool active,
    required Color tone,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? tone.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: oneKeepInter(
            color: active ? tone : oneKeepTextTertiary(context),
            size: 12,
            weight: active ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _TrendBars extends StatelessWidget {
  final List<TrendPoint> points;
  final List<Color> colors;

  const _TrendBars({required this.points, required this.colors});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return SizedBox(
        height: 160,
        child: Center(
          child: Text(
            '暂无数据',
            style: oneKeepInter(
              color: oneKeepTextSecondary(context),
              size: 12,
              weight: FontWeight.w400,
            ),
          ),
        ),
      );
    }

    final maxValue = points
        .map((point) => point.value)
        .fold<double>(
          0,
          (previous, value) => previous > value ? previous : value,
        );

    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: points.map((point) {
          final ratio = maxValue == 0
              ? 0.25
              : (point.value / maxValue).clamp(0.2, 1.0);
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 20,
                  height: 120 * ratio,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: colors,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  point.label,
                  style: oneKeepInter(
                    color: oneKeepTextTertiary(context),
                    size: 10,
                    weight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final CategoryRank rank;
  final Color tone;

  const _RankRow({required this.rank, required this.tone});

  @override
  Widget build(BuildContext context) {
    final icon = oneKeepCategoryIcon(
      rank.categoryName,
      rank.categoryName,
      rank.categoryIcon,
    );

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: tone.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: tone),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      rank.categoryName,
                      style: oneKeepInter(
                        color: oneKeepTextPrimary(context),
                        size: 14,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '¥${oneKeepCurrency(rank.amount)}',
                    style: oneKeepGrotesk(
                      color: tone,
                      size: 13,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: SizedBox(
                  height: 4,
                  child: Stack(
                    children: [
                      Container(color: oneKeepGlassStrong(context)),
                      FractionallySizedBox(
                        widthFactor: rank.progressRatio.clamp(0, 1),
                        child: Container(color: tone),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
