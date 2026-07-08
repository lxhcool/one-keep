import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:liqing/core/theme/lucide_icons_compat.dart';

import '../../core/theme/app_colors.dart';
import '../models/models.dart';
import 'onekeep_ui.dart';

class OneKeepTransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;
  final String? categoryColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const OneKeepTransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.categoryColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = transaction.isExpense ? AppColors.rose : AppColors.emerald;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.76;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.78)
                : Colors.white.withValues(alpha: 0.86),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OneKeepCategoryBadge(
                        title: transaction.title,
                        categoryName: transaction.categoryName,
                        categoryIcon: transaction.categoryIcon,
                        categoryId: transaction.categoryId,
                        colorHex: categoryColor,
                        size: 48,
                        iconSize: 24,
                        radius: 14,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.categoryName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: oneKeepManrope(
                                color: oneKeepTextPrimary(context),
                                size: 20,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${transaction.isExpense ? '-' : '+'}¥${oneKeepCurrency(transaction.amount)}',
                        maxLines: 1,
                        style: oneKeepGrotesk(
                          color: tone,
                          size: 30,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(
                        alpha: 0.04,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha: 0.05),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: '交易日期',
                          value: oneKeepDayTime(transaction.occurredAt),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, thickness: 0.5),
                        ),
                        _DetailRow(
                          label: '商家名称',
                          value: transaction.merchant ?? '暂无商家',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, thickness: 0.5),
                        ),
                        _DetailRow(
                          label: '交易备注',
                          value: transaction.note ?? '暂无备注',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _SheetActionButton(
                          label: '编辑',
                          icon: LucideIcons.edit3,
                          tone: AppColors.emerald,
                          onTap: onEdit,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SheetActionButton(
                          label: '删除',
                          icon: LucideIcons.trash2,
                          tone: AppColors.rose,
                          onTap: onDelete,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
            weight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: oneKeepInter(
              color: oneKeepTextPrimary(context),
              size: 14,
              weight: FontWeight.w700,
            ),
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
    return OneKeepBouncingCard(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: tone,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: oneKeepManrope(
                color: Colors.white,
                size: 15,
                weight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
