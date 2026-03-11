import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../application/home_snapshot_service.dart';
import '../domain/home_snapshot.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

enum _BottomTab { detail, chart, discover, profile }

enum _PageStatus { loading, success, error, empty }

class _HomePageState extends State<HomePage> {
  final HomeSnapshotService _snapshotService = const HomeSnapshotService();

  _BottomTab? _activeTab;
  DateTime _selectedMonth = DateTime(2025, 7);
  HomeSummary _summary = const HomeSummary(income: '0.00', expense: '0.00');
  List<HomeDayGroup> _dayGroups = const [];
  _PageStatus _pageStatus = _PageStatus.loading;
  bool _isDayGroupsLoading = false;
  String? _errorText;
  int _loadToken = 0;

  final List<DateTime> _monthOptions = [
    DateTime(2025, 7),
    DateTime(2025, 6),
    DateTime(2025, 5),
  ];

  @override
  void initState() {
    super.initState();
    _loadMonthData(showFullLoading: true);
  }

  void _handleTabTap(_BottomTab tab) {
    setState(() {
      _activeTab = tab;
    });
  }

  void _handleAddTap() {
    context.push('/transaction/new?month=${_monthKey(_selectedMonth)}').then((
      result,
    ) {
      if (result == true && mounted) {
        _loadMonthData(showFullLoading: false);
      }
    });
  }

  String _monthKey(DateTime month) {
    final monthText = month.month.toString().padLeft(2, '0');
    return '${month.year}-$monthText';
  }

  Future<void> _loadMonthData({required bool showFullLoading}) async {
    final int token = ++_loadToken;

    setState(() {
      _errorText = null;
      if (showFullLoading) {
        _pageStatus = _PageStatus.loading;
      } else {
        _isDayGroupsLoading = true;
      }
    });

    try {
      final HomeSummary summary = await _snapshotService.fetchSummary(
        _selectedMonth,
      );
      if (!mounted || token != _loadToken) {
        return;
      }

      setState(() {
        _summary = summary;
      });

      final List<HomeDayGroup> dayGroups = await _snapshotService
          .fetchDayGroups(_selectedMonth);
      if (!mounted || token != _loadToken) {
        return;
      }

      setState(() {
        _dayGroups = dayGroups;
        _isDayGroupsLoading = false;
        _pageStatus = dayGroups.isEmpty
            ? _PageStatus.empty
            : _PageStatus.success;
      });
    } catch (_) {
      if (!mounted || token != _loadToken) {
        return;
      }

      setState(() {
        _isDayGroupsLoading = false;
        _pageStatus = _PageStatus.error;
        _errorText = '加载失败，请重试';
      });
    }
  }

