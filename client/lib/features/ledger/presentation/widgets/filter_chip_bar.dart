import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/ledger_notifier.dart';

class FilterChipBar extends StatelessWidget {
  const FilterChipBar({
    super.key,
    required this.current,
    required this.onChanged,
  });

  final TransactionFilter current;
  final ValueChanged<TransactionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip('全部', TransactionFilter.all),
        const SizedBox(width: 8),
        _chip('支出', TransactionFilter.expense),
        const SizedBox(width: 8),
        _chip('收入', TransactionFilter.income),
      ],
    );
  }

  Widget _chip(String label, TransactionFilter filter) {
    final isActive = current == filter;
    return GestureDetector(
      onTap: () => onChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentGreen : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
