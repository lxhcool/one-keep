import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/providers/preferences_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/onekeep_ui.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final preferences = ref.watch(preferencesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayName = preferences.nickname.isNotEmpty
        ? preferences.nickname
        : (authState.user?.name.isNotEmpty == true
              ? authState.user!.name
              : 'OneKeep 用户');
    final email = authState.user?.email ?? '未登录邮箱';
    final accent = oneKeepAccent(context);

    if (_nicknameController.text != preferences.nickname) {
      _nicknameController.value = TextEditingValue(
        text: preferences.nickname,
        selection: TextSelection.collapsed(offset: preferences.nickname.length),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OneKeepPageBackground(
        variant: OneKeepPageVariant.home,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 110),
            children: [
              Text(
                '我的',
                style: oneKeepGrotesk(
                  color: oneKeepTextPrimary(context),
                  size: 28,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              OneKeepGlassCard(
                radius: 22,
                blurSigma: isDark ? 18 : 10,
                fillColor: oneKeepGlass(context),
                borderColor: oneKeepBorderStrong(context),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        OneKeepAvatar(
                          avatarIndex: preferences.avatarIndex,
                          size: 84,
                          iconSize: 36,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _showAvatarPicker,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: accent,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBg
                                      : Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: oneKeepGrotesk(
                        color: oneKeepTextPrimary(context),
                        size: 24,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: oneKeepInter(
                        color: oneKeepTextSecondary(context),
                        size: 13,
                        weight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: '个人资料',
                child: Column(
                  children: [
                    _SettingsRow(
                      context: context,
                      label: '头像',
                      subtitle: '选择一个你喜欢的头像样式',
                      trailing: GestureDetector(
                        onTap: _showAvatarPicker,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OneKeepAvatar(
                              avatarIndex: preferences.avatarIndex,
                              size: 40,
                              iconSize: 18,
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: oneKeepTextTertiary(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '昵称',
                        style: oneKeepManrope(
                          color: oneKeepTextPrimary(context),
                          size: 15,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _nicknameController,
                      style: oneKeepInter(
                        color: oneKeepTextPrimary(context),
                        size: 14,
                        weight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: '输入昵称',
                        hintStyle: oneKeepInter(
                          color: oneKeepTextTertiary(context),
                          size: 14,
                          weight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkInputBg
                            : AppColors.lightInputBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await ref
                              .read(preferencesProvider.notifier)
                              .setNickname(_nicknameController.text);
                          ref
                              .read(authProvider.notifier)
                              .updateLocalUser(
                                name: _nicknameController.text.trim(),
                              );
                        },
                        child: const Text('保存昵称'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _SectionCard(
                title: '显示模式',
                child: Column(
                  children: [
                    _SettingsRow(
                      context: context,
                      label: '界面主题',
                      subtitle: '在浅色和深色模式之间切换',
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _ThemeChip(
                            label: 'Light',
                            icon: Icons.light_mode_outlined,
                            active: preferences.themeMode == ThemeMode.light,
                            onTap: () => ref
                                .read(preferencesProvider.notifier)
                                .setThemeMode(ThemeMode.light),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ThemeChip(
                            label: 'Dark',
                            icon: Icons.dark_mode_outlined,
                            active: preferences.themeMode == ThemeMode.dark,
                            onTap: () => ref
                                .read(preferencesProvider.notifier)
                                .setThemeMode(ThemeMode.dark),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkCardBorderStrong
                        : AppColors.lightHairline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  '退出登录',
                  style: oneKeepManrope(
                    color: oneKeepTextPrimary(context),
                    size: 14,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.darkDimOverlay,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: oneKeepSurface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: oneKeepBorder(context), width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.18)
                            : Colors.black.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '设置头像',
                    style: oneKeepManrope(
                      color: oneKeepTextPrimary(context),
                      size: 18,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: oneKeepAvatarPresets.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 92,
                        ),
                    itemBuilder: (context, index) {
                      final sheetNavigator = Navigator.of(context);
                      return GestureDetector(
                        onTap: () async {
                          await ref
                              .read(preferencesProvider.notifier)
                              .setAvatarIndex(index);
                          if (mounted) sheetNavigator.pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: oneKeepGlass(context),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color:
                                  ref.watch(preferencesProvider).avatarIndex ==
                                      index
                                  ? oneKeepAccent(context)
                                  : oneKeepBorder(context),
                            ),
                          ),
                          child: Center(
                            child: OneKeepAvatar(
                              avatarIndex: index,
                              size: 56,
                              iconSize: 24,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OneKeepGlassCard(
      radius: 20,
      blurSigma: isDark ? 14 : 8,
      fillColor: oneKeepGlass(context),
      borderColor: oneKeepBorder(context),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: oneKeepManrope(
              color: oneKeepTextPrimary(context),
              size: 16,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final BuildContext context;
  final String label;
  final String subtitle;
  final Widget? trailing;

  const _SettingsRow({
    required this.context,
    required this.label,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext _) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: oneKeepManrope(
                  color: oneKeepTextPrimary(context),
                  size: 15,
                  weight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: oneKeepInter(
                  color: oneKeepTextSecondary(context),
                  size: 13,
                  weight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = oneKeepAccent(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: active
              ? accent.withValues(alpha: 0.14)
              : (isDark ? AppColors.darkInputBg : AppColors.lightInputBg),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? accent : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: active ? accent : oneKeepTextSecondary(context),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: oneKeepManrope(
                color: active ? accent : oneKeepTextPrimary(context),
                size: 14,
                weight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
