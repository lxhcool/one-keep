import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/api_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/onekeep_ui.dart';

const _statsPageBackground = Color(0xFFFFFFFF);

enum _StatsRange { day, week, month, year }

extension _StatsRangeLabel on _StatsRange {
  String get label {
    switch (this) {
      case _StatsRange.day:
        return '天';
      case _StatsRange.week:
        return '周';
      case _StatsRange.month:
        return '月';
      case _StatsRange.year:
        return '年';
    }
  }
}

class _ResolvedStats {
  final double totalIncome;
  final double totalExpense;
  final List<TrendPoint> trendSeries;
  final List<CategoryRank> categoryRanks;

  const _ResolvedStats({
    required this.totalIncome,
    required this.totalExpense,
    required this.trendSeries,
    required this.categoryRanks,
  });
}

class _CategoryAggregate {
  final String id;
  final String name;
  final String icon;
  double amount;

  _CategoryAggregate({
    required this.id,
    required this.name,
    required this.icon,
    required this.amount,
  });
}

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String _metricType = 'expense';
  _StatsRange _range = _StatsRange.month;

  final Map<String, StatsOverview> _overviewCache = {};
  bool _isAggregateLoading = false;
  String? _aggregateError;
  _ResolvedStats? _aggregateStats;

  String get _monthKey => DateFormat('yyyy-MM').format(_selectedMonth);

  @override
  void initState() {
    super.initState();
    Future.microtask(_reload);
  }

  Future<void> _reload() async {
    await ref.read(statsProvider.notifier).load(
      month: _monthKey,
      metricType: _metricType,
    );
    await _refreshAggregateData();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statsProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    final categoryColors = <String, String?>{
      for (final item in categories) item.id: item.color,
    };
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentOverview =
        state.overview ?? _overviewCache[_cacheKey(_selectedMonth)];
    if (state.overview != null) {
      _overviewCache[_cacheKey(_selectedMonth)] = state.overview!;
    }

    final displayStats = _resolveDisplayStats(currentOverview);
    final showLoading =
        (state.isLoading && currentOverview == null) ||
        (_needsAggregateFetch && _isAggregateLoading && displayStats == null);
    final showError =
        displayStats == null &&
        ((state.error != null && currentOverview == null) ||
            (_needsAggregateFetch && _aggregateError != null));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : _statsPageBackground,
      body: Column(
        children: [
          _buildGradientHeader(isDark),
          Expanded(
            child: showLoading
                ? const Center(child: CircularProgressIndicator())
                : showError
                ? Center(
                    child: Text(
                      _aggregateError ?? state.error ?? '加载失败',
                      style: oneKeepInter(
                        color: oneKeepTextSecondary(context),
                        size: 13,
                        weight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.paddingOf(context).bottom + 24),
                    children: [
                      if (displayStats != null) ...[
                        _buildTrendSection(displayStats),
                        const SizedBox(height: 28),
                        _buildCategorySection(displayStats, categoryColors),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  bool get _needsAggregateFetch {
    return _range == _StatsRange.month || _range == _StatsRange.year;
  }

  String _cacheKey(DateTime month) {
    return '${DateFormat('yyyy-MM').format(month)}|$_metricType';
  }

  _ResolvedStats? _resolveDisplayStats(StatsOverview? overview) {
    if (overview == null) return _aggregateStats;

    switch (_range) {
      case _StatsRange.day:
        return _ResolvedStats(
          totalIncome: overview.totalIncome,
          totalExpense: overview.totalExpense,
          trendSeries: overview.trendSeries,
          categoryRanks: overview.categoryRanks,
        );
      case _StatsRange.week:
        return _ResolvedStats(
          totalIncome: overview.totalIncome,
          totalExpense: overview.totalExpense,
          trendSeries: _buildWeeklySeries(overview.trendSeries),
          categoryRanks: overview.categoryRanks,
        );
      case _StatsRange.month:
      case _StatsRange.year:
        return _aggregateStats;
    }
  }

  Future<void> _refreshAggregateData() async {
    if (!_needsAggregateFetch) {
      if (!mounted) return;
      setState(() {
        _aggregateStats = null;
        _aggregateError = null;
        _isAggregateLoading = false;
      });
      return;
    }

    setState(() {
      _isAggregateLoading = true;
      _aggregateError = null;
    });

    try {
      final resolved = _range == _StatsRange.month
          ? await _buildYearMonthStats(_selectedMonth.year)
          : await _buildYearStats(_selectedMonth.year);

      if (!mounted) return;
      setState(() {
        _aggregateStats = resolved;
        _aggregateError = null;
        _isAggregateLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _aggregateError = '加载失败';
        _isAggregateLoading = false;
      });
    }
  }

  Future<StatsOverview> _fetchOverview(DateTime month) async {
    final key = _cacheKey(month);
    final cached = _overviewCache[key];
    if (cached != null) return cached;

    final api = ref.read(apiClientProvider);
    final response = await api.dio.get(
      '/api/stats/overview',
      queryParameters: {
        'month': DateFormat('yyyy-MM').format(month),
        'metricType': _metricType,
      },
    );
    final overview = StatsOverview.fromJson(response.data as Map<String, dynamic>);
    _overviewCache[key] = overview;
    return overview;
  }

  Future<_ResolvedStats> _buildYearMonthStats(int year) async {
    final now = DateTime.now();
    final monthCount = year == now.year ? now.month : 12;
    final overviews = await Future.wait(
      List.generate(monthCount, (index) => _fetchOverview(DateTime(year, index + 1))),
    );

    return _ResolvedStats(
      totalIncome: overviews.fold(0.0, (sum, item) => sum + item.totalIncome),
      totalExpense: overviews.fold(0.0, (sum, item) => sum + item.totalExpense),
      trendSeries: [
        for (var index = 0; index < overviews.length; index++)
          TrendPoint(
            label: '${index + 1}月',
            value: _metricType == 'expense'
                ? overviews[index].totalExpense
                : overviews[index].totalIncome,
          ),
      ],
      categoryRanks: _aggregateCategoryRanks(overviews),
    );
  }
  Future<_ResolvedStats> _buildYearStats(int endYear) async {
    final now = DateTime.now();
    final startYear = math.max(2023, endYear - 3);
    final points = <TrendPoint>[];
    final allOverviews = <StatsOverview>[];
    var totalIncome = 0.0;
    var totalExpense = 0.0;

    for (var year = startYear; year <= endYear; year++) {
      final monthCount = year == now.year ? now.month : 12;
      final yearOverviews = await Future.wait(
        List.generate(monthCount, (index) => _fetchOverview(DateTime(year, index + 1))),
      );
      final yearIncome = yearOverviews.fold(0.0, (sum, item) => sum + item.totalIncome);
      final yearExpense = yearOverviews.fold(0.0, (sum, item) => sum + item.totalExpense);

      totalIncome += yearIncome;
      totalExpense += yearExpense;
      allOverviews.addAll(yearOverviews);
      points.add(
        TrendPoint(
          label: '$year',
          value: _metricType == 'expense' ? yearExpense : yearIncome,
        ),
      );
    }

    return _ResolvedStats(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      trendSeries: points,
      categoryRanks: _aggregateCategoryRanks(allOverviews),
    );
  }

  List<TrendPoint> _buildWeeklySeries(List<TrendPoint> points) {
    if (points.isEmpty) return const [];

    final weekTotals = <int, double>{};
    for (final point in points) {
      final day = int.tryParse(point.label.split('-').last) ?? 1;
      final weekIndex = ((day - 1) ~/ 7) + 1;
      weekTotals[weekIndex] = (weekTotals[weekIndex] ?? 0) + point.value;
    }

    final keys = weekTotals.keys.toList()..sort();
    return keys
        .map((week) => TrendPoint(label: '第$week周', value: weekTotals[week] ?? 0))
        .toList();
  }

  List<CategoryRank> _aggregateCategoryRanks(List<StatsOverview> overviews) {
    final aggregates = <String, _CategoryAggregate>{};

    for (final overview in overviews) {
      for (final rank in overview.categoryRanks) {
        final current = aggregates[rank.categoryId];
        if (current == null) {
          aggregates[rank.categoryId] = _CategoryAggregate(
            id: rank.categoryId,
            name: rank.categoryName,
            icon: rank.categoryIcon,
            amount: rank.amount,
          );
        } else {
          current.amount += rank.amount;
        }
      }
    }

    final items = aggregates.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final maxAmount = items.isEmpty ? 0.0 : items.first.amount;
    return items.take(5).map((item) {
      return CategoryRank(
        categoryId: item.id,
        categoryName: item.name,
        categoryIcon: item.icon,
        amount: item.amount,
        progressRatio: maxAmount > 0 ? item.amount / maxAmount : 0,
      );
    }).toList();
  }

  Widget _buildGradientHeader(bool isDark) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0D1111), const Color(0xFF0D1111)]
              : [const Color(0xFF065F46), const Color(0xFF0D9373)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, topInset + 16, 16, 20),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '统计',
                  style: oneKeepGrotesk(
                    color: Colors.white,
                    size: 28,
                    weight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '查看你的收支趋势',
                  style: oneKeepInter(
                    color: Colors.white.withValues(alpha: 0.6),
                    size: 13,
                    weight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: _showMonthPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      [_selectedMonth.year, _selectedMonth.month.toString().padLeft(2, '0')].join('/'),
                      style: oneKeepInter(
                        color: Colors.white.withValues(alpha: 0.9),
                        size: 13,
                        weight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 14,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ],
                ),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '统计',
              style: oneKeepGrotesk(
                color: oneKeepTextPrimary(context),
                size: 28,
                weight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '查看你的收支趋势',
              style: oneKeepInter(
                color: oneKeepTextSecondary(context),
                size: 13,
                weight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrendSection(_ResolvedStats stats) {
    const tone = Color(0xFF308781);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '收支趋势',
              style: oneKeepManrope(
                color: oneKeepTextPrimary(context),
                size: 18,
                weight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            _MetricToggle(
              isExpense: _metricType == 'expense',
              onChanged: (value) async {
                setState(() => _metricType = value ? 'expense' : 'income');
                await _reload();
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _metricType == 'expense'
                        ? '¥${oneKeepCurrency(stats.totalExpense)}'
                        : '¥${oneKeepCurrency(stats.totalIncome)}',
                    style: oneKeepGrotesk(
                      color: oneKeepTextPrimary(context),
                      size: 24,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _showRangePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: oneKeepGlassStrong(context),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _range.label,
                            style: oneKeepInter(
                              color: oneKeepTextTertiary(context),
                              size: 12,
                              weight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.expand_more_rounded,
                            size: 14,
                            color: oneKeepTextTertiary(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _needsAggregateFetch && _isAggregateLoading
                  ? SizedBox(
                      height: 184,
                      child: Center(
                        child: CircularProgressIndicator(color: tone),
                      ),
                    )
                  : _needsAggregateFetch && _aggregateError != null
                  ? SizedBox(
                      height: 184,
                      child: Center(
                        child: Text(
                          _aggregateError!,
                          style: oneKeepInter(
                            color: oneKeepTextSecondary(context),
                            size: 13,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : _TrendBars(
                      points: stats.trendSeries,
                      tone: tone,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(
    _ResolvedStats stats,
    Map<String, String?> categoryColors,
  ) {
    final ranks = stats.categoryRanks.take(5).toList();
    final totalAmount = ranks.isEmpty
        ? 0.0
        : ranks
              .map((rank) => rank.amount)
              .reduce((current, next) => current + next);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类排行',
          style: oneKeepManrope(
            color: oneKeepTextPrimary(context),
            size: 18,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        if (ranks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: OneKeepEmptyState(
              icon: Icons.pie_chart_outline_rounded,
              message: '暂无数据',
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < ranks.length; i++)
                _RankRow(
                  rank: ranks[i],
                  categoryColor: categoryColors[ranks[i].categoryId] ?? ranks[i].categoryColor,
                  progressRatio: totalAmount > 0 ? ranks[i].amount / totalAmount : 0,
                  isEven: i.isEven,
                ),
            ],
          ),
      ],
    );
  }

  void _showMonthPicker() {
    var displayYear = _selectedMonth.year;
    final now = DateTime.now();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return OneKeepSheetSurface(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: oneKeepTextTertiary(context).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Year navigator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            _yearNavButton(
                              context: context,
                              icon: Icons.chevron_left_rounded,
                              enabled: true,
                              isDark: isDark,
                              onTap: () => setModalState(() => displayYear -= 1),
                            ),
                            const Spacer(),
                            Text(
                              '$displayYear年',
                              style: oneKeepGrotesk(
                                color: oneKeepTextPrimary(context),
                                size: 18,
                                weight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            _yearNavButton(
                              context: context,
                              icon: Icons.chevron_right_rounded,
                              enabled: displayYear < now.year,
                              isDark: isDark,
                              onTap: displayYear < now.year
                                  ? () => setModalState(() => displayYear += 1)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Month grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 12,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 48,
                        ),
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final disabled = displayYear == now.year && month > now.month;
                          final selected =
                              displayYear == _selectedMonth.year &&
                              month == _selectedMonth.month;
                          final isCurrent = displayYear == now.year && month == now.month;

                          return GestureDetector(
                            onTap: disabled
                                ? null
                                : () async {
                                    setState(() {
                                      _selectedMonth = DateTime(displayYear, month);
                                    });
                                    Navigator.pop(context);
                                    await _reload();
                                  },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              curve: Curves.easeOut,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.teal
                                    : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02)),
                                borderRadius: BorderRadius.circular(14),
                                border: isCurrent && !selected
                                    ? Border.all(color: AppColors.teal.withValues(alpha: 0.4), width: 1.5)
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$month月',
                                style: oneKeepGrotesk(
                                  color: selected
                                      ? Colors.white
                                      : disabled
                                      ? oneKeepTextTertiary(context).withValues(alpha: 0.3)
                                      : oneKeepTextPrimary(context),
                                  size: 15,
                                  weight: selected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _yearNavButton({
    required BuildContext context,
    required IconData icon,
    required bool enabled,
    required bool isDark,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: enabled && !isDark ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          color: enabled
              ? oneKeepTextSecondary(context)
              : oneKeepTextTertiary(context).withValues(alpha: 0.3),
          size: 20,
        ),
      ),
    );
  }

  void _showRangePicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
      builder: (sheetContext) {
        return OneKeepSheetSurface(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                        '切换统计范围',
                        style: oneKeepManrope(
                          color: oneKeepTextPrimary(context),
                          size: 18,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(sheetContext),
                        child: Icon(
                          Icons.close_rounded,
                          color: oneKeepTextSecondary(context),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ..._StatsRange.values.map((range) {
                    final selected = range == _range;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          if (selected) return;
                          setState(() => _range = range);
                          if (_needsAggregateFetch) {
                            await _refreshAggregateData();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.teal.withValues(alpha: 0.14)
                                : oneKeepGlassStrong(context),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Text(
                                range.label,
                                style: oneKeepInter(
                                  color: selected
                                      ? AppColors.tealDark
                                      : oneKeepTextPrimary(context),
                                  size: 14,
                                  weight: selected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              if (selected)
                                Icon(
                                  Icons.check_rounded,
                                  color: AppColors.tealDark,
                                  size: 18,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: oneKeepGlassStrong(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _toggleChip(
            context: context,
            label: '支出',
            active: isExpense,
            onTap: () => onChanged(true),
          ),
          _toggleChip(
            context: context,
            label: '收入',
            active: !isExpense,
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.teal.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: oneKeepInter(
            color: active ? AppColors.tealDark : oneKeepTextTertiary(context),
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
  final Color tone;

  const _TrendBars({required this.points, required this.tone});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return const SizedBox(
        height: 184,
        child: OneKeepEmptyState(
          icon: Icons.bar_chart,
          message: '暂无数据',
        ),
      );
    }

    final maxValue = points.fold<double>(0, (max, point) => math.max(max, point.value));
    final showEvery = math.max(1, (points.length / 6).ceil());

    return Column(
      children: [
        SizedBox(
          height: 166,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: points.asMap().entries.map((entry) {
              final point = entry.value;
              final ratio = maxValue <= 0 ? 0.18 : (point.value / maxValue).clamp(0.12, 1.0);
              final active = entry.key == points.length - 1;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (point.value > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '¥${oneKeepCurrency(point.value)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: oneKeepInter(
                              color: oneKeepTextTertiary(context),
                              size: 10,
                              weight: FontWeight.w400,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 14),
                      Container(
                        width: 18,
                        height: 116 * ratio,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(999),
                            topRight: Radius.circular(999),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              tone.withValues(alpha: active ? 1 : 0.86),
                              tone.withValues(alpha: active ? 0.78 : 0.58),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: points.asMap().entries.map((entry) {
            final visible =
                entry.key == 0 ||
                entry.key == points.length - 1 ||
                entry.key % showEvery == 0;
            return Expanded(
              child: Text(
                visible ? entry.value.label : '',
                textAlign: TextAlign.center,
                style: oneKeepInter(
                  color: oneKeepTextTertiary(context),
                  size: 10,
                  weight: FontWeight.w400,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  final CategoryRank rank;
  final String? categoryColor;
  final double progressRatio;
  final bool isEven;

  const _RankRow({
    required this.rank,
    required this.categoryColor,
    required this.progressRatio,
    this.isEven = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = oneKeepCategoryTone(
      colorHex: categoryColor,
      categoryId: rank.categoryId,
      categoryName: rank.categoryName,
      categoryIcon: rank.categoryIcon,
    );
    final visibleProgress = rank.amount <= 0
        ? 0.0
        : progressRatio.clamp(0.04, 1.0);
    final rowColor = isEven
        ? (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02))
        : Colors.transparent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: rowColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          OneKeepCategoryBadge(
            title: rank.categoryName,
            categoryName: rank.categoryName,
            categoryIcon: rank.categoryIcon,
            categoryId: rank.categoryId,
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
                  rank.categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: oneKeepInter(
                    color: oneKeepTextPrimary(context),
                    size: 14,
                    weight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 6,
                        color: tone.withValues(alpha: 0.10),
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: visibleProgress,
                          child: SizedBox.expand(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    tone.withValues(alpha: 0.72),
                                    tone,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '¥${oneKeepCurrency(rank.amount)}',
            style: oneKeepGrotesk(
              color: tone,
              size: 16,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
