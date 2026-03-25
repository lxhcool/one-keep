import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/user_profile.dart';
import '../../../../shared/widgets/avatar.dart';
import '../../../../shared/widgets/header_icon_button.dart';

class UserGreeting extends StatelessWidget {
  const UserGreeting({
    super.key,
    required this.userProfile,
    required this.onSearchTap,
    required this.onNotificationTap,
  });

  final UserProfile userProfile;
  final VoidCallback onSearchTap;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Avatar(),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${userProfile.greeting}，',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userProfile.truncatedName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            HeaderIconButton(
              icon: Icons.search_outlined,
              color: AppColors.textTertiary,
              onTap: onSearchTap,
            ),
            const SizedBox(width: 16),
            HeaderIconButton(
              icon: Icons.notifications_outlined,
              color: AppColors.textPrimary,
              onTap: onNotificationTap,
            ),
          ],
        ),
      ],
    );
  }
}