  Future<void> _openMonthPicker() async {
    final DateTime? selected = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _monthOptions
                .map(
                  (DateTime month) => ListTile(
                    title: Text(
                      '${month.year}年 ${month.month.toString().padLeft(2, '0')}月',
                    ),
                    trailing: _monthKey(month) == _monthKey(_selectedMonth)
                        ? const Icon(Icons.check, color: Color(0xFF222222))
                        : null,
                    onTap: () => Navigator.of(context).pop(month),
                  ),
                )
                .toList(),
          ),
        );
      },
    );

    if (selected != null && _monthKey(selected) != _monthKey(_selectedMonth)) {
      setState(() {
        _selectedMonth = selected;
      });
      await _loadMonthData(showFullLoading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _TopSummarySection(
            yearText: '${_selectedMonth.year}年',
            monthText:
                '${_selectedMonth.month.toString().padLeft(2, '0')}月',
            incomeText: _summary.income,
            expenseText: _summary.expense,
            onMonthTap: _openMonthPicker,
          ),
          Expanded(
            child: _RecordList(
              status: _pageStatus,
              dayGroups: _dayGroups,
              isDayGroupsLoading: _isDayGroupsLoading,
              errorText: _errorText,
              onRetry: () => _loadMonthData(showFullLoading: true),
              onAddTap: _handleAddTap,
              onRecordTap: (String transactionId) =>
                  context.push('/transaction/$transactionId'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        activeTab: _activeTab,
        onTabTap: _handleTabTap,
        onAddTap: _handleAddTap,
      ),
    );
  }
}

class _TopSummarySection extends StatelessWidget {
  const _TopSummarySection({
    required this.yearText,
    required this.monthText,
    required this.incomeText,
    required this.expenseText,
    required this.onMonthTap,
  });

  final String yearText;
  final String monthText;
  final String incomeText;
  final String expenseText;
  final VoidCallback onMonthTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFCD34D),
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
      child: Column(
        children: [
          // Status bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '16:57',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF18181B),
                ),
              ),
              Row(
                children: const [
                  Text(
                    '57%',
                    style: TextStyle(fontSize: 12, color: Color(0xFF18181B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Top row with avatar and title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const Text(
                '鲨鱼记账',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18181B),
                ),
              ),
              const SizedBox(width: 32),
            ],
          ),
          const SizedBox(height: 16),
          // Date selector
          GestureDetector(
            key: const Key('month-selector'),
            onTap: onMonthTap,
            child: Row(
              children: [
                Text(
                  yearText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF52525B),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  monthText,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '▼',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF18181B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Income and expense
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '收入',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF52525B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    incomeText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18181B),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '支出',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF52525B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expenseText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF18181B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecordList extends StatelessWidget {
  const _RecordList({
    required this.status,
    required this.dayGroups,
    required this.isDayGroupsLoading,
    required this.errorText,
    required this.onRetry,
    required this.onAddTap,
    required this.onRecordTap,
  });

  final _PageStatus status;
  final List<HomeDayGroup> dayGroups;
  final bool isDayGroupsLoading;
  final String? errorText;
  final VoidCallback onRetry;
  final VoidCallback onAddTap;
  final ValueChanged<String> onRecordTap;

  @override
  Widget build(BuildContext context) {
    if (status == _PageStatus.loading && dayGroups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (status == _PageStatus.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorText ?? '加载失败，请重试',
              style: const TextStyle(color: Color(0xFF666666)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      );
    }

    if (status == _PageStatus.empty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('本月还没有流水', style: TextStyle(color: Color(0xFF666666))),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: onAddTap, child: const Text('去记一笔')),
          ],
        ),
      );
    }

    final List<Widget> children = <Widget>[];
    if (isDayGroupsLoading) {
      children.add(const LinearProgressIndicator(minHeight: 2));
    }

    for (final HomeDayGroup group in dayGroups) {
      children.add(
        _DateHeader(dateText: group.dateText, totalText: group.totalText),
      );
      for (final HomeRecordItem item in group.items) {
        children.add(
          _RecordItem(
            recordId: item.id,
            name: item.name,
            amount: item.amount,
            kind: item.kind,
            onTap: () => onRecordTap(item.id),
          ),
        );
      }
    }

    return ListView(padding: EdgeInsets.zero, children: children);
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.dateText, required this.totalText});

  final String dateText;
  final String totalText;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          Text(
            dateText,
            style: const TextStyle(fontSize: 13, color: Color(0xFF71717A)),
          ),
          const Spacer(),
          Text(
            totalText,
            style: const TextStyle(fontSize: 13, color: Color(0xFF71717A)),
          ),
        ],
      ),
    );
  }
}

class _RecordItem extends StatelessWidget {
  const _RecordItem({
    required this.recordId,
    required this.name,
    required this.amount,
    required this.kind,
    required this.onTap,
  });

  final String recordId;
  final String name;
  final String amount;
  final HomeRecordKind kind;
  final VoidCallback onTap;

  IconData _resolveIcon(HomeRecordKind recordKind) {
    switch (recordKind) {
      case HomeRecordKind.meal:
        return Icons.restaurant;
      case HomeRecordKind.taxi:
        return Icons.local_taxi;
      case HomeRecordKind.drink:
        return Icons.local_cafe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey<String>('record-$recordId'),
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              _resolveIcon(kind),
              size: 24,
              color: const Color(0xFFFCD34D),
            ),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF18181B),
              ),
            ),
            const Spacer(),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF18181B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.activeTab,
    required this.onTabTap,
    required this.onAddTap,
  });

  final _BottomTab? activeTab;
  final ValueChanged<_BottomTab> onTabTap;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE5E5E5), width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomItem(
                label: '明细',
                icon: Icons.list,
                selected: activeTab == _BottomTab.detail,
                onTap: () => onTabTap(_BottomTab.detail),
              ),
              _BottomItem(
                label: '图表',
                icon: Icons.trending_up,
                selected: activeTab == _BottomTab.chart,
                onTap: () => onTabTap(_BottomTab.chart),
              ),
              GestureDetector(
                key: const Key('add-button'),
                onTap: onAddTap,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCD34D),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 32,
                    color: Color(0xFF18181B),
                  ),
                ),
              ),
              _BottomItem(
                label: '发现',
                icon: Icons.explore,
                selected: activeTab == _BottomTab.discover,
                onTap: () => onTabTap(_BottomTab.discover),
              ),
              _BottomItem(
                label: '我的',
                icon: Icons.person,
                selected: activeTab == _BottomTab.profile,
                onTap: () => onTabTap(_BottomTab.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.label,
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = selected
        ? const Color(0xFF18181B)
        : const Color(0xFF71717A);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }
}
