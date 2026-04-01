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
        : (authState.user?.name.isNotEmpty == true ? authState.user!.name : 'OneKeep 用户');
    final username = authState.user?.username?.isNotEmpty == true
        ? '@${authState.user!.username!}' : '';
    final totalExpense = statsOverview?.totalExpense ?? 0;
    final totalIncome = statsOverview?.totalIncome ?? 0;
    final balance = totalIncome - totalExpense;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverAppBar(
            expandedHeight: 280.0,
            floating: false,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: _HeaderBackground(
                backgroundImageData: preferences.profileBackgroundImageData,
                avatarIndex: preferences.avatarIndex,
                avatarImageData: preferences.avatarImageData,
                displayName: displayName,
                username: username,
                onEditAvatar: _showAvatarStudio,
                onEditNickname: _showNicknameSheet,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('财务概况', isDark),
                    const SizedBox(height: 12),
                    _FinanceDashboardCard(
                      expense: totalExpense,
                      income: totalIncome,
                      balance: balance,
                      isLoading: statsState.isLoading && statsOverview == null,
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('个性化与设置', isDark),
                    const SizedBox(height: 12),
                    _BentoGridMenu(
                      preferences: preferences,
                      onThemeTap: _showThemePicker,
                      onBackgroundTap: _showBackgroundStudio,
                      onAvatarTap: _showAvatarStudio,
                      onNicknameTap: _showNicknameSheet,
                      onCategoryTap: _openCategorySettings,
                    ),
                    const SizedBox(height: 48),
                    OneKeepBouncingCard(
                      onTap: () => ref.read(authProvider.notifier).logout(),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0x1AEF4444) : const Color(0x0CEF4444),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? const Color(0x40EF4444) : const Color(0x2CEF4444),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '退出登录',
                            style: TextStyle(
                              color: AppColors.expense,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? const Color(0xFF6E6E73) : const Color(0xFF86868B),
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
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

// 用户信息卡片 - 沉浸式头部设计
class _HeaderBackground extends StatelessWidget {
  final String? backgroundImageData;
  final int avatarIndex;
  final String? avatarImageData;
  final String displayName;
  final String username;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditNickname;

  const _HeaderBackground({
    this.backgroundImageData,
    required this.avatarIndex,
    this.avatarImageData,
    required this.displayName,
    required this.username,
    required this.onEditAvatar,
    required this.onEditNickname,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasBackground = backgroundImageData != null && backgroundImageData!.isNotEmpty;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasBackground)
          Image.memory(
            base64Decode(backgroundImageData!.contains(',')
                ? backgroundImageData!.substring(backgroundImageData!.indexOf(',') + 1)
                : backgroundImageData!),
            fit: BoxFit.cover,
          )
        else
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF121214), const Color(0xFF1C1C1E)]
                    : [const Color(0xFFE2E2E7), const Color(0xFFF2F2F7)],
              ),
            ),
          ),
        
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                if (hasBackground) Colors.black.withValues(alpha: 0.3) else Colors.transparent,
                if (hasBackground) Colors.black.withValues(alpha: 0.7) 
                else (isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7)),
              ],
            ),
          ),
        ),

        Positioned(
          left: 20,
          bottom: 40,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              OneKeepBouncingCard(
                onTap: onEditAvatar,
                child: Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: hasBackground 
                            ? Colors.white.withValues(alpha: 0.4) 
                            : (isDark ? const Color(0xFF2C2C2E) : Colors.white),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: avatarImageData != null && avatarImageData!.isNotEmpty
                          ? Image.memory(
                              base64Decode(avatarImageData!.contains(',')
                                  ? avatarImageData!.substring(avatarImageData!.indexOf(',') + 1)
                                  : avatarImageData!),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                              child: Center(
                                child: Icon(
                                  oneKeepAvatarPresets[avatarIndex.clamp(0, oneKeepAvatarPresets.length - 1)].icon,
                                  size: 40,
                                  color: AppColors.teal,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: OneKeepBouncingCard(
                  onTap: onEditNickname,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        displayName,
                        style: TextStyle(
                          color: hasBackground ? Colors.white : (isDark ? Colors.white : const Color(0xFF1D1D1F)),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (username.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: hasBackground 
                                ? Colors.white.withValues(alpha: 0.2) 
                                : (isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            username,
                            style: TextStyle(
                              color: hasBackground 
                                  ? Colors.white.withValues(alpha: 0.9) 
                                  : (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF86868B)),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 高级财务面板卡片
class _FinanceDashboardCard extends StatelessWidget {
  final double expense;
  final double income;
  final double balance;
  final bool isLoading;

  const _FinanceDashboardCard({
    required this.expense,
    required this.income,
    required this.balance,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : const Color(0x0C000000),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '总结余',
                style: TextStyle(
                  color: isDark ? const Color(0xFF86868B) : const Color(0xFF86868B),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                isLoading ? '--' : '¥${oneKeepCurrency(balance)}',
                style: TextStyle(
                  color: balance >= 0 ? AppColors.teal : AppColors.expense,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _FinanceItemModern(
                  label: '本月支出',
                  amount: expense,
                  color: AppColors.expense,
                  isLoading: isLoading,
                  icon: Icons.arrow_outward_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 48,
                color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
              ),
              Expanded(
                child: _FinanceItemModern(
                  label: '本月收入',
                  amount: income,
                  color: AppColors.income,
                  isLoading: isLoading,
                  icon: Icons.south_west_rounded,
                  alignment: CrossAxisAlignment.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinanceItemModern extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isLoading;
  final IconData icon;
  final CrossAxisAlignment alignment;

  const _FinanceItemModern({
    required this.label,
    required this.amount,
    required this.color,
    required this.isLoading,
    required this.icon,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
            ),
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF8E8E93),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          isLoading ? '--' : '¥${oneKeepCurrency(amount)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1D1D1F),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BentoGridMenu extends StatelessWidget {
  final dynamic preferences;
  final VoidCallback onThemeTap;
  final VoidCallback onBackgroundTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onNicknameTap;
  final VoidCallback onCategoryTap;

  const _BentoGridMenu({
    required this.preferences,
    required this.onThemeTap,
    required this.onBackgroundTap,
    required this.onAvatarTap,
    required this.onNicknameTap,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLightMode = preferences.themeMode == ThemeMode.light;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 1,
              child: OneKeepBouncingCard(
                onTap: onThemeTap,
                child: _BentoBlock(
                  height: 180,
                  gradient: isLightMode 
                      ? const LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]) 
                      : const LinearGradient(colors: [Color(0xFF312E81), Color(0xFF1E1B4B)]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        isLightMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                        size: 36,
                        color: isLightMode ? const Color(0xFFD97706) : const Color(0xFFA5B4FC),
                      ),
                      Text(
                        isLightMode ? '浅色外观\n明亮活跃' : '深色外观\n护眼模式',
                        style: TextStyle(
                          color: isLightMode ? const Color(0xFF92400E) : const Color(0xFFE0E7FF),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  OneKeepBouncingCard(
                    onTap: onCategoryTap,
                    child: _BentoBlock(
                      height: 82,
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.category_rounded, color: AppColors.teal, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('分类管理', style: _bentoTitleStyle(isDark)),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OneKeepBouncingCard(
                    onTap: onBackgroundTap,
                    child: _BentoBlock(
                      height: 82,
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.wallpaper_rounded, color: Color(0xFF8B5CF6), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text('卡片背景', style: _bentoTitleStyle(isDark)),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OneKeepBouncingCard(
                onTap: () {},
                child: _BentoBlock(
                  height: 64,
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.help_outline_rounded, color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93), size: 20),
                      const SizedBox(width: 8),
                      Text('帮助反馈', style: _bentoSubtitleStyle(isDark)),
                    ],
                  )
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OneKeepBouncingCard(
                onTap: () {},
                child: _BentoBlock(
                  height: 64,
                  color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline_rounded, color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93), size: 20),
                      const SizedBox(width: 8),
                      Text('关于系统', style: _bentoSubtitleStyle(isDark)),
                    ],
                  )
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  TextStyle _bentoTitleStyle(bool isDark) {
    return TextStyle(
      color: isDark ? Colors.white : const Color(0xFF1D1D1F),
      fontSize: 15,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle _bentoSubtitleStyle(bool isDark) {
    return TextStyle(
      color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
  }
}

class _BentoBlock extends StatelessWidget {
  final Widget child;
  final double height;
  final Color? color;
  final Gradient? gradient;

  const _BentoBlock({
    required this.child,
    required this.height,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          if (color != null)
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x06000000),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
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
