import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_notifier.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/statistics/presentation/statistics_page.dart';
import 'features/ledger/presentation/ledger_page.dart';
import 'features/profile/presentation/profile_page.dart';
import 'features/record/presentation/quick_record_sheet.dart';
import 'shared/widgets/bottom_tab_bar.dart';
import 'shared/widgets/primary_fab.dart';

class _CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) => state = index;
}

final currentTabProvider = NotifierProvider<_CurrentTabNotifier, int>(
  _CurrentTabNotifier.new,
);

class OneKeepApp extends StatelessWidget {
  const OneKeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OneKeep',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const _AuthGate(),
    );
  }
}

/// 根据认证状态路由到不同页面
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // null = 初始化中，检查本地 token
    if (authState == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return authState ? const AppShell() : const LoginPage();
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          IndexedStack(
            index: currentTab,
            children: [
              const HomePage(),
              const StatisticsPage(),
              const LedgerPage(),
              const ProfilePage(),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomTabBar(
              currentIndex: currentTab,
              onTap: (i) => ref.read(currentTabProvider.notifier).setTab(i),
            ),
          ),
          Positioned(
            bottom: bottomPadding + 8,
            left: 0,
            right: 0,
            child: Center(
              child: PrimaryFAB(
                onTap: () => _showQuickRecord(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickRecord(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickRecordSheet(),
    );
  }
}
