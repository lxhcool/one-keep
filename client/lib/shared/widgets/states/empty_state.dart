import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EmptyTransactionsState extends StatelessWidget {
  const EmptyTransactionsState({super.key, this.onAddTap});

  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无账单',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onAddTap,
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: AppColors.textTertiary),
                children: [
                  TextSpan(text: '点击 '),
                  TextSpan(
                    text: '+',
                    style: TextStyle(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(text: ' 记一笔'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
