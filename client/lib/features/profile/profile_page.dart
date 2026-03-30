import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'category_settings_sheet.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final displayName = preferences.nickname.isNotEmpty
        ? preferences.nickname
        : (authState.user?.name.isNotEmpty == true
              ? authState.user!.name
              : 'OneKeep 用户');
    final username = authState.user?.username?.isNotEmpty == true
        ? '@${authState.user!.username!}'
        : '';
    final totalExpense = statsOverview?.totalExpense ?? 0;
    final totalIncome = statsOverview?.totalIncome ?? 0;
    final balance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0B) : const Color(0xFFF8F9FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 顶部导航
            SliverToBoxAdapter(
              child: _buildHeader(context, isDark),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  
                  // 用户信息卡片 - 采用Block-based设计
                  _UserInfoCard(
                    displayName: displayName,
                    username: username,
                    avatarIndex: preferences.avatarIndex,
                    avatarImageData: preferences.avatarImageData,
                    backgroundImageData: preferences.profileBackgroundImageData,
                    onEditAvatar: _showAvatarStudio,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // 财务概览 - 简洁三列布局
                  _FinanceOverview(
                    expense: totalExpense,
                    income: totalIncome,
                    balance: balance,
                    isLoading: statsState.isLoading && statsOverview == null,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 设置分组
                  _buildSectionTitle('个性化', isDark),
                  const SizedBox(height: 12),
                  
                  // 个性化菜单
                  _PersonalizationMenu(
                    themeLabel: preferences.themeMode == ThemeMode.light
                        ? '浅色模式'
                        : '深色模式',
                    onThemeTap: _showThemePicker,
                    onBackgroundTap: _showBackgroundStudio,
                    onAvatarTap: _showAvatarStudio,
                    onNicknameTap: _showNicknameSheet,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // 设置分组
                  _buildSectionTitle('设置', isDark),
                  const SizedBox(height: 12),
                  
                  // 设置菜单
                  _SettingsMenu(
                    onCategoryTap: _openCategorySettings,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 退出登录
                  _LogoutButton(onTap: () => ref.read(authProvider.notifier).logout()),
                  
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '我的',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF18181B),
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1F) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 20,
              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Future<void> _showAvatarStudio() async {
    final preferences = ref.read(preferencesProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _AvatarStudioSheet(
        avatarIndex: preferences.avatarIndex,
        avatarImageData: preferences.avatarImageData,
        onSelectPreset: (index) {
          ref.read(preferencesProvider.notifier).setAvatarIndex(index);
        },
        onSelectImage: (bytes) {
          final base64Str = base64Encode(bytes);
          ref.read(preferencesProvider.notifier).setAvatarImageData(base64Str);
        },
      ),
    );
  }

  Future<void> _showBackgroundStudio() async {
    final preferences = ref.read(preferencesProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => _BackgroundStudioSheet(
        imageData: preferences.profileBackgroundImageData,
        onSelectImage: (bytes) {
          final base64Str = base64Encode(bytes);
          ref.read(preferencesProvider.notifier).setProfileBackgroundImageData(base64Str);
        },
        onClear: () {
          ref.read(preferencesProvider.notifier).clearProfileBackgroundImageData();
        },
      ),
    );
  }

  Future<void> _showNicknameSheet() async {
    final preferences = ref.read(preferencesProvider);
    final authState = ref.read(authProvider);
    final current = preferences.nickname.isNotEmpty
        ? preferences.nickname
        : (authState.user?.name ?? '');
    
    final controller = TextEditingController(text: current);
    
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NicknameSheet(
        controller: controller,
        onSave: (nickname) {
          if (nickname.isNotEmpty) {
            ref.read(preferencesProvider.notifier).setNickname(nickname);
          }
        },
      ),
    );
  }

  void _openCategorySettings() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CategorySettingsSheet(),
    );
  }

  Future<void> _showThemePicker() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final preferences = ref.watch(preferencesProvider);

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1F) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 拖拽指示条
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3C3C3E) : const Color(0xFFD1D5DB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 标题
                  Text(
                    '外观设置',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 选项卡片
                  Row(
                    children: [
                      Expanded(
                        child: _ThemeOptionCard(
                          icon: Icons.wb_sunny_outlined,
                          title: '浅色',
                          subtitle: '明亮清晰',
                          active: preferences.themeMode == ThemeMode.light,
                          onTap: () async {
                            await ref.read(preferencesProvider.notifier).setThemeMode(ThemeMode.light);
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ThemeOptionCard(
                          icon: Icons.nightlight_round,
                          title: '深色',
                          subtitle: '护眼省电',
                          active: preferences.themeMode == ThemeMode.dark,
                          onTap: () async {
                            await ref.read(preferencesProvider.notifier).setThemeMode(ThemeMode.dark);
                            if (sheetContext.mounted) Navigator.of(sheetContext).pop();
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
      },
    );
  }
}

// 用户信息卡片 - Block-based 设计
class _UserInfoCard extends StatelessWidget {
  final String displayName;
  final String username;
  final int avatarIndex;
  final String? avatarImageData;
  final String? backgroundImageData;
  final VoidCallback onEditAvatar;

  const _UserInfoCard({
    required this.displayName,
    required this.username,
    required this.avatarIndex,
    this.avatarImageData,
    this.backgroundImageData,
    required this.onEditAvatar,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasBackground = backgroundImageData != null && backgroundImageData!.isNotEmpty;
    
    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : const Color(0x1A18181B),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 背景层
            if (hasBackground)
              Positioned.fill(
                child: Image.memory(
                  base64Decode(backgroundImageData!.contains(',') 
                      ? backgroundImageData!.substring(backgroundImageData!.indexOf(',') + 1)
                      : backgroundImageData!),
                  fit: BoxFit.cover,
                ),
              ),
            // 渐变遮罩层
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: hasBackground
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [const Color(0xFF2563EB), const Color(0xFF1D4ED8)]
                              : [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
                        ),
                ),
              ),
            ),
            // 内容层
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // 头像
                  GestureDetector(
                    onTap: onEditAvatar,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: avatarImageData != null && avatarImageData!.isNotEmpty
                            ? Image.memory(
                                base64Decode(avatarImageData!.contains(',')
                                    ? avatarImageData!.substring(avatarImageData!.indexOf(',') + 1)
                                    : avatarImageData!),
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Icon(
                                  oneKeepAvatarPresets[avatarIndex.clamp(0, oneKeepAvatarPresets.length - 1)].icon,
                                  size: 32,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // 用户信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        if (username.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            username,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 财务概览 - 简洁三列
class _FinanceOverview extends StatelessWidget {
  final double expense;
  final double income;
  final double balance;
  final bool isLoading;

  const _FinanceOverview({
    required this.expense,
    required this.income,
    required this.balance,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FinanceItem(
              label: '支出',
              amount: expense,
              color: AppColors.expense,
              isLoading: isLoading,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
          ),
          Expanded(
            child: _FinanceItem(
              label: '收入',
              amount: income,
              color: AppColors.income,
              isLoading: isLoading,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
          ),
          Expanded(
            child: _FinanceItem(
              label: '结余',
              amount: balance,
              color: const Color(0xFF2563EB),
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinanceItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isLoading;

  const _FinanceItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isLoading ? '--' : '¥${oneKeepCurrency(amount)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// 个性化菜单
class _PersonalizationMenu extends StatelessWidget {
  final String themeLabel;
  final VoidCallback onThemeTap;
  final VoidCallback onBackgroundTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onNicknameTap;

  const _PersonalizationMenu({
    required this.themeLabel,
    required this.onThemeTap,
    required this.onBackgroundTap,
    required this.onAvatarTap,
    required this.onNicknameTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.palette_outlined,
            title: '主题外观',
            subtitle: themeLabel,
            color: const Color(0xFF2563EB),
            onTap: onThemeTap,
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB)),
          _MenuItem(
            icon: Icons.wallpaper_outlined,
            title: '卡片背景',
            subtitle: '自定义背景图片',
            color: const Color(0xFF8B5CF6),
            onTap: onBackgroundTap,
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB)),
          _MenuItem(
            icon: Icons.person_outline,
            title: '头像',
            subtitle: '更换头像',
            color: const Color(0xFF10B981),
            onTap: onAvatarTap,
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB)),
          _MenuItem(
            icon: Icons.edit_outlined,
            title: '昵称',
            subtitle: '修改显示名称',
            color: const Color(0xFFF59E0B),
            onTap: onNicknameTap,
          ),
        ],
      ),
    );
  }
}

// 设置菜单
class _SettingsMenu extends StatelessWidget {
  final VoidCallback onCategoryTap;

  const _SettingsMenu({
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.category_outlined,
            title: '分类管理',
            subtitle: '管理收支分类',
            color: const Color(0xFFEF4444),
            onTap: onCategoryTap,
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB)),
          _MenuItem(
            icon: Icons.help_outline_rounded,
            title: '帮助与反馈',
            subtitle: '常见问题、联系我们',
            color: const Color(0xFF6B7280),
            onTap: () {},
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB)),
          _MenuItem(
            icon: Icons.info_outline_rounded,
            title: '关于',
            subtitle: '版本信息',
            color: const Color(0xFF6B7280),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF18181B),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF9CA3AF),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? const Color(0xFF3C3C3E) : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}

// 退出登录按钮
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0x1AEF4444) : const Color(0x08EF4444),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0x30EF4444) : const Color(0x20EF4444),
          ),
        ),
        child: Center(
          child: Text(
            '退出登录',
            style: TextStyle(
              color: AppColors.expense,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// 昵称编辑弹窗
class _NicknameSheet extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSave;

  const _NicknameSheet({
    required this.controller,
    required this.onSave,
  });

  @override
  State<_NicknameSheet> createState() => _NicknameSheetState();
}

class _NicknameSheetState extends State<_NicknameSheet> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 头部
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '修改昵称',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF18181B),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.onSave(widget.controller.text.trim());
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '保存',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 输入框
              TextField(
                controller: widget.controller,
                autofocus: true,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  hintText: '输入昵称',
                  hintStyle: TextStyle(
                    color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF9CA3AF),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool active;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active ? const Color(0xFF2563EB) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF2563EB).withValues(alpha: 0.15) : (isDark ? const Color(0xFF1C1C1F) : Colors.white),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: active ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF9CA3AF)),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF18181B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF9CA3AF),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarStudioSheet extends ConsumerWidget {
  final int avatarIndex;
  final String? avatarImageData;
  final ValueChanged<int> onSelectPreset;
  final ValueChanged<Uint8List> onSelectImage;

  const _AvatarStudioSheet({
    required this.avatarIndex,
    required this.avatarImageData,
    required this.onSelectPreset,
    required this.onSelectImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 拖拽指示条
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3C3C3E) : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 标题
              Text(
                '更换头像',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.photo_library_outlined,
                      label: '从相册选择',
                      color: const Color(0xFF2563EB),
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 82,
                          maxWidth: 1200,
                          maxHeight: 1200,
                        );
                        if (picked != null) {
                          final bytes = await picked.readAsBytes();
                          onSelectImage(bytes);
                        }
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (preferences.avatarImageData != null)
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.delete_outline,
                        label: '移除图片',
                        color: AppColors.expense,
                        onTap: () async {
                          await ref.read(preferencesProvider.notifier).clearAvatarImageData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已移除上传头像')),
                            );
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              // 预设头像标题
              Text(
                '预设头像',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              // 预设头像网格
              SizedBox(
                height: 220,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: oneKeepAvatarPresets.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 80,
                  ),
                  itemBuilder: (context, index) {
                    final selected = preferences.avatarImageData == null &&
                        preferences.avatarIndex == index;
                    return GestureDetector(
                      onTap: () async {
                        onSelectPreset(index);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? const Color(0xFF2563EB) : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            oneKeepAvatarPresets[index].icon,
                            size: 32,
                            color: selected ? const Color(0xFF2563EB) : (isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280)),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackgroundStudioSheet extends ConsumerWidget {
  final String? imageData;
  final ValueChanged<Uint8List> onSelectImage;
  final VoidCallback onClear;

  const _BackgroundStudioSheet({
    required this.imageData,
    required this.onSelectImage,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Uint8List? previewBytes;
    if (preferences.profileBackgroundImageData != null) {
      final data = preferences.profileBackgroundImageData!;
      final normalized = data.contains(',') ? data.substring(data.indexOf(',') + 1) : data;
      try {
        previewBytes = base64Decode(normalized);
      } catch (_) {
        previewBytes = null;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1F) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 拖拽指示条
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3C3C3E) : const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 标题
              Text(
                '更换背景',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF18181B),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              // 预览区域
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: previewBytes == null
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF1D4ED8),
                          ],
                        )
                      : null,
                  image: previewBytes != null
                      ? DecorationImage(
                          image: MemoryImage(previewBytes),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: previewBytes == null
                    ? const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Colors.white54,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 24),
              // 操作按钮
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.photo_library_outlined,
                      label: '从相册选择',
                      color: const Color(0xFF2563EB),
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 74,
                          maxWidth: 1280,
                          maxHeight: 1280,
                        );
                        if (picked != null) {
                          final bytes = await picked.readAsBytes();
                          onSelectImage(bytes);
                        }
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (preferences.profileBackgroundImageData != null)
                    Expanded(
                      child: _ActionCard(
                        icon: Icons.delete_outline,
                        label: '移除背景',
                        color: AppColors.expense,
                        onTap: () async {
                          await ref.read(preferencesProvider.notifier).clearProfileBackgroundImageData();
                          if (context.mounted) Navigator.of(context).pop();
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF18181B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
