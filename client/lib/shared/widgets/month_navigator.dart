import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class MonthNavigator extends StatelessWidget {
  const MonthNavigator({
    super.key,
    required this.year,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    this.canGoNext = false,
  });

  final int year;
  final int month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final bool canGoNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPrevious,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 20),
        Text(
          '$year年$month月',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: canGoNext ? onNext : null,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: canGoNext ? AppColors.bgCard : AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(AppRadius.small),
            ),
            child: Icon(
              Icons.chevron_right_rounded,
              color: canGoNext ? AppColors.textSecondary : AppColors.textTertiary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
