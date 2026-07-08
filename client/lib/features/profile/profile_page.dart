import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import 'category_settings_page.dart';
import '../../core/providers/api_provider.dart';
import '../../core/network/api_client.dart';
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

const _defaultAvatarAsset = 'assets/images/default-avatar.png';
const _profileBackgroundPresetAssets = <String>[
  'assets/images/profile-bg-1.png',
  'assets/images/profile-bg-2.png',
  'assets/images/profile-bg-3.png',
  'assets/images/profile-bg-4.png',
  'assets/images/profile-bg-5.png',
  'assets/images/profile-bg-6.png',
];

int _stableProfileSeed(AuthState authState) {
  final user = authState.user;
  final source = [
    user?.id,
    user?.email,
    user?.username,
    user?.name,
  ].whereType<String>().where((value) => value.isNotEmpty).join('|');
  final text = source.isEmpty ? 'one-keep-default-profile' : source;
  var hash = 0;
  for (final codeUnit in text.codeUnits) {
    hash = (hash * 31 + codeUnit) & 0x7fffffff;
  }
  return hash;
}

class _DefaultProfileBackground extends StatelessWidget {
  final int index;
  final bool isDark;

  const _DefaultProfileBackground({required this.index, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final asset =
        _profileBackgroundPresetAssets[index %
            _profileBackgroundPresetAssets.length];
    return Image.asset(asset, fit: BoxFit.cover, alignment: Alignment.center);
  }
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;
  Uint8List? _backgroundBytes;
  Uint8List? _avatarBytes;
  String? _lastBgData;
  String? _lastAvatarData;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(statsProvider.notifier).load());
  }

  void _onScroll() {
    if (mounted) {
      setState(() {
        _scrollOffset = _scrollController.offset.clamp(0.0, 180.0);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
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
              : '厘清用户');
    final profileSeed = _stableProfileSeed(authState);
    final defaultBackgroundIndex =
        profileSeed % _profileBackgroundPresetAssets.length;
    final totalExpense = statsOverview?.totalExpense ?? 0;
    final totalIncome = statsOverview?.totalIncome ?? 0;
    final balance = totalIncome - totalExpense;

    final backgroundImageData = preferences.profileBackgroundImageData;
    if (backgroundImageData != _lastBgData) {
      _lastBgData = backgroundImageData;
      if (backgroundImageData != null && backgroundImageData.isNotEmpty) {
        try {
          final normalized = backgroundImageData.contains(',')
              ? backgroundImageData.substring(
                  backgroundImageData.indexOf(',') + 1,
                )
              : backgroundImageData;
          _backgroundBytes = base64Decode(normalized);
        } catch (_) {
          _backgroundBytes = null;
        }
      } else {
        _backgroundBytes = null;
      }
    }

    final avatarImageData = preferences.avatarImageData;
    if (avatarImageData != _lastAvatarData) {
      _lastAvatarData = avatarImageData;
      if (avatarImageData != null && avatarImageData.isNotEmpty) {
        try {
          final normalized = avatarImageData.contains(',')
              ? avatarImageData.substring(avatarImageData.indexOf(',') + 1)
              : avatarImageData;
          _avatarBytes = base64Decode(normalized);
        } catch (_) {
          _avatarBytes = null;
        }
      } else {
        _avatarBytes = null;
      }
    }

    final t = (_scrollOffset / 150.0).clamp(0.0, 1.0);
    final topPadding = MediaQuery.of(context).padding.top;
    final bgHeight = 320.0 + topPadding;
    const baseAvatarSize = 88.0;
    const minAvatarSize = 54.0;
    final avatarSize = baseAvatarSize - (baseAvatarSize - minAvatarSize) * t;
    final fontSize = 28.0 - 8.0 * t;
    final profileBlockOffsetY = 6.0 * (1 - t);
    final actualScrollOffset = _scrollController.hasClients
        ? _scrollController.offset.clamp(0.0, double.infinity)
        : 0.0;
    final avatarTop = (bgHeight - avatarSize - 44 - actualScrollOffset).clamp(
      topPadding + 20.0,
      double.infinity,
    );

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF2F2F7),
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeroSection(
                  t: t,
                  isDark: isDark,
                  defaultBackgroundIndex: defaultBackgroundIndex,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Placeholder shortened to match overlay offset (-25px)
                      Transform.translate(
                        offset: const Offset(0, -21),
                        child: Opacity(
                          opacity: 0,
                          child: _buildFinanceOverview(
                            isDark: isDark,
                            totalExpense: totalExpense,
                            totalIncome: totalIncome,
                            balance: balance,
                            isLoading:
                                statsState.isLoading && statsOverview == null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 0),
                      _BentoGridMenu(
                        preferences: preferences,
                        onThemeTap: () {
                          final newMode =
                              preferences.themeMode == ThemeMode.dark
                              ? ThemeMode.light
                              : ThemeMode.dark;
                          ref
                              .read(preferencesProvider.notifier)
                              .setThemeMode(newMode);
                        },
                        onBackgroundTap: _showBackgroundStudio,
                        onCategoryTap: _openCategorySettings,
                        onAccountTap: _showAccountSheet,
                      ),
                      const SizedBox(height: 28),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // ── Finance Card overlay ───────────────
          Positioned(
            top: bgHeight - 25 - actualScrollOffset + 4,
            left: 16,
            right: 16,
            child: IgnorePointer(
              child: _buildFinanceOverview(
                isDark: isDark,
                totalExpense: totalExpense,
                totalIncome: totalIncome,
                balance: balance,
                isLoading: statsState.isLoading && statsOverview == null,
              ),
            ),
          ),
          // ── Avatar & Nickname (fixed overlay, never enters status bar) ──
          Positioned(
            top: avatarTop,
            left: 16,
            right: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                            color: Colors.black.withValues(
                              alpha: (0.25 * (1 - t * 0.5)).clamp(0, 0.25),
                            ),
                            blurRadius: 25 * (1 - t * 0.3),
                            offset: Offset(0, 12 * (1 - t * 0.5)),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.9),
                          width: (3.5 - 1.5 * t).clamp(1.0, 3.5),
                        ),
                      ),
                      child: ClipOval(
                        child: _avatarBytes != null
                            ? Image.memory(_avatarBytes!, fit: BoxFit.cover)
                            : Image.asset(
                                _defaultAvatarAsset,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: (20 - 4 * t).clamp(12.0, 20.0)),
                Expanded(
                  child: SizedBox(
                    height: avatarSize,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Transform.translate(
                        offset: Offset(0, profileBlockOffsetY),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            OneKeepBouncingCard(
                              onTap: _showNicknameSheet,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      displayName,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.8,
                                        height: 1.1,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: (0.3 * (1 - t)).clamp(
                                                0,
                                                0.3,
                                              ),
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
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

  Widget _buildFinanceOverview({
    required bool isDark,
    required double totalExpense,
    required double totalIncome,
    required double balance,
    required bool isLoading,
  }) {
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subTextColor = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF8E8E93);
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 余额行
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  isLoading ? '--' : '¥${oneKeepCurrency(balance)}',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    height: 1.0,
                  ),
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(
                    alpha: isDark ? 0.12 : 0.08,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.emerald,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 分隔线
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // 支出 / 收入
          Row(
            children: [
              Expanded(
                child: _FinanceMiniItem(
                  label: '本月支出',
                  amount: totalExpense,
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.expense,
                  isLoading: isLoading,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _FinanceMiniItem(
                  label: '本月收入',
                  amount: totalIncome,
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.emerald,
                  isLoading: isLoading,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection({
    required double t,
    required bool isDark,
    required int defaultBackgroundIndex,
  }) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bgHeight = 320.0 + topPadding;
    return SizedBox(
      width: double.infinity,
      height: bgHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Background ────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: bgHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_backgroundBytes != null)
                  Image.memory(_backgroundBytes!, fit: BoxFit.cover)
                else
                  _DefaultProfileBackground(
                    index: defaultBackgroundIndex,
                    isDark: isDark,
                  ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Avatar & Nickname (anchored near bottom of background) ──
          // ── Finance Card (overlaps bottom of background) ──────────
        ],
      ),
    );
  }

  Future<void> _showAvatarStudio() async {
    final preferences = ref.read(preferencesProvider);
    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      builder: (_) => _AvatarStudioSheet(
        avatarIndex: preferences.avatarIndex,
        avatarImageData: preferences.avatarImageData,
        onSelectImage: (bytes) {
          final base64Str = base64Encode(bytes);
          ref.read(preferencesProvider.notifier).setAvatarImageData(base64Str);
        },
      ),
    );
  }

  Future<void> _showBackgroundStudio() async {
    final preferences = ref.read(preferencesProvider);
    await _showProfileRootSheet<void>(
      builder: (_) => _BackgroundStudioSheet(
        imageData: preferences.profileBackgroundImageData,
        onSelectImage: (bytes) {
          final base64Str = base64Encode(bytes);
          ref
              .read(preferencesProvider.notifier)
              .setProfileBackgroundImageData(base64Str);
        },
        onClear: () {
          ref
              .read(preferencesProvider.notifier)
              .clearProfileBackgroundImageData();
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

  Future<void> _deleteAccount() async {
    HapticFeedback.heavyImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '确认注销',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: oneKeepTextPrimary(ctx),
          ),
        ),
        content: Text(
          '注销后，您的所有数据（交易记录、分类、个人设置）将被永久删除且无法恢复。\n\n确定要注销账号吗？',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: oneKeepTextSecondary(ctx),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              '取消',
              style: TextStyle(color: oneKeepTextSecondary(ctx)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              '确认注销',
              style: const TextStyle(
                color: Color(0xFFFF3B30),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(apiClientProvider).dio.delete('/api/auth/account');
      if (!mounted) return;
      ref.read(authProvider.notifier).logout();
      if (!mounted) return;
      showOneKeepToast(
        context,
        message: '账号已注销',
        type: OneKeepToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      showOneKeepToast(
        context,
        message: '注销失败：${ApiClient.readableError(e)}',
        type: OneKeepToastType.error,
      );
    }
  }

  Future<void> _showAccountSheet() async {
    await _showProfileRootSheet<void>(
      builder: (sheetContext) => _AccountActionsSheet(
        onLogout: () {
          Navigator.of(sheetContext).pop();
          ref.read(authProvider.notifier).logout();
        },
        onDeleteAccount: () {
          Navigator.of(sheetContext).pop();
          _deleteAccount();
        },
      ),
    );
  }

  Future<T?> _showProfileRootSheet<T>({required WidgetBuilder builder}) {
    return showGeneralDialog<T>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(dialogContext).pop(),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: builder(dialogContext),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.16),
              end: Offset.zero,
            ).animate(curved),
            child: child,
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
    final cardBg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final subBg = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF4F4F8);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.16)
                : Colors.black.withValues(alpha: 0.025),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── 余额主区域 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: _AdaptiveMoneyText(
                    value: isLoading ? '--' : '¥${oneKeepCurrency(balance)}',
                    color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                    maxFontSize: 36,
                    minFontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                    height: 1.0,
                  ),
                ),
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(
                      alpha: isDark ? 0.15 : 0.1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.emerald,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
          // ── 支出/收入分割行 ──
          Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              color: subBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                // 支出
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '本月支出',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF8E8E93),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.expense.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              size: 13,
                              color: AppColors.expense,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _AdaptiveMoneyText(
                              value: isLoading
                                  ? '--'
                                  : '¥${oneKeepCurrency(expense)}',
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1D1D1F),
                              maxFontSize: 16,
                              minFontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // 分割线
                Container(
                  width: 1,
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // 收入
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '本月收入',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFF8E8E93)
                              : const Color(0xFF8E8E93),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.emerald.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(
                              Icons.arrow_downward_rounded,
                              size: 13,
                              color: AppColors.emerald,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _AdaptiveMoneyText(
                              value: isLoading
                                  ? '--'
                                  : '¥${oneKeepCurrency(income)}',
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1D1D1F),
                              maxFontSize: 16,
                              minFontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptiveMoneyText extends StatelessWidget {
  final String value;
  final Color color;
  final double maxFontSize;
  final double minFontSize;
  final FontWeight fontWeight;
  final double letterSpacing;
  final double? height;

  const _AdaptiveMoneyText({
    required this.value,
    required this.color,
    required this.maxFontSize,
    required this.minFontSize,
    required this.fontWeight,
    required this.letterSpacing,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = _resolveFontSize(
          context,
          maxWidth: constraints.maxWidth,
        );
        final style = TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
          height: height,
        );

        return SizedBox(
          width: double.infinity,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: style,
            ),
          ),
        );
      },
    );
  }

  double _resolveFontSize(BuildContext context, {required double maxWidth}) {
    if (maxWidth <= 0 || value.length <= 3) return maxFontSize;
    for (var size = maxFontSize; size >= minFontSize; size -= 1) {
      final painter = TextPainter(
        text: TextSpan(
          text: value,
          style: TextStyle(
            fontSize: size,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            height: height,
          ),
        ),
        maxLines: 1,
        textDirection: Directionality.of(context),
      )..layout(maxWidth: double.infinity);
      if (painter.width <= maxWidth) return size;
    }
    return minFontSize;
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
                color: isDark
                    ? const Color(0xFFA1A1AA)
                    : const Color(0xFF8E8E93),
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

class _FinanceMiniItem extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final bool isDark;

  const _FinanceMiniItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF8E8E93)
                        : const Color(0xFF8E8E93),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isLoading ? '--' : '¥${oneKeepCurrency(amount)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1D1D1F),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoGridMenu extends StatelessWidget {
  final dynamic preferences;
  final VoidCallback onThemeTap;
  final VoidCallback onBackgroundTap;
  final VoidCallback onCategoryTap;
  final VoidCallback onAccountTap;

  const _BentoGridMenu({
    required this.preferences,
    required this.onThemeTap,
    required this.onBackgroundTap,
    required this.onCategoryTap,
    required this.onAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLightMode = preferences.themeMode == ThemeMode.light;

    return Column(
      children: [
        _BentoMenuItem(
          title: '头部背景',
          icon: Icons.style_rounded,
          iconColor: const Color(0xFF8B5CF6),
          isDark: isDark,
          onTap: onBackgroundTap,
          titleStyle: _bentoTitleStyle(isDark),
        ),
        const SizedBox(height: 12),
        _BentoMenuItem(
          title: '深色模式',
          icon: isLightMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
          iconColor: isLightMode
              ? const Color(0xFFF59E0B)
              : const Color(0xFF6366F1),
          isDark: isDark,
          onTap: onThemeTap,
          titleStyle: _bentoTitleStyle(isDark),
        ),
        const SizedBox(height: 12),
        _BentoMenuItem(
          title: '分类管理',
          icon: Icons.grid_view_rounded,
          iconColor: AppColors.teal,
          isDark: isDark,
          onTap: onCategoryTap,
          titleStyle: _bentoTitleStyle(isDark),
        ),
        const SizedBox(height: 12),
        _BentoMenuItem(
          title: '账号管理',
          icon: Icons.manage_accounts_rounded,
          iconColor: const Color(0xFFFF3B30),
          isDark: isDark,
          onTap: onAccountTap,
          titleStyle: _bentoTitleStyle(isDark),
        ),
        const SizedBox(height: 12),
        _BentoMenuItem(
          title: '关于系统',
          icon: Icons.info_outline_rounded,
          iconColor: const Color(0xFF6B7280),
          isDark: isDark,
          onTap: () => context.push('/about'),
          titleStyle: _bentoTitleStyle(isDark),
        ),
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
      color: isDark
          ? const Color(0xFF8E8E93).withValues(alpha: 0.6)
          : const Color(0xFF8E8E93),
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

class _BentoMenuItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool isDark;
  final VoidCallback onTap;
  final TextStyle titleStyle;

  const _BentoMenuItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.isDark,
    required this.onTap,
    required this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return OneKeepBouncingCard(
      onTap: onTap,
      child: _BentoBlock(
        height: 66,
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: titleStyle)),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: isDark ? const Color(0xFF48484A) : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoBlock extends StatelessWidget {
  final Widget child;
  final double height;
  final Color? color;

  const _BentoBlock({required this.child, required this.height, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: height,
      padding: EdgeInsets.all(height <= 80 ? 14 : 20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(height <= 80 ? 20 : 28),
        boxShadow: [
          if (color != null)
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );
  }
}

class _AccountActionsSheet extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;

  const _AccountActionsSheet({
    required this.onLogout,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OneKeepGlassSheet(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF3C3C3E)
                      : const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '账号管理',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF18181B),
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.power_settings_new_rounded,
                    label: '退出登录',
                    color: const Color(0xFFFF3B30),
                    onTap: onLogout,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.delete_outline_rounded,
                    label: '注销账号',
                    color: const Color(0xFFDC2626),
                    onTap: onDeleteAccount,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 昵称编辑弹窗
class _NicknameSheet extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSave;

  const _NicknameSheet({required this.controller, required this.onSave});

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
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: isDark
                            ? const Color(0xFF8E8E93)
                            : const Color(0xFF6B7280),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
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
                    color: isDark
                        ? const Color(0xFF8E8E93)
                        : const Color(0xFF9CA3AF),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2C2C2E)
                      : const Color(0xFFF3F4F6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarStudioSheet extends ConsumerWidget {
  final int avatarIndex;
  final String? avatarImageData;
  final ValueChanged<Uint8List> onSelectImage;

  const _AvatarStudioSheet({
    required this.avatarIndex,
    required this.avatarImageData,
    required this.onSelectImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(preferencesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCustomImage =
        preferences.avatarImageData != null &&
        preferences.avatarImageData!.isNotEmpty;

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
                color: isDark
                    ? const Color(0xFF3C3C3E)
                    : const Color(0xFFD1D5DB),
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
                    color: (hasCustomImage ? Colors.white : AppColors.teal)
                        .withValues(alpha: isDark ? 0.16 : 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: hasCustomImage
                    ? Image.memory(
                        base64Decode(
                          preferences.avatarImageData!.contains(',')
                              ? preferences.avatarImageData!.substring(
                                  preferences.avatarImageData!.indexOf(',') + 1,
                                )
                              : preferences.avatarImageData!,
                        ),
                        fit: BoxFit.cover,
                      )
                    : Image.asset(_defaultAvatarAsset, fit: BoxFit.cover),
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
            const SizedBox(height: 28),
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
                        await ref
                            .read(preferencesProvider.notifier)
                            .clearAvatarImageData();
                        if (context.mounted) {
                          showOneKeepToast(
                            context,
                            message: '已恢复默认头像',
                            type: OneKeepToastType.success,
                          );
                          Navigator.of(context).pop();
                        }
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
      final normalized = data.contains(',')
          ? data.substring(data.indexOf(',') + 1)
          : data;
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
                color: isDark
                    ? const Color(0xFF3C3C3E)
                    : const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),
            // 沉浸式标题
            Text(
              '更换头部背景',
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Image
                    if (previewBytes != null)
                      Image.memory(
                        previewBytes,
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      )
                    else
                      Image.asset(
                        _profileBackgroundPresetAssets.first,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),

                    // Mock Gradient for Text Readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.black.withValues(alpha: 0.26),
                            Colors.black.withValues(alpha: 0.48),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 22,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.85),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.20),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                _defaultAvatarAsset,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              '厘清用户',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
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
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '预设背景',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFA1A1AA)
                      : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _profileBackgroundPresetAssets.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final asset = _profileBackgroundPresetAssets[index];
                  return OneKeepBouncingCard(
                    onTap: () async {
                      final data = await rootBundle.load(asset);
                      onSelectImage(
                        data.buffer.asUint8List(
                          data.offsetInBytes,
                          data.lengthInBytes,
                        ),
                      );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                    child: Container(
                      width: 112,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(asset, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 28),
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
                        await ref
                            .read(preferencesProvider.notifier)
                            .clearProfileBackgroundImageData();
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
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
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
                color: isDark
                    ? Colors.white.withValues(alpha: 0.95)
                    : const Color(0xFF18181B),
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
          child: SafeArea(top: false, child: child),
        ),
      ),
    );
  }
}

class _ProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double totalExpense;
  final double totalIncome;
  final double balance;
  final bool isLoading;
  final PreferencesState preferences;
  final AuthState authState;
  final bool isDark;
  final String displayName;
  final String username;
  final VoidCallback onAvatarTap;
  final VoidCallback onNicknameTap;
  final BuildContext context;
  final Uint8List? backgroundBytes;
  final Uint8List? avatarBytes;

  _ProfileHeaderDelegate({
    required this.totalExpense,
    required this.totalIncome,
    required this.balance,
    required this.isLoading,
    required this.preferences,
    required this.authState,
    required this.isDark,
    required this.displayName,
    required this.username,
    required this.onAvatarTap,
    required this.onNicknameTap,
    required this.context,
    this.backgroundBytes,
    this.avatarBytes,
  });

  @override
  double get maxExtent => 500.0; // background(280) + card(~220)

  @override
  double get minExtent => 140.0;

  @override
  bool shouldRebuild(covariant _ProfileHeaderDelegate oldDelegate) => true;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    // Layout Metrics
    const baseAvatarSize = 88.0;
    const minAvatarSize = 54.0;
    final currentAvatarSize =
        baseAvatarSize - (baseAvatarSize - minAvatarSize) * t;

    const baseFontSize = 28.0;
    const minFontSize = 20.0;
    final currentFontSize = baseFontSize - (baseFontSize - minFontSize) * t;

    final profileSeed = _stableProfileSeed(authState);
    final defaultBackgroundIndex =
        profileSeed % _profileBackgroundPresetAssets.length;

    // The visible header height shrinks from maxExtent(500) to minExtent(140).
    // The BACKGROUND is always anchored at top=0, height=280.
    // Avatar is vertically centered in the 280px background area.
    // Card is at top=256, overlapping the bottom of the background.
    const bgHeight = 280.0;
    // Avatar row height ~88px at t=0, ~54px at t=1
    // Center of avatar row in background: top = (bgHeight - avatarSize) / 2
    final avatarTop = (bgHeight - currentAvatarSize) / 2;

    return Stack(
      children: [
        // ── Background: fixed 280px at top ──────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: bgHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (backgroundBytes != null)
                Image.memory(backgroundBytes!, fit: BoxFit.cover)
              else
                _DefaultProfileBackground(
                  index: defaultBackgroundIndex,
                  isDark: isDark,
                ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.0),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Avatar & Nickname: centered inside background ────────────
        Positioned(
          top: avatarTop,
          left: 20,
          right: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OneKeepBouncingCard(
                onTap: onAvatarTap,
                child: Hero(
                  tag: 'profile_avatar',
                  child: Container(
                    width: currentAvatarSize,
                    height: currentAvatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: (0.25 * (1 - t * 0.5)).clamp(0.0, 0.25),
                          ),
                          blurRadius: 25 * (1 - t * 0.3),
                          offset: Offset(0, 12 * (1 - t * 0.5)),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.9),
                        width: (3.5 - (1.5 * t)).clamp(1.0, 3.5),
                      ),
                    ),
                    child: ClipOval(
                      child: avatarBytes != null
                          ? Image.memory(avatarBytes!, fit: BoxFit.cover)
                          : (preferences.avatarImageData != null &&
                                preferences.avatarImageData!.isNotEmpty)
                          ? const SizedBox.shrink()
                          : Image.asset(_defaultAvatarAsset, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              SizedBox(width: (20 - (4 * t)).clamp(12.0, 20.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OneKeepBouncingCard(
                      onTap: onNicknameTap,
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: currentFontSize,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.8,
                                height: 1.1,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(
                                      alpha: (0.3 * (1 - t)).clamp(0.0, 0.3),
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Finance card sits on top of background, inside the Stack
        Positioned(
          top: 256, // backgroundHeight(280) - 24 overlap
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
    );
  }
}
