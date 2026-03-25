import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.message = '数据加载失败',
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accentGreen),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 16, color: AppColors.accentGreen),
                    SizedBox(width: 4),
                    Text('重试', style: TextStyle(color: AppColors.accentGreen, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
