import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PrimaryFAB extends StatefulWidget {
  const PrimaryFAB({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  State<PrimaryFAB> createState() => _PrimaryFABState();
}

class _PrimaryFABState extends State<PrimaryFAB> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.accentGreen, AppColors.accentGreenDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGreen.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 36),
        ),
      ),
    );
  }
}
