import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/avatar.dart';
import '../../home/application/home_notifier.dart';
import '../../home/application/home_state.dart';
import 'widgets/setting_tile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeAsync = ref.watch(homeNotifierProvider);
    final HomeData? homeData = switch (homeAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final displayName = homeData?.userProfile.displayName ?? '用户';

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const Text(
                    '我的',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  _ProfileCard(displayName: displayName),
                  const SizedBox(height: AppSpacing.section),
                  _SettingGroup(
                    title: '账户',
                    tiles: [
                      SettingTile(
                        icon: Icons.person_outline_rounded,
                        label: '个人信息',
                        onTap: () => _toast(context, '功能即将上线'),
                      ),
                      SettingTile(
                        icon: Icons.notifications_outlined,
                        label: '通知设置',
                        onTap: () => _toast(context, '功能即将上线'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingGroup(
                    title: '偏好',
                    tiles: [
                      SettingTile(
                        icon: Icons.palette_outlined,
                        label: '主题设置',
                        onTap: () => _toast(context, '功能即将上线'),
                      ),
                      SettingTile(
                        icon: Icons.download_outlined,
                        label: '数据导出',
                        onTap: () => _toast(context, '功能即将上线'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SettingGroup(
                    title: '其他',
                    tiles: [
                      SettingTile(
                        icon: Icons.info_outline_rounded,
                        label: '关于 OneKeep',
                        onTap: () => _toast(context, 'OneKeep v0.1.0'),
                      ),
                      SettingTile(
                        icon: Icons.logout_rounded,
                        label: '退出登录',
                        isDestructive: true,
                        trailing: const SizedBox.shrink(),
                        onTap: () => _toast(context, '功能即将上线'),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentGreen, AppColors.accentGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
      ),
      child: Row(
        children: [
          const Avatar(size: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  '普通会员',
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white70),
        ],
      ),
    );
  }
}

class _SettingGroup extends StatelessWidget {
  const _SettingGroup({required this.title, required this.tiles});

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            children: tiles.asMap().entries.map((e) {
              final isLast = e.key == tiles.length - 1;
              if (isLast) return e.value;
              return Column(
                children: [
                  e.value,
                  const Divider(height: 1, color: AppColors.borderSubtle),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
