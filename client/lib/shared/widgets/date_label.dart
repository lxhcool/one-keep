import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DateLabel extends StatelessWidget {
  const DateLabel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.5,
      ),
    );
  }
}
