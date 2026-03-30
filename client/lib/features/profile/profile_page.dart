import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'category_settings_page.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_providers.dart';
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
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(statsProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final preferences = ref.watch(preferencesProvider);
    final statsState = ref.watch(statsProvider);
    final statsOverview = statsState.overview;
    final displayName = preferences.nickname.isNotEmpty
        ? preferences.nickname
        : (authState.user?.name.isNotEmpty == true
              ? authState.user!.name
              : 'OneKeep 用户');
    final themeLabel = preferences.themeMode == ThemeMode.light
        ? '白天模式'
        : '夜间模式';
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: OneKeepPageBackground(
          variant: OneKeepPageVariant.profile,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _ProfileSummaryCard(
                displayName: displayName,
                username: authState.user?.username?.isNotEmpty == true
                    ? '@${authState.user!.username!}'
                    : '',
                avatarIndex: preferences.avatarIndex,
                avatarImageData: preferences.avatarImageData,
                backgroundImageData: preferences.profileBackgroundImageData,
                onEditAvatar: _showAvatarStudio,
                onEditBackground: _showBackgroundStudio,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileStatsRow(
                      totalExpense: statsOverview?.totalExpense,
                      totalIncome: statsOverview?.totalIncome,
                      isLoading: statsState.isLoading && statsOverview == null,
                    ),
                    const SizedBox(height: 20),
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
                          onTap: _showNicknameSheet,
                        ),
                        _MenuTile(
                          icon: Icons.category_outlined,
                          tone: AppColors.teal,
                          title: '分类设置',
                          subtitle: '管理快速记账使用的分类和图标',
                          onTap: _openCategorySettings,
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
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => ref.read(authProvider.notifier).logout(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            '退出登录',
                            style: oneKeepManrope(
                              color: AppColors.expense,
                              size: 16,
                              weight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
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
    );
  }

  // ignore: unused_element
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

    // Let the dialog route finish tearing down before triggering provider updates.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ref.read(preferencesProvider.notifier).setNickname(saved);
    });
  }

  Future<void> _showNicknameSheet() async {
    final preferences = ref.read(preferencesProvider);
    final authState = ref.read(authProvider);
    final initial = preferences.nickname.isNotEmpty
        ? preferences.nickname
        : (authState.user?.name ?? '');
    final controller = TextEditingController(text: initial);

    final saved = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return OneKeepSheetSurface(
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
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
                    '编辑昵称',
                    style: oneKeepGrotesk(
                      color: oneKeepTextPrimary(sheetContext),
                      size: 22,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '更新后会同步显示在首页和个人中心',
                    style: oneKeepInter(
                      color: oneKeepTextSecondary(sheetContext),
                      size: 13,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    style: oneKeepInter(
                      color: oneKeepTextPrimary(sheetContext),
                      size: 14,
                      weight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: '输入新的昵称',
                      hintStyle: oneKeepInter(
                        color: oneKeepTextTertiary(sheetContext),
                        size: 14,
                        weight: FontWeight.w400,
                      ),
                      filled: true,
                      fillColor: oneKeepGlassStrong(sheetContext),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: oneKeepBorder(sheetContext),
                          width: 0.8,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: oneKeepBorder(sheetContext),
                          width: 0.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: oneKeepAccent(sheetContext),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: Text(
                            '取消',
                            style: oneKeepInter(
                              color: oneKeepTextSecondary(sheetContext),
                              size: 14,
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.of(
                            sheetContext,
                          ).pop(controller.text.trim()),
                          child: Text(
                            '保存',
                            style: oneKeepManrope(
                              color: Colors.white,
                              size: 14,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    controller.dispose();

    if (!mounted || saved == null || saved.isEmpty) return;
    await ref.read(preferencesProvider.notifier).setNickname(saved);
  }

  Future<void> _showThemePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
      builder: (sheetContext) {
        final preferences = ref.watch(preferencesProvider);
        return OneKeepSheetSurface(
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

  Future<void> _openCategorySettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const CategorySettingsPage()),
    );
  }

  Future<void> _showAvatarStudio() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: oneKeepDimOverlay(context),
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
      barrierColor: oneKeepDimOverlay(context),
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

class _ProfileSummaryCard extends StatefulWidget {
  final String displayName;
  final String username;
  final int avatarIndex;
  final String? avatarImageData;
  final String? backgroundImageData;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditBackground;

  const _ProfileSummaryCard({
    required this.displayName,
    required this.username,
    required this.avatarIndex,
    required this.avatarImageData,
    required this.backgroundImageData,
    required this.onEditAvatar,
    required this.onEditBackground,
  });

  @override
  State<_ProfileSummaryCard> createState() => _ProfileSummaryCardState();
}

class _ProfileSummaryCardState extends State<_ProfileSummaryCard> {
  MemoryImage? _coverImageProvider;

  @override
  void initState() {
    super.initState();
    _syncCoverProvider();
  }

  @override
  void didUpdateWidget(covariant _ProfileSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backgroundImageData != widget.backgroundImageData) {
      _syncCoverProvider();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const heroHeight = 280.0;
    const avatarSize = 92.0;

    return SizedBox(
      height: heroHeight + statusBarHeight + 56,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: heroHeight + statusBarHeight,
            child: ClipPath(
              clipper: _ProfileHeroFanClipper(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (_coverImageProvider != null)
                    Image(
                      image: _coverImageProvider!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  else
                    const _ProfileCoverFallback(),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: isDark ? 0.12 : 0.06),
                          Colors.black.withValues(alpha: isDark ? 0.26 : 0.14),
                          Colors.black.withValues(alpha: isDark ? 0.48 : 0.24),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16 + statusBarHeight,
                    right: 16,
                    child: _HeroActionButton(
                      icon: Icons.wallpaper_outlined,
                      onTap: widget.onEditBackground,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
             top: heroHeight + statusBarHeight - 70,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: OneKeepAvatar(
                    avatarIndex: widget.avatarIndex,
                    avatarImageData: widget.avatarImageData,
                    size: avatarSize - 4,
                    iconSize: 34,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    widget.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: oneKeepGrotesk(
                      color: oneKeepTextPrimary(context),
                      size: 18,
                      weight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                if (widget.username.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      widget.username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: oneKeepInter(
                        color: const Color(0xFF308781),
                        size: 13,
                        weight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _syncCoverProvider() {
    final bytes = _decodeImageBytes(widget.backgroundImageData);
    _coverImageProvider = bytes == null ? null : MemoryImage(bytes);
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
          color: oneKeepGlass(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: oneKeepBorderStrong(context), width: 0.8),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  final double? totalExpense;
  final double? totalIncome;
  final bool isLoading;

  const _ProfileStatsRow({
    required this.totalExpense,
    required this.totalIncome,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfileStatTile(
            label: '总支出',
            amount: totalExpense,
            isLoading: isLoading,
            tone: AppColors.expense,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileStatTile(
            label: '总收入',
            amount: totalIncome,
            isLoading: isLoading,
            tone: AppColors.tealDark,
          ),
        ),
      ],
    );
  }
}

class _ProfileStatTile extends StatelessWidget {
  final String label;
  final double? amount;
  final bool isLoading;
  final Color tone;

  const _ProfileStatTile({
    required this.label,
    required this.amount,
    required this.isLoading,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return OneKeepGlassCard(
      radius: 18,
      blurSigma: 12,
      fillColor: oneKeepGlass(context),
      borderColor: oneKeepBorder(context),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: oneKeepInter(
              color: oneKeepTextSecondary(context),
              size: 12,
              weight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isLoading && amount == null ? '--' : '¥${oneKeepCurrency(amount ?? 0)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: oneKeepGrotesk(
              color: tone,
              size: 20,
              weight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCoverFallback extends StatelessWidget {
  const _ProfileCoverFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFd4e5e3),
            Color(0xFF5aaa9f),
            Color(0xFF287f79),
          ],
          stops: [0.0, 0.48, 1.0],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: -80,
            top: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -60,
            top: -10,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -40,
            bottom: -50,
            child: Container(
              width: 240,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroFanClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0);
    path.lineTo(0, size.height - 72);
    path.cubicTo(
      size.width * 0.22,
      size.height - 6,
      size.width * 0.78,
      size.height - 6,
      size.width,
      size.height - 72,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF18181B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 22, color: tone),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: oneKeepManrope(
                      color: oneKeepTextPrimary(context),
                      size: 16,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: oneKeepInter(
                      color: oneKeepTextSecondary(context),
                      size: 13,
                      weight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: oneKeepTextSecondary(context),
                ),
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
    return OneKeepSheetSurface(
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
                          usePresetStyleWhenNoImage: true,
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

    return OneKeepSheetSurface(
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
