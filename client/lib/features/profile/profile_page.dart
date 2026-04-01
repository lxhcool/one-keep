import 'dart:convert';
import 'dart:ui';

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
          SliverToBoxAdapter(
            child: _buildProfileHero(
              totalExpense: totalExpense,
              totalIncome: totalIncome,
              balance: balance,
              isLoading: statsState.isLoading && statsOverview == null,
              preferences: preferences,
              authState: authState,
              isDark: isDark,
              displayName: displayName,
              username: username,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x06000000),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.power_settings_new_rounded,
                            size: 20,
                            color: const Color(0xFFFF3B30).withValues(alpha: 0.8),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '退出当前账号',
                            style: TextStyle(
                              color: const Color(0xFFFF3B30),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 140),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHero({
    required double totalExpense,
    required double totalIncome,
    required double balance,
    required bool isLoading,
    required PreferencesState preferences,
    required AuthState authState,
    required bool isDark,
    required String displayName,
    required String username,
  }) {
    final topInset = MediaQuery.paddingOf(context).top;
    final backgroundImageData = preferences.profileBackgroundImageData;
    final hasBackground = backgroundImageData != null && backgroundImageData.isNotEmpty;
    
    // Layout Metrics (Mirroring home_page.dart layout strategy)
    final backgroundHeight = 280.0; 
    final avatarSize = 88.0;
    
    // Placing the Finance Card overlapping the background natively
    final balanceCardTop = backgroundHeight - 24.0; 
    // Card intrinsic height + overlay clearance + bottom spacing
    final heroHeight = balanceCardTop + 240.0 + 32.0; 

    return SizedBox(
      height: heroHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: backgroundHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasBackground)
                  Image.memory(
                    base64Decode(backgroundImageData!.contains(',')
                        ? backgroundImageData.substring(backgroundImageData.indexOf(',') + 1)
                        : backgroundImageData),
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
                        if (hasBackground) Colors.black.withValues(alpha: 0.0) else Colors.transparent,
                        if (hasBackground) Colors.black.withValues(alpha: 0.6) 
                        else (isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7)),
                      ],
                      stops: hasBackground ? const [0.4, 1.0] : null,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Avatar & User Info Layer
          Positioned(
            left: 20,
            bottom: heroHeight - backgroundHeight + 36, // Placed squarely inside background
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                OneKeepBouncingCard(
                  onTap: _showAvatarStudio,
                  child: Hero(
                    tag: 'profile_avatar',
                    child: Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 25,
                            offset: const Offset(0, 12),
                          ),
                          if (!isDark && !hasBackground)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                        ],
                        border: Border.all(
                          color: hasBackground 
                              ? Colors.white.withValues(alpha: 0.9)
                              : (isDark ? const Color(0xFF3C3C3E) : Colors.white),
                          width: 3.5,
                        ),
                      ),
                      child: ClipOval(
                        child: preferences.avatarImageData != null && preferences.avatarImageData!.isNotEmpty
                            ? Image.memory(
                                base64Decode(preferences.avatarImageData!.contains(',')
                                    ? preferences.avatarImageData!.substring(preferences.avatarImageData!.indexOf(',') + 1)
                                    : preferences.avatarImageData!),
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                                child: Center(
                                  child: Icon(
                                    oneKeepAvatarPresets[preferences.avatarIndex.clamp(0, oneKeepAvatarPresets.length - 1)].icon,
                                    size: avatarSize * 0.45,
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        OneKeepBouncingCard(
                          onTap: _showNicknameSheet,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayName,
                                  style: TextStyle(
                                    color: (hasBackground || isDark ? Colors.white : const Color(0xFF1C1C1E)),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.8,
                                    height: 1.1,
                                    shadows: [
                                      if (hasBackground)
                                        Shadow(
                                          color: Colors.black.withValues(alpha: 0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                size: 18,
                                color: AppColors.teal,
                              ),
                            ],
                          ),
                        ),
                        if (username.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: (hasBackground || isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: (hasBackground || isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                                ),
                              ),
                              child: Text(
                                '@$username',
                                style: TextStyle(
                                  color: (hasBackground || isDark ? Colors.white : const Color(0xFF1C1C1E)).withValues(alpha: 0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Finance Card Overlapping Layer (solves translation overlaps robustly!)
          Positioned(
            top: balanceCardTop,
            left: 20,
            right: 20,
            child: _FinanceDashboardCard(
              expense: totalExpense,
              income: totalIncome,
              balance: balance,
              isLoading: isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: isDark ? const Color(0xFF86868B) : const Color(0xFF86868B),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
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
      barrierColor: Colors.black.withValues(alpha: 0.25),
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
      barrierColor: Colors.black.withValues(alpha: 0.25),
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
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (context) => const CategorySettingsPage()),
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
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.5) : const Color(0x08000000),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '账户总余额',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 14,
                            color: isDark ? const Color(0xFF3C3C3E) : const Color(0xFFC7C7CC),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isLoading ? '--' : '¥${oneKeepCurrency(balance)}',
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF2C2C2E), const Color(0xFF1C1C1E)]
                          : [const Color(0xFFF2F2F7), Colors.white],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.teal,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E).withValues(alpha: 0.4) : const Color(0xFFF9F9FB),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _FinanceItemModern(
                      label: '本月支出',
                      amount: expense,
                      color: AppColors.expense,
                      isLoading: isLoading,
                      icon: Icons.arrow_upward_rounded,
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF3C3C3E) : const Color(0xFFE5E5EA),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  Expanded(
                    child: _FinanceItemModern(
                      label: '本月收入',
                      amount: income,
                      color: AppColors.income,
                      isLoading: isLoading,
                      icon: Icons.arrow_downward_rounded,
                      alignment: CrossAxisAlignment.end,
                    ),
                  ),
                ],
              ),
            ),
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
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFEF3C7), Color(0xFFFBBF24)],
                        )
                      : const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF3730A3), Color(0xFF1E1B4B)],
                        ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLightMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          size: 28,
                          color: isLightMode ? const Color(0xFFD97706) : const Color(0xFFA5B4FC),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLightMode ? '外观样式' : '主题外观',
                            style: TextStyle(
                              color: (isLightMode ? const Color(0xFF92400E) : const Color(0xFFE0E7FF)).withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLightMode ? '浅色外观\n明亮活跃' : '深色外观\n尊享护眼',
                            style: TextStyle(
                              color: isLightMode ? const Color(0xFF92400E) : const Color(0xFFE0E7FF),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.grid_view_rounded, color: AppColors.teal, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('分类管理', style: _bentoTitleStyle(isDark)),
                                const SizedBox(height: 2),
                                Text('编排图标', style: _bentoTipStyle(isDark)),
                              ],
                            ),
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
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.style_rounded, color: Color(0xFF8B5CF6), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('卡片背景', style: _bentoTitleStyle(isDark)),
                                const SizedBox(height: 2),
                                Text('个性皮肤', style: _bentoTipStyle(isDark)),
                              ],
                            ),
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
        const SizedBox(width: 18),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            children: [
              Expanded(
                child: OneKeepBouncingCard(
                  onTap: () {},
                  child: _BentoBlock(
                    height: 68,
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.help_outline_rounded, color: Color(0xFF3B82F6), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text('帮助反馈', style: _bentoTitleStyle(isDark)),
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
                    height: 68,
                    color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6B7280).withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.info_outline_rounded, color: Color(0xFF6B7280), size: 18),
                        ),
                        const SizedBox(width: 12),
                        Text('关于系统', style: _bentoTitleStyle(isDark)),
                      ],
                    )
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  TextStyle _bentoTitleStyle(bool isDark) {
    return TextStyle(
      color: isDark ? Colors.white : const Color(0xFF1D1D1F),
      fontSize: 16,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
    );
  }

  TextStyle _bentoTipStyle(bool isDark) {
    return TextStyle(
      color: isDark ? const Color(0xFF8E8E93).withValues(alpha: 0.6) : const Color(0xFF8E8E93),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
  }

  TextStyle _bentoSubtitleStyle(bool isDark) {
    return TextStyle(
      color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF6B7280),
      fontSize: 14,
      fontWeight: FontWeight.w600,
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
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          if (color != null)
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
    final hasCustomImage = preferences.avatarImageData != null && preferences.avatarImageData!.isNotEmpty;

    return OneKeepGlassSheet(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 32),
            // 居中发光的当前头像
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (hasCustomImage ? Colors.white : AppColors.teal).withValues(alpha: isDark ? 0.3 : 0.15),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  )
                ],
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: hasCustomImage
                    ? Image.memory(
                        base64Decode(preferences.avatarImageData!.contains(',')
                            ? preferences.avatarImageData!.substring(preferences.avatarImageData!.indexOf(',') + 1)
                            : preferences.avatarImageData!),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                        child: Center(
                          child: Icon(
                            oneKeepAvatarPresets[preferences.avatarIndex.clamp(0, oneKeepAvatarPresets.length - 1)].icon,
                            size: 40,
                            color: AppColors.teal,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '你的形象，由你定义',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF18181B),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 32),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.photo_library_rounded,
                    label: '从相册选取',
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
                if (preferences.avatarImageData != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.layers_clear_rounded,
                      label: '重置为默认',
                      color: AppColors.expense,
                      onTap: () async {
                        await ref.read(preferencesProvider.notifier).clearAvatarImageData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已恢复默认头像')),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 32),
            // 预设头像矩阵
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '探索基础风格',
                style: TextStyle(
                  color: isDark ? const Color(0xFFA1A1AA) : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: oneKeepAvatarPresets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  final selected = preferences.avatarImageData == null && preferences.avatarIndex == index;
                  return OneKeepBouncingCard(
                    onTap: () {
                      onSelectPreset(index);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutBack,
                      width: 72,
                      decoration: BoxDecoration(
                        color: selected 
                            ? const Color(0xFF2563EB).withValues(alpha: isDark ? 0.2 : 0.1) 
                            : (isDark ? const Color(0xFF2C2C2E).withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? const Color(0xFF2563EB) : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: AnimatedScale(
                          scale: selected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            oneKeepAvatarPresets[index].icon,
                            size: 28,
                            color: selected ? const Color(0xFF2563EB) : AppColors.teal.withValues(alpha: 0.8),
                          ),
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

    return OneKeepGlassSheet(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
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
            const SizedBox(height: 32),
            // 沉浸式标题
            Text(
              '更换背景图片',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF18181B),
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            // 沉浸式实景小预览区域
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    if (previewBytes != null)
                      Image.memory(previewBytes, fit: BoxFit.cover, alignment: Alignment.topCenter)
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
                      
                    // Mock Gradient for Text Readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          stops: const [0.3, 1.0],
                        ),
                      ),
                    ),

                    // Mini Avatar & Name
                    Positioned(
                      left: 20, bottom: 24, right: 20,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                              ],
                            ),
                            child: ClipOval(
                              child: preferences.avatarImageData != null && preferences.avatarImageData!.isNotEmpty
                                ? Image.memory(
                                    base64Decode(preferences.avatarImageData!.contains(',')
                                        ? preferences.avatarImageData!.substring(preferences.avatarImageData!.indexOf(',') + 1)
                                        : preferences.avatarImageData!),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                                    child: Center(
                                      child: Icon(
                                        oneKeepAvatarPresets[preferences.avatarIndex.clamp(0, oneKeepAvatarPresets.length - 1)].icon,
                                        size: 20,
                                        color: AppColors.teal,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                preferences.nickname.isNotEmpty ? preferences.nickname : 'OneKeep User',
                                style: const TextStyle(
                                  color: Colors.white, 
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // 操作按钮
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.panorama_outlined,
                    label: '从相册选取',
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
                if (preferences.profileBackgroundImageData != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.layers_clear_rounded,
                      label: '恢复极简纯净',
                      color: AppColors.expense,
                      onTap: () async {
                        await ref.read(preferencesProvider.notifier).clearProfileBackgroundImageData();
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
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

    return OneKeepBouncingCard(
      onTap: onTap,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.95) : const Color(0xFF18181B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 高级玻璃拟物风底部弹窗容器
class OneKeepGlassSheet extends StatelessWidget {
  final Widget child;

  const OneKeepGlassSheet({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF1C1C1E).withValues(alpha: 0.75) 
                : Colors.white.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.6),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: child,
          ),
        ),
      ),
    );
  }
}

