import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    this.size = 48,
    this.gradientColors = const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
    this.icon = Icons.person_outline,
  });

  final double size;
  final List<Color> gradientColors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.56),
    );
  }
}
