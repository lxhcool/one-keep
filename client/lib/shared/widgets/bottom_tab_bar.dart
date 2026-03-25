import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'tab_item.dart';

const _tabs = [
  (Icons.home_outlined, '首页'),
  (Icons.bar_chart_outlined, '统计'),
  (Icons.receipt_long_outlined, '账单'),
  (Icons.person_outline, '我的'),
];

class AppBottomTabBar extends StatelessWidget {
  const AppBottomTabBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgPrimary,
        border: Border(top: BorderSide(color: AppColors.borderSubtle, width: 1)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(4, 12, 4, 12 + bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_tabs.length, (i) {
            return TabItem(
              icon: _tabs[i].$1,
              label: _tabs[i].$2,
              isActive: currentIndex == i,
              onTap: () => onTap(i),
            );
          }),
        ),
      ),
    );
  }
}
