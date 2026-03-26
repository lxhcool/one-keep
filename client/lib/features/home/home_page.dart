import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/data_providers.dart';
import '../../shared/models/models.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeProvider.notifier).load());
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 6) return '凌晨好';
    if (h < 12) return '早上好';
    if (h < 18) return '下午好';
    return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
                ? Center(child: Text(state.error!))
                : RefreshIndicator(
                    onRefresh: () => ref.read(homeProvider.notifier).load(),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        const SizedBox(height: 16),
                        _buildHeader(isDark),
                        const SizedBox(height: 24),
                        _buildBalanceCard(state.summary!, isDark),
                        const SizedBox(height: 16),
                        _buildIncomeExpenseRow(state.summary!, isDark),
                        const SizedBox(height: 28),
                        _buildRecentSection(
                          state.summary!.recentTransactions,
                          isDark,
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ── Header: avatar(teal ring) + greeting + bell ──
  Widget _buildHeader(bool isDark) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? AppColors.teal.withValues(alpha: 0.6)
                  : AppColors.indigo.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.lightInputBg,
            child: Icon(
              LucideIcons.user,
              size: 20,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'OneKeep 用户',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkInputBg : AppColors.lightInputBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            LucideIcons.bell,
            size: 20,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  // ── Balance Card: glow border + hidden dots ──
  Widget _buildBalanceCard(HomeSummary summary, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.teal.withValues(alpha: 0.15)
              : AppColors.indigo.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          if (isDark)
            BoxShadow(
              color: AppColors.teal.withValues(alpha: 0.08),
              blurRadius: 40,
              offset: const Offset(0, -4),
            ),
          if (!isDark)
            BoxShadow(
              color: AppColors.indigo.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '本月结余',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () =>
                    setState(() => _balanceVisible = !_balanceVisible),
                child: Icon(
                  _balanceVisible ? LucideIcons.eye : LucideIcons.eyeOff,
                  size: 16,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _balanceVisible
                ? '¥ ${_fmt(summary.balance)}'
                : '¥ ••••••••',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          if (_balanceVisible)
            Text(
              '较上月 +8.2%',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.teal : AppColors.indigo,
              ),
            ),
        ],
      ),
    );
  }

  // ── Income / Expense cards ──
  Widget _buildIncomeExpenseRow(HomeSummary summary, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: '本月支出',
            amount: summary.expense,
            icon: Icons.arrow_upward_rounded,
            iconColor: AppColors.expensePink,
            isDark: isDark,
            visible: _balanceVisible,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _MetricCard(
            label: '本月收入',
            amount: summary.income,
            icon: Icons.arrow_downward_rounded,
            iconColor: AppColors.incomeTeal,
            isDark: isDark,
            visible: _balanceVisible,
          ),
        ),
      ],
    );
  }

  // ── Recent section with left accent bar ──
  Widget _buildRecentSection(List<Transaction> txs, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: isDark ? AppColors.teal : AppColors.indigo,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '最近记账',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 0.5,
                color: isDark
                    ? AppColors.darkCardBorder
                    : const Color(0xFFE5E7EB),
              ),
            ),
            const SizedBox(width: 12),
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
                  Icon(
                    LucideIcons.chevronRight,
                    size: 14,
                    color: isDark ? AppColors.teal : AppColors.indigo,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (txs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                '暂无交易记录',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ),
          )
        else
          ...txs.map((tx) => _HomeTransactionRow(tx: tx, isDark: isDark)),
      ],
    );
  }

  String _fmt(double v) {
    return v.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+\.)'),
          (m) => '${m[1]},',
        );
  }
}

// ── Metric card (income/expense) ──
class _MetricCard extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final bool visible;

  const _MetricCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.visible,
  });

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
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            visible ? '¥ ${amount.toStringAsFixed(2)}' : '¥ ••••',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction row matching design ──
class _HomeTransactionRow extends StatelessWidget {
  final Transaction tx;
  final bool isDark;

  const _HomeTransactionRow({required this.tx, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isExp = tx.isExpense;
    final color = isExp ? AppColors.expensePink : AppColors.incomeTeal;
    final sign = isExp ? '-' : '+';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? AppColors.darkCardBorder
                : const Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.1 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(tx.categoryIcon,
                    style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${tx.categoryName} · ${_fmtTime(tx.occurredAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '$sign¥ ${tx.amount.toStringAsFixed(2)}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtTime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    final day = d == today
        ? '今天'
        : d == today.subtract(const Duration(days: 1))
            ? '昨天'
            : '${dt.month}/${dt.day}';
    return '$day ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
