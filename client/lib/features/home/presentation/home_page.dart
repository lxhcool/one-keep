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
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            _TopSummarySection(
              yearText: '${_selectedMonth.year}年',
              monthText:
                  '${_selectedMonth.month.toString().padLeft(2, '0')}月 ▾',
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
      color: const Color(0xFFE9D35E),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        children: [
          Row(
            children: const [
              Icon(Icons.tag_faces_outlined, size: 20),
              Spacer(),
              Text(
                'One Keep',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
              ),
              Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  widgetKey: const Key('month-selector'),
                  label: yearText,
                  value: monthText,
                  isLeft: true,
                  onTap: onMonthTap,
                ),
              ),
              Expanded(
                child: _SummaryItem(label: '收入', value: incomeText),
              ),
              Expanded(
                child: _SummaryItem(label: '支出', value: expenseText),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    this.widgetKey,
    required this.label,
    required this.value,
    this.isLeft = false,
    this.onTap,
  });

  final Key? widgetKey;
  final String label;
  final String value;
  final bool isLeft;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: EdgeInsets.only(left: isLeft ? 0 : 12),
      decoration: isLeft
          ? null
          : const BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.black26, width: 0.5),
              ),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 34,
              height: 1,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return GestureDetector(
      key: widgetKey,
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
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
      color: const Color(0xFFF7F7F7),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          Text(
            dateText,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9A9A9A)),
          ),
          const Spacer(),
          Text(
            totalText,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9A9A9A)),
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
        return Icons.local_taxi_outlined;
      case HomeRecordKind.drink:
        return Icons.local_drink_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey<String>('record-$recordId'),
      onTap: onTap,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(_resolveIcon(kind), size: 22, color: const Color(0xFF5A5A5A)),
            const SizedBox(width: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 25,
                color: Color(0xFF3D3D3D),
                fontWeight: FontWeight.w300,
              ),
            ),
            const Spacer(),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 31,
                color: Color(0xFF4A4A4A),
                fontWeight: FontWeight.w300,
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
    return BottomAppBar(
      color: Colors.white,
      elevation: 6,
      child: SizedBox(
        height: 76,
        child: Row(
          children: [
            Expanded(
              child: _BottomItem(
                label: '明细',
                icon: Icons.article_outlined,
                selected: activeTab == _BottomTab.detail,
                onTap: () => onTabTap(_BottomTab.detail),
              ),
            ),
            Expanded(
              child: _BottomItem(
                label: '图表',
                icon: Icons.pie_chart_outline,
                selected: activeTab == _BottomTab.chart,
                onTap: () => onTabTap(_BottomTab.chart),
              ),
            ),
            Expanded(child: _CenterRecordEntry(onAddTap: onAddTap)),
            Expanded(
              child: _BottomItem(
                label: '发现',
                icon: Icons.explore_outlined,
                selected: activeTab == _BottomTab.discover,
                onTap: () => onTabTap(_BottomTab.discover),
              ),
            ),
            Expanded(
              child: _BottomItem(
                label: '我的',
                icon: Icons.person_outline,
                selected: activeTab == _BottomTab.profile,
                onTap: () => onTabTap(_BottomTab.profile),
              ),
            ),
          ],
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
        ? const Color(0xFF222222)
        : const Color(0xFF8A8A8A);
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}

class _CenterRecordEntry extends StatelessWidget {
  const _CenterRecordEntry({required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Positioned(
          top: -14,
          child: GestureDetector(
            key: const Key('add-button'),
            onTap: onAddTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE6CF55),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(Icons.add, size: 28, color: Color(0xFF333333)),
            ),
          ),
        ),
        const Positioned(
          bottom: 2,
          child: Text(
            '记账',
            style: TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
          ),
        ),
      ],
    );
  }
}
