import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/data_providers.dart';
import '../../shared/models/models.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  String _metricType = 'expense';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _reload());
  }

  void _reload() {
    ref
        .read(statsProvider.notifier)
        .load(month: _selectedMonth, metricType: _metricType);
  }

  void _switchMetric(String type) {
    setState(() => _metricType = type);
    ref
        .read(statsProvider.notifier)
        .load(month: _selectedMonth, metricType: type);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? Center(child: Text(state.error!))
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 16),
                      _buildHeader(isDark),
                      const SizedBox(height: 20),
                      _buildSummaryRow(state.overview!, isDark),
                      const SizedBox(height: 20),
                      _buildTrendCard(state.overview!, isDark),
                      const SizedBox(height: 20),
                      _buildCategoryRanking(state.overview!, isDark),
                      const SizedBox(height: 32),
                    ],
                  ),
      ),
    );
  }

  // ── Header: "统计" + month picker chip ──
  Widget _buildHeader(bool isDark) {
    final d = DateTime.tryParse('$_selectedMonth-01');
    final label =
        d != null ? DateFormat('yyyy年M月').format(d) : _selectedMonth;

    return Row(
      children: [
        Text(
          '统计',
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
          onTap: () => _showMonthPicker(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? AppColors.darkCardBorder
                    : const Color(0xFFE5E7EB),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.chevronLeft,
                    size: 14,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(LucideIcons.chevronRight,
                    size: 14,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Summary cards ──
  Widget _buildSummaryRow(StatsOverview overview, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: '总支出',
            amount: overview.totalExpense,
            color: AppColors.expensePink,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _SummaryCard(
            label: '总收入',
            amount: overview.totalIncome,
            color: AppColors.incomeTeal,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  // ── Trend chart card with toggle chips ──
  Widget _buildTrendCard(StatsOverview overview, bool isDark) {
    final isExp = _metricType == 'expense';
    final trend = overview.trendSeries;
    final gradientColors =
        isExp ? AppColors.expenseGradient : AppColors.incomeGradient;
    final maxY = trend.isEmpty
        ? 100.0
        : trend.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
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
          // Title + metric toggle
          Row(
            children: [
              Text(
                isExp ? '支出趋势' : '收入趋势',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              _ChipToggle(
                left: '支出',
                right: '收入',
                isLeft: isExp,
                isDark: isDark,
                onToggle: (left) =>
                    _switchMetric(left ? 'expense' : 'income'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bar chart
          SizedBox(
            height: 180,
            child: trend.isEmpty
                ? Center(
                    child: Text('暂无数据',
                        style: TextStyle(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.lightTextTertiary)))
                : BarChart(
                    BarChartData(
                      maxY: maxY * 1.3,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= trend.length) {
                                return const SizedBox.shrink();
                              }
                              // Show every label for <=7 items, else every 5th
                              if (trend.length <= 7 || idx % 5 == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    trend[idx].label,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.darkTextTertiary
                                          : AppColors.lightTextTertiary,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: trend.asMap().entries.map((e) {
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.value,
                              width: trend.length <= 7 ? 24 : 8,
                              borderRadius: BorderRadius.circular(
                                  trend.length <= 7 ? 6 : 3),
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Category ranking card with top 3 ──
  Widget _buildCategoryRanking(StatsOverview overview, bool isDark) {
    final isExp = _metricType == 'expense';
    final ranks = overview.categoryRanks;

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '分类排行',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              if (ranks.length > 3)
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '查看全部',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.teal : AppColors.indigo,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(LucideIcons.chevronRight,
                          size: 14,
                          color:
                              isDark ? AppColors.teal : AppColors.indigo),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (ranks.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('暂无数据',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary)),
              ),
            )
          else
            ...ranks.take(3).map(
                  (r) => _RankRow(
                    rank: r,
                    isDark: isDark,
                    barColor:
                        isExp ? AppColors.expensePink : AppColors.incomeTeal,
                  ),
                ),
        ],
      ),
    );
  }

  void _showMonthPicker(BuildContext context) {
    final now = DateTime.now();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.sheet)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(12, (i) {
                    final d = DateTime(now.year, now.month - i);
                    final m = DateFormat('yyyy-MM').format(d);
                    final label = DateFormat('yyyy年M月').format(d);
                    final selected = m == _selectedMonth;
                    final accent =
                        isDark ? AppColors.teal : AppColors.indigo;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() => _selectedMonth = m);
                        _reload();
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? accent.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: selected
                              ? Border.all(color: accent, width: 1)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            label,
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
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Summary card ──
class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isDark;

  const _SummaryCard(
      {required this.label,
      required this.amount,
      required this.color,
      required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary)),
          const SizedBox(height: 8),
          Text(
            '¥ ${amount.toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip toggle (支出/收入) ──
class _ChipToggle extends StatelessWidget {
  final String left;
  final String right;
  final bool isLeft;
  final bool isDark;
  final ValueChanged<bool> onToggle;

  const _ChipToggle({
    required this.left,
    required this.right,
    required this.isLeft,
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDark ? AppColors.teal : AppColors.indigo;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _chip(left, isLeft, accent),
          _chip(right, !isLeft, accent),
        ],
      ),
    );
  }

  Widget _chip(String label, bool active, Color accent) {
    return GestureDetector(
      onTap: () => onToggle(label == left),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active
              ? (isDark ? AppColors.darkSurface : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
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
    );
  }
}

// ── Category rank row ──
class _RankRow extends StatelessWidget {
  final CategoryRank rank;
  final bool isDark;
  final Color barColor;

  const _RankRow(
      {required this.rank, required this.isDark, required this.barColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: barColor.withValues(alpha: isDark ? 0.1 : 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(rank.categoryIcon,
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rank.categoryName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: rank.progressRatio.clamp(0.0, 1.0),
                    minHeight: 4,
                    backgroundColor: isDark
                        ? AppColors.darkInputBg
                        : AppColors.lightInputBg,
                    valueColor: AlwaysStoppedAnimation(barColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '¥${rank.amount.toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: barColor,
            ),
          ),
        ],
      ),
    );
  }
}
