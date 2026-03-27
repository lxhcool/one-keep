import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final preferences = ref.watch(preferencesProvider);
    final displayName = preferences.nickname.isNotEmpty
        ? preferences.nickname
        : (authState.user?.name.isNotEmpty == true
              ? authState.user!.name
              : 'OneKeep 用户');
    final themeLabel = preferences.themeMode == ThemeMode.light
        ? '白天模式'
        : '夜间模式';
    final background = Theme.of(context).brightness == Brightness.dark
        ? AppColors.darkBg
        : AppColors.lightBg;

    return Scaffold(
      backgroundColor: background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: DecoratedBox(
          decoration: BoxDecoration(color: background),
          child: SafeArea(
            top: false,
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
              children: [
                _ProfileSummaryCard(
                  displayName: displayName,
                  avatarIndex: preferences.avatarIndex,
                  avatarImageData: preferences.avatarImageData,
                  backgroundImageData: preferences.profileBackgroundImageData,
                  onEditAvatar: _showAvatarStudio,
                  onEditBackground: _showBackgroundStudio,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MenuGroup(
                        children: [
                          _MenuTile(
                            icon: Icons.wallpaper_outlined,
                            tone: AppColors.info,
                            title: '背景图',
                            subtitle:
                                preferences.profileBackgroundImageData != null
                                ? '已应用于个人中心和首页结余卡片'
                                : '上传背景图，将显示在个人中心和首页',
                            onTap: _showBackgroundStudio,
                          ),
                          _MenuTile(
                            icon: Icons.add_a_photo_outlined,
                            tone: AppColors.teal,
                            title: '头像设置',
                            subtitle: preferences.avatarImageData != null
                                ? '已上传头像'
                                : '使用预设头像',
                            onTap: _showAvatarStudio,
                          ),
                          _MenuTile(
                            icon: Icons.drive_file_rename_outline_rounded,
                            tone: AppColors.purple,
                            title: '昵称设置',
                            subtitle: displayName,
                            onTap: _showNicknameDialog,
                          ),
                          _MenuTile(
                            icon: Icons.light_mode_outlined,
                            tone: AppColors.warning,
                            title: '主题模式',
                            subtitle: themeLabel,
                            onTap: _showThemePicker,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: () =>
                            ref.read(authProvider.notifier).logout(),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(54),
                          side: BorderSide(
                            color: AppColors.expense.withValues(
                              alpha: 0.18,
                            ),
                            width: 0.9,
                          ),
                          backgroundColor: oneKeepSurface(context),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          '退出登录',
                          style: oneKeepManrope(
                          color: AppColors.expense,
                          size: 15,
                          weight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showNicknameDialog() async {
    final preferences = ref.read(preferencesProvider);
    final authState = ref.read(authProvider);
    final initial = preferences.nickname.isNotEmpty
        ? preferences.nickname
        : (authState.user?.name ?? '');
    final controller = TextEditingController(text: initial);
    final saved = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: oneKeepSurface(dialogContext),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: oneKeepBorder(dialogContext), width: 0.8),
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 10),
          contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Text(
            '编辑昵称',
            style: oneKeepGrotesk(
              color: oneKeepTextPrimary(dialogContext),
              size: 22,
              weight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: oneKeepInter(
              color: oneKeepTextPrimary(dialogContext),
              size: 14,
              weight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '输入新的昵称',
              hintStyle: oneKeepInter(
                color: oneKeepTextTertiary(dialogContext),
                size: 14,
                weight: FontWeight.w400,
              ),
              filled: true,
              fillColor: isDark
                  ? AppColors.darkInputBg
                  : AppColors.lightInputBg,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: oneKeepBorder(dialogContext),
                  width: 0.8,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: oneKeepBorder(dialogContext),
                  width: 0.8,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: oneKeepAccent(dialogContext),
                  width: 1,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                '取消',
                style: oneKeepInter(
                  color: oneKeepTextSecondary(dialogContext),
                  size: 14,
                  weight: FontWeight.w500,
                ),
              ),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              style: FilledButton.styleFrom(
                backgroundColor: oneKeepAccent(dialogContext),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                '保存',
                style: oneKeepManrope(
                  color: Colors.white,
                  size: 14,
                  weight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (!mounted || saved == null || saved.isEmpty) return;
    await ref.read(preferencesProvider.notifier).setNickname(saved);
    ref.read(authProvider.notifier).updateLocalUser(name: saved);
  }

  Future<void> _showThemePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.darkDimOverlay,
      builder: (sheetContext) {
        final preferences = ref.watch(preferencesProvider);
        return Container(
          decoration: BoxDecoration(
            color: oneKeepSurface(sheetContext),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: oneKeepBorderStrong(sheetContext),
                width: 0.6,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: oneKeepTextTertiary(
                          sheetContext,
                        ).withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '主题模式',
                    style: oneKeepGrotesk(
                      color: oneKeepTextPrimary(sheetContext),
                      size: 22,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ThemeSheetOption(
                    icon: Icons.wb_sunny_outlined,
                    title: '白天模式',
                    active: preferences.themeMode == ThemeMode.light,
                    onTap: () async {
                      await ref
                          .read(preferencesProvider.notifier)
                          .setThemeMode(ThemeMode.light);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _ThemeSheetOption(
                    icon: Icons.nightlight_round,
                    title: '夜间模式',
                    active: preferences.themeMode == ThemeMode.dark,
                    onTap: () async {
                      await ref
                          .read(preferencesProvider.notifier)
                          .setThemeMode(ThemeMode.dark);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
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

  Future<void> _showAvatarStudio() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.darkDimOverlay,
      builder: (_) => _AvatarStudioSheet(onUpload: _pickAvatarFromGallery),
    );
  }

  Future<void> _pickAvatarFromGallery() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1200,
      maxHeight: 1200,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    await ref
        .read(preferencesProvider.notifier)
        .setAvatarImageData(base64Encode(bytes));
  }

  Future<void> _showBackgroundStudio() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.darkDimOverlay,
      builder: (_) =>
          _BackgroundStudioSheet(onUpload: _pickProfileBackgroundFromGallery),
    );
  }

  Future<void> _pickProfileBackgroundFromGallery() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 74,
      maxWidth: 1280,
      maxHeight: 1280,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    await ref
        .read(preferencesProvider.notifier)
        .setProfileBackgroundImageData(base64Encode(bytes));
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final String displayName;
  final int avatarIndex;
  final String? avatarImageData;
  final String? backgroundImageData;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditBackground;

  const _ProfileSummaryCard({
    required this.displayName,
    required this.avatarIndex,
    required this.avatarImageData,
    required this.backgroundImageData,
    required this.onEditAvatar,
    required this.onEditBackground,
  });

  @override
  Widget build(BuildContext context) {
    final coverBytes = _decodeImageBytes(backgroundImageData);
    final topInset = MediaQuery.paddingOf(context).top;

    return Container(
      height: 220 + topInset,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1720),
        border: Border(
          bottom: BorderSide(color: oneKeepBorderStrong(context), width: 0.8),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (coverBytes != null)
            Image.memory(coverBytes, fit: BoxFit.cover)
          else
            const _ProfileCoverFallback(),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.16),
                  Colors.black.withValues(alpha: 0.24),
                  Colors.black.withValues(alpha: 0.38),
                  Colors.black.withValues(alpha: 0.52),
                ],
              ),
            ),
          ),
          Positioned(
            top: topInset + 18,
            right: 18,
            child: _HeroActionButton(
              icon: Icons.wallpaper_outlined,
              onTap: onEditBackground,
            ),
          ),
          Positioned(
            left: 24,
            top: topInset + 78,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.96),
                    shape: BoxShape.circle,
                  ),
                  child: OneKeepAvatar(
                    avatarIndex: avatarIndex,
                    avatarImageData: avatarImageData,
                    size: 72,
                    iconSize: 30,
                  ),
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: GestureDetector(
                    onTap: onEditAvatar,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: oneKeepAccent(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.96),
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
          ),
          Positioned(
            left: 116,
            right: 24,
            top: topInset + 142,
            child: Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: oneKeepGrotesk(
                color: Colors.white,
                size: 24,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Uint8List? _decodeImageBytes(String? data) {
    if (data == null || data.isEmpty) return null;
    final normalized = data.contains(',')
        ? data.substring(data.indexOf(',') + 1)
        : data;
    try {
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }
}

class _HeroActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeroActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.16),
            width: 0.8,
          ),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _ProfileCoverFallback extends StatelessWidget {
  const _ProfileCoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF223229),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -80,
            top: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                color: Color(0x662E5D38),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -60,
            top: -10,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                color: Color(0x5534662B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -40,
            bottom: -50,
            child: Container(
              width: 240,
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0x66315E35),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  final List<Widget> children;

  const _MenuGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color tone;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.icon,
    required this.tone,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: oneKeepSurface(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: oneKeepBorder(context), width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 18, color: tone),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: oneKeepManrope(
                      color: oneKeepTextPrimary(context),
                      size: 15,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: oneKeepInter(
                      color: oneKeepTextSecondary(context),
                      size: 11,
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: oneKeepTextTertiary(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeSheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool active;
  final VoidCallback onTap;

  const _ThemeSheetOption({
    required this.icon,
    required this.title,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = oneKeepAccent(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active
              ? accent.withValues(alpha: 0.12)
              : oneKeepGlassStrong(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: active ? accent : oneKeepBorder(context),
            width: 0.9,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: active
                    ? accent.withValues(alpha: 0.12)
                    : oneKeepGlass(context),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                size: 18,
                color: active ? accent : oneKeepTextSecondary(context),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: oneKeepManrope(
                  color: active ? accent : oneKeepTextPrimary(context),
                  size: 14,
                  weight: FontWeight.w700,
                ),
              ),
            ),
            if (active) Icon(Icons.check_rounded, size: 18, color: accent),
          ],
        ),
      ),
    );
  }
}

class _AvatarStudioSheet extends ConsumerWidget {
  final Future<void> Function() onUpload;

  const _AvatarStudioSheet({required this.onUpload});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: oneKeepSurface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: oneKeepBorderStrong(context), width: 0.6),
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
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '头像设置',
                style: oneKeepGrotesk(
                  color: oneKeepTextPrimary(context),
                  size: 22,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StudioActionButton(
                      icon: Icons.upload_rounded,
                      label: '上传图片',
                      tone: AppColors.teal,
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        await onUpload();
                        navigator.pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StudioActionButton(
                      icon: Icons.auto_awesome_outlined,
                      label: '使用预设',
                      tone: AppColors.purple,
                      onTap: () async {
                        await ref
                            .read(preferencesProvider.notifier)
                            .clearAvatarImageData();
                      },
                    ),
                  ),
                ],
              ),
              if (preferences.avatarImageData != null) ...[
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    await ref
                        .read(preferencesProvider.notifier)
                        .clearAvatarImageData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('已移除上传头像')));
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.expense.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.expense.withValues(alpha: 0.22),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      '移除上传头像',
                      textAlign: TextAlign.center,
                      style: oneKeepManrope(
                        color: AppColors.expense,
                        size: 13,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: oneKeepAvatarPresets.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: 92,
                ),
                itemBuilder: (context, index) {
                  final selected =
                      preferences.avatarImageData == null &&
                      preferences.avatarIndex == index;
                  return GestureDetector(
                    onTap: () async {
                      await ref
                          .read(preferencesProvider.notifier)
                          .setAvatarIndex(index);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: oneKeepGlass(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: selected
                              ? oneKeepAccent(context)
                              : oneKeepBorder(context),
                          width: selected ? 1 : 0.8,
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
  }
}

class _BackgroundStudioSheet extends ConsumerWidget {
  final Future<void> Function() onUpload;

  const _BackgroundStudioSheet({required this.onUpload});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final previewBytes = preferences.profileBackgroundImageData == null
        ? null
        : base64Decode(preferences.profileBackgroundImageData!);

    return Container(
      decoration: BoxDecoration(
        color: oneKeepSurface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: oneKeepBorderStrong(context), width: 0.6),
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
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: oneKeepTextTertiary(context).withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '背景图设置',
                style: oneKeepGrotesk(
                  color: oneKeepTextPrimary(context),
                  size: 22,
                  weight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: 144,
                  width: double.infinity,
                  child: previewBytes != null
                      ? Image.memory(previewBytes, fit: BoxFit.cover)
                      : const _ProfileCoverFallback(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StudioActionButton(
                      icon: Icons.upload_rounded,
                      label: '上传背景',
                      tone: AppColors.info,
                      onTap: () async {
                        final navigator = Navigator.of(context);
                        await onUpload();
                        navigator.pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StudioActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: '移除背景',
                      tone: AppColors.expense,
                      onTap: preferences.profileBackgroundImageData == null
                          ? () {}
                          : () async {
                              await ref
                                  .read(preferencesProvider.notifier)
                                  .clearProfileBackgroundImageData();
                              if (context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudioActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color tone;
  final VoidCallback onTap;

  const _StudioActionButton({
    required this.icon,
    required this.label,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: tone.withValues(alpha: 0.24), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: tone),
            const SizedBox(width: 8),
            Text(
              label,
              style: oneKeepManrope(
                color: tone,
                size: 13,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
