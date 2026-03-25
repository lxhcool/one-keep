import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 带渐变动画的 Shimmer 方块
class ShimmerBlock extends StatefulWidget {
  const ShimmerBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.medium,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  State<ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value + 1, 0),
            colors: const [
              AppColors.shimmerBase,
              AppColors.shimmerHighlight,
              AppColors.shimmerBase,
            ],
          ),
        ),
      ),
    );
  }
}

/// 首页专用骨架屏
class HomeLoadingShimmer extends StatelessWidget {
  const HomeLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户问候区骨架
        Row(
          children: [
            const ShimmerBlock(width: 48, height: 48, borderRadius: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBlock(width: 80, height: 13, borderRadius: AppRadius.small),
                const SizedBox(height: 6),
                ShimmerBlock(width: 120, height: 16, borderRadius: AppRadius.small),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.section),
        // 结余卡片骨架
        ShimmerBlock(
            width: double.infinity, height: 160, borderRadius: AppRadius.large),
        const SizedBox(height: AppSpacing.section),
        // 收支统计骨架
        Row(
          children: [
            Expanded(
              child: ShimmerBlock(
                  width: double.infinity,
                  height: 96,
                  borderRadius: AppRadius.large),
            ),
            const SizedBox(width: AppSpacing.card),
            Expanded(
              child: ShimmerBlock(
                  width: double.infinity,
                  height: 96,
                  borderRadius: AppRadius.large),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.section),
        // 近期账单骨架
        ShimmerBlock(width: 100, height: 11, borderRadius: AppRadius.small),
        const SizedBox(height: 8),
        for (int i = 0; i < 3; i++) ...[  
          ShimmerBlock(
              width: double.infinity, height: 72, borderRadius: AppRadius.medium),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
