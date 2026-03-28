import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/providers/preferences_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/onekeep_ui.dart';
import '../../shared/widgets/transaction_editor_sheet.dart';

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
    final hour = DateTime.now().hour;
    if (hour < 6) return '凌晨好';
    if (hour < 12) return '早上好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final authState = ref.watch(authProvider);
    final preferences = ref.watch(preferencesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OneKeepPageBackground(
        variant: OneKeepPageVariant.home,
        child: SafeArea(
          bottom: false,
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
              ? Center(child: Text(state.error!))
              : RefreshIndicator(
                  onRefresh: () => ref.read(homeProvider.notifier).load(),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 110),
                    children: [
                      _buildHeader(
                        state.summary,
                        authState.user?.name,
                        preferences,
                      ),
                      const SizedBox(height: 20),
                      if (state.summary != null) ...[
                        _buildBalanceCard(
                          state.summary!,
                          preferences.profileBackgroundImageData,
                        ),
                        const SizedBox(height: 20),
                        _buildIncomeExpenseRow(state.summary!),
                        const SizedBox(height: 20),
                        _buildRecentSection(state.summary!.recentTransactions),
                      ],
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    HomeSummary? summary,
    String? authUserName,
    PreferencesState preferences,
  ) {
    final userName = preferences.nickname.isNotEmpty
        ? preferences.nickname
        : (summary?.user.name.isNotEmpty == true
              ? summary!.user.name
              : (authUserName?.isNotEmpty == true
                    ? authUserName!
                    : 'OneKeep 用户'));

    return Row(
      children: [
        OneKeepAvatar(
          avatarIndex: preferences.avatarIndex,
          avatarImageData: preferences.avatarImageData,
          size: 48,
          iconSize: 22,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _greeting(),
                style: oneKeepManrope(
                  color: oneKeepTextSecondary(context),
                  size: 13,
                  weight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: oneKeepGrotesk(
                  color: oneKeepTextPrimary(context),
                  size: 18,
                  weight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        OneKeepGlassCard(
          radius: 14,
          blurSigma: 10,
          fillColor: oneKeepGlassStrong(context),
          borderColor: oneKeepBorderStrong(context),
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: oneKeepTextSecondary(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(HomeSummary summary, String? backgroundImageData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasBackgroundImage =
        backgroundImageData != null && backgroundImageData.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: oneKeepCardShadows(context, prominent: true),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 背景层：图片或深色高级渐变
            if (hasBackgroundImage)
              Positioned.fill(
                child: _buildBlurredBackground(backgroundImageData),
              )
            else
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? AppColors.balanceGradientDark
                          : AppColors.balanceGradientLight,
                    ),
                  ),
                ),
              ),

            // 光晕点缀 (只在无背景图时显示)
            if (!hasBackgroundImage)
              Positioned(
                right: -40,
                top: -40,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.teal.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // 内容层
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '本月结余',
                        style: oneKeepManrope(
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 14,
                          weight: FontWeight.w500,
                          letterSpacing: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _balanceVisible = !_balanceVisible),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _balanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_balanceVisible)
                    Text(
                      '¥ ${oneKeepCurrency(summary.balance)}',
                      style: oneKeepGrotesk(
                        color: Colors.white,
                        size: 40,
                        weight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    )
                  else
                    Text(
                      '¥ ********',
                      style: oneKeepGrotesk(
                        color: Colors.white,
                        size: 40,
                        weight: FontWeight.w700,
                        letterSpacing: 2.0,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredBackground(String imageData) {
    final bytes = _decodeImageBytes(imageData);
    if (bytes == null) {
      return _buildGradientBackground(
        Theme.of(context).brightness == Brightness.dark,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // 背景图片
        Image.memory(
          bytes,
          fit: BoxFit.cover,
          opacity: const AlwaysStoppedAnimation(0.4),
        ),
        // 高斯模糊层
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(color: Colors.black.withValues(alpha: 0.35)),
        ),
      ],
    );
  }

  Widget _buildGradientBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF5B6B7C), // 深灰蓝
                  const Color(0xFF6B7B8C), // 灰蓝
                ]
              : [
                  const Color(0xFF7B8B9C), // 浅灰蓝
                  const Color(0xFF9BABB9), // 淡灰蓝
                ],
        ),
      ),
    );
  }

  Uint8List? _decodeImageBytes(String? data) {
    if (data == null || data.isEmpty) return null;
    final normalized = data.contains(',')
        ? data.substring(data.indexOf(',') + 1)
        : data;
    try {
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }

  Widget _buildIncomeExpenseRow(HomeSummary summary) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: '本月支出',
            amount: summary.expense,
            icon: Icons.arrow_upward_rounded,
            tone: AppColors.expense,
            visible: _balanceVisible,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _MetricTile(
            label: '本月收入',
            amount: summary.income,
            icon: Icons.arrow_downward_rounded,
            tone: oneKeepIncomeTone(context),
            visible: _balanceVisible,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection(List<Transaction> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.teal, AppColors.purple],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '最近记账',
              style: oneKeepGrotesk(
                color: oneKeepTextPrimary(context),
                size: 16,
                weight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/bills'),
              child: Row(
                children: [
                  Text(
                    '查看全部',
                    style: oneKeepManrope(
                      color: oneKeepTextTertiary(context),
                      size: 13,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: oneKeepTextTertiary(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                '暂无交易记录',
                style: oneKeepManrope(
                  color: oneKeepTextSecondary(context),
                  size: 13,
                  weight: FontWeight.w400,
                ),
              ),
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _HomeTransactionRow(
                transaction: item,
                onTap: () => _showTransactionSheet(item),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _showTransactionSheet(Transaction tx) async {
    final action = await showModalBottomSheet<_TransactionDetailAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
      builder: (_) => _HomeTransactionDetailSheet(transaction: tx),
    );
    if (!mounted || action == null) return;

    if (action == _TransactionDetailAction.edit) {
      await _editTransaction(tx);
    } else if (action == _TransactionDetailAction.delete) {
      await _deleteTransaction(tx);
    }
  }

  Future<void> _editTransaction(Transaction tx) async {
    final draft = await showModalBottomSheet<TransactionEditDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
      builder: (_) => OneKeepTransactionEditorSheet(transaction: tx),
    );
    if (!mounted || draft == null) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.dio.put(
        '/api/transactions/${tx.transactionId}',
        data: draft.toJson(),
      );
      ref.read(homeProvider.notifier).load();
      ref.read(billsProvider.notifier).load();
      ref.read(statsProvider.notifier).load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('记账已更新')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiClient.readableError(error, fallback: '更新失败')),
        ),
      );
    }
  }

  Future<void> _deleteTransaction(Transaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: oneKeepSurface(dialogContext),
        title: Text(
          '删除这条记账？',
          style: oneKeepManrope(
            color: oneKeepTextPrimary(dialogContext),
            size: 18,
            weight: FontWeight.w700,
          ),
        ),
        content: Text(
          '删除后将无法恢复。',
          style: oneKeepInter(
            color: oneKeepTextSecondary(dialogContext),
            size: 13,
            weight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              '取消',
              style: oneKeepInter(
                color: oneKeepTextSecondary(dialogContext),
                size: 14,
                weight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              '删除',
              style: oneKeepInter(
                color: AppColors.expense,
                size: 14,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.dio.delete(
        '/api/transactions/${tx.transactionId}',
        data: const <String, dynamic>{},
      );
      ref.read(homeProvider.notifier).load();
      ref.read(billsProvider.notifier).load();
      ref.read(statsProvider.notifier).load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('记账已删除')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiClient.readableError(error, fallback: '删除失败')),
        ),
      );
    }
  }
}

enum _TransactionDetailAction { edit, delete }

class _MetricTile extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color tone;
  final bool visible;

  const _MetricTile({
    required this.label,
    required this.amount,
    required this.icon,
    required this.tone,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: tone),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: oneKeepManrope(
              color: oneKeepTextSecondary(context),
              size: 13,
              weight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            visible ? '¥ ${oneKeepCurrency(amount)}' : '¥ ****',
            style: oneKeepGrotesk(
              color: oneKeepTextPrimary(context),
              size: 20,
              weight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeTransactionRow extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const _HomeTransactionRow({required this.transaction, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final tone = isExpense ? AppColors.expense : AppColors.income;
    final icon = oneKeepResolvedCategoryIcon(
      transaction.title,
      transaction.categoryName,
      transaction.categoryIcon,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
              ? AppColors.darkCardBorder
              : AppColors.lightCardBorder,
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: tone),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: oneKeepManrope(
                      color: oneKeepTextPrimary(context),
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${transaction.categoryName} · ${oneKeepDayTime(transaction.occurredAt)}',
                    style: oneKeepInter(
                      color: oneKeepTextSecondary(context),
                      size: 12,
                      weight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isExpense ? '-' : '+'} ¥${oneKeepCurrency(transaction.amount)}',
              style: oneKeepGrotesk(
                color: oneKeepTextPrimary(context),
                size: 16,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;

  const _HomeTransactionDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final tone = transaction.isExpense ? AppColors.expense : AppColors.income;
    final icon = oneKeepResolvedCategoryIcon(
      transaction.title,
      transaction.categoryName,
      transaction.categoryIcon,
    );

    return OneKeepSheetSurface(
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 400,
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: tone.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 20, color: tone),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction.title,
                            style: oneKeepManrope(
                              color: oneKeepTextPrimary(context),
                              size: 18,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            transaction.categoryName,
                            style: oneKeepInter(
                              color: oneKeepTextTertiary(context),
                              size: 12,
                              weight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${transaction.isExpense ? '-' : '+'}¥${oneKeepCurrency(transaction.amount)}',
                      style: oneKeepGrotesk(
                        color: tone,
                        size: 22,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: oneKeepBorder(context), height: 1),
                const SizedBox(height: 16),
                _DetailRow(
                  label: '日期',
                  value: oneKeepDayTime(transaction.occurredAt),
                ),
                const SizedBox(height: 14),
                _DetailRow(label: '商家', value: transaction.merchant ?? '暂无商家'),
                const SizedBox(height: 14),
                _DetailRow(label: '备注', value: transaction.note ?? '暂无备注'),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: _SheetActionButton(
                        label: '编辑',
                        icon: Icons.edit_outlined,
                        tone: AppColors.teal,
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_TransactionDetailAction.edit),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SheetActionButton(
                        label: '删除',
                        icon: Icons.delete_outline_rounded,
                        tone: AppColors.expense,
                        onTap: () => Navigator.of(
                          context,
                        ).pop(_TransactionDetailAction.delete),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: oneKeepInter(
            color: oneKeepTextSecondary(context),
            size: 13,
            weight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: oneKeepInter(
            color: oneKeepTextPrimary(context),
            size: 13,
            weight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color tone;
  final VoidCallback onTap;

  const _SheetActionButton({
    required this.label,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: tone.withValues(alpha: 0.24), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: tone),
            const SizedBox(width: 8),
            Text(
              label,
              style: oneKeepManrope(
                color: tone,
                size: 14,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
