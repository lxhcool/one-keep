import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StatTypeToggle extends StatelessWidget {
  const StatTypeToggle({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  final bool isExpense;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.small + 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _tab('支出', isExpense, () => onChanged(true)),
          _tab('收入', !isExpense, () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _tab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
