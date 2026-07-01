import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/network/api_client.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/providers/preferences_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/onekeep_ui.dart';
import '../../shared/widgets/transaction_editor_sheet.dart';

// Nordic Emerald Theme Constants
const _nordicHeroTop = Color(0xFF065F46); // Emerald 800
const _nordicHeroMid = Color(0xFF047857); // Emerald 700
const _nordicHeroBottom = Color(0xFF059669); // Emerald 600

const _nordicDarkHeroTop = Color(0xFF064E3B);
const _nordicDarkHeroMid = Color(0xFF0D1111);
const _nordicDarkHeroBottom = Color(0xFF0D1111);

class _HomePalette {
  final Color scaffoldBackground;
  final SystemUiOverlayStyle overlayStyle;
  final List<Color> heroGradient;
  final Color heroGlowPrimary;
  final Color heroGlowSecondary;
  final Color heroGreetingText;
  final Color heroNameText;
  final Color heroActionBackground;
  final Color heroActionBorder;
  final Color heroActionIcon;
  final List<Color> cardGradient;
  final Color cardGlow;
  final Color cardShadow;
  final Color listPrimaryText;
  final Color listSecondaryText;
  final Color listAccent;

  const _HomePalette({
    required this.scaffoldBackground,
    required this.overlayStyle,
    required this.heroGradient,
    required this.heroGlowPrimary,
    required this.heroGlowSecondary,
    required this.heroGreetingText,
    required this.heroNameText,
    required this.heroActionBackground,
    required this.heroActionBorder,
    required this.heroActionIcon,
    required this.cardGradient,
    required this.cardGlow,
    required this.cardShadow,
    required this.listPrimaryText,
    required this.listSecondaryText,
    required this.listAccent,
  });

  static _HomePalette of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return _HomePalette(
        scaffoldBackground: AppColors.darkBg,
        overlayStyle: SystemUiOverlayStyle.light,
        heroGradient: [_nordicDarkHeroTop, _nordicDarkHeroMid, _nordicDarkHeroBottom],
        heroGlowPrimary: AppColors.emerald.withValues(alpha: 0.15),
        heroGlowSecondary: AppColors.emerald.withValues(alpha: 0.1),
        heroGreetingText: AppColors.darkTextSecondary,
        heroNameText: AppColors.darkTextPrimary,
        heroActionBackground: Colors.white.withValues(alpha: 0.05),
        heroActionBorder: Colors.white.withValues(alpha: 0.1),
        heroActionIcon: AppColors.darkTextPrimary,
        cardGradient: [AppColors.darkBgSecondary, AppColors.darkSurface],
        cardGlow: AppColors.emerald.withValues(alpha: 0.1),
        cardShadow: Colors.black.withValues(alpha: 0.4),
        listPrimaryText: AppColors.darkTextPrimary,
        listSecondaryText: AppColors.darkTextSecondary,
        listAccent: AppColors.emerald,
      );
    }

    return _HomePalette(
      scaffoldBackground: AppColors.lightBg,
      overlayStyle: SystemUiOverlayStyle.light, // Keep status bar light on dark header
      heroGradient: [_nordicHeroTop, _nordicHeroMid, _nordicHeroBottom],
      heroGlowPrimary: Colors.white.withValues(alpha: 0.1),
      heroGlowSecondary: Colors.white.withValues(alpha: 0.05),
      heroGreetingText: Colors.white.withValues(alpha: 0.7),
      heroNameText: Colors.white,
      heroActionBackground: Colors.white.withValues(alpha: 0.15),
      heroActionBorder: Colors.white.withValues(alpha: 0.2),
      heroActionIcon: Colors.white,
      cardGradient: [AppColors.emerald, Color(0xFF047857)],
      cardGlow: Colors.white.withValues(alpha: 0.15),
      cardShadow: AppColors.emerald.withValues(alpha: 0.25),
      listPrimaryText: AppColors.lightTextPrimary,
      listSecondaryText: AppColors.lightTextSecondary,
      listAccent: AppColors.emerald,
    );
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _balanceVisible = true;
  bool _hasTriggeredInitialLoad = false;
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (mounted) setState(() => _scrollOffset = _scrollController.offset);
    });
    Future.microtask(_loadIfAuthenticated);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadIfAuthenticated() async {
    if (!mounted || _hasTriggeredInitialLoad) return;
    if (ref.read(authProvider).status != AuthStatus.authenticated) return;

    _hasTriggeredInitialLoad = true;
    await ref.read(homeProvider.notifier).load();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '凌晨好';
    if (hour < 12) return '早上好';
    if (hour < 18) return '下午好';
    return '晚上好';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final authState = ref.watch(authProvider);
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!mounted) return;

      final becameAuthenticated =
          previous?.status != AuthStatus.authenticated &&
          next.status == AuthStatus.authenticated;
      if (becameAuthenticated) {
        _hasTriggeredInitialLoad = true;
        ref.read(homeProvider.notifier).load();
      }

      if (next.status == AuthStatus.unauthenticated) {
        _hasTriggeredInitialLoad = false;
      }
    });
    final preferences = ref.watch(preferencesProvider);
    final categories = ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    final categoryColors = <String, String?>{
      for (final item in categories) item.id: item.color,
    };
    final palette = _HomePalette.of(context);

    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: palette.overlayStyle,
        child: authState.status == AuthStatus.unknown
            ? const Center(child: CircularProgressIndicator())
            : state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.error != null
            ? Center(child: Text(state.error!))
            : RefreshIndicator(
                edgeOffset: MediaQuery.paddingOf(context).top + 12,
                onRefresh: () => ref.read(homeProvider.notifier).load(),
                child: Stack(
                  children: [
                    ListView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        _buildHeroSection(
                          state.summary,
                          authState.user?.name,
                          preferences,
                        ),
                        if (state.summary != null)
                          _buildContentSection(
                            state.summary!.recentTransactions,
                            categoryColors,
                          ),
                      ],
                    ),
                    // ── Sticky header ──
                    _buildStickyHeader(preferences, palette, state.summary),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStickyHeader(PreferencesState preferences, _HomePalette palette, HomeSummary? summary) {
    final topInset = MediaQuery.paddingOf(context).top;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // progress: 0 = not scrolled, 1 = fully compact
    final progress = (_scrollOffset / 100.0).clamp(0.0, 1.0);

    final userName = preferences.nickname.isNotEmpty
        ? preferences.nickname
        : (summary?.user.name.isNotEmpty == true
              ? summary!.user.name
              : '厘清用户');

    // Avatar: 54 → 36
    final avatarSize = 54.0 - 18.0 * progress;
    final iconSize = 24.0 - 8.0 * progress;
    // Content height: 78 → 48
    final contentHeight = 78.0 - 30.0 * progress;
    // Name font: 22 → 16
    final nameFontSize = 22.0 - 6.0 * progress;
    // Greeting opacity: fade out in first 40%
    final greetingOpacity = progress < 0.4 ? (1.0 - progress / 0.4).clamp(0.0, 1.0) : 0.0;
    // Greeting height factor
    final greetingHeight = progress < 0.5 ? (1.0 - progress / 0.5).clamp(0.0, 1.0) : 0.0;
    // Background opacity
    final bgOpacity = progress;
    // Blur
    final blur = 24.0 * progress;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 12),
            decoration: BoxDecoration(
              color: (isDark
                  ? const Color(0xFF0D1111)
                  : const Color(0xFF065F46))
                  .withValues(alpha: bgOpacity * 0.9),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.06 * progress),
                  width: 0.5,
                ),
              ),
            ),
            child: SizedBox(
              height: contentHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  OneKeepAvatar(
                    avatarIndex: preferences.avatarIndex,
                    avatarImageData: preferences.avatarImageData,
                    size: avatarSize,
                    iconSize: iconSize,
                  ),
                  SizedBox(width: 16.0 - 4.0 * progress),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting fades and shrinks
                        ClipRect(
                          child: Align(
                            alignment: Alignment.topLeft,
                            heightFactor: greetingHeight,
                            child: Opacity(
                              opacity: greetingOpacity,
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 6.0 * greetingHeight),
                                child: Text(
                                  _greeting(),
                                  style: oneKeepManrope(
                                    color: palette.heroGreetingText,
                                    size: 14,
                                    weight: FontWeight.w600,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Text(
                          userName,
                          style: oneKeepGrotesk(
                            color: Colors.white,
                            size: nameFontSize,
                            weight: FontWeight.w700,
                            height: 1,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    HomeSummary? summary,
    String? authUserName,
    PreferencesState preferences,
  ) {
    final palette = _HomePalette.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    const headerTopSpacing = 24.0;
    const avatarSize = 54.0;
    const balanceCardTopSpacing = 24.0;
    const balanceCardHeight = 196.0;
    const contentSpacing = 16.0;
    final balanceCardTop = topInset + headerTopSpacing + avatarSize + balanceCardTopSpacing;
    final heroHeight = balanceCardTop + balanceCardHeight + contentSpacing;
    final userName = preferences.nickname.isNotEmpty
        ? preferences.nickname
        : (summary?.user.name.isNotEmpty == true
              ? summary!.user.name
              : (authUserName?.isNotEmpty == true
                    ? authUserName!
                    : '厘清用户'));
    return SizedBox(
      height: heroHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: 400,
            child: ClipPath(
              clipper: _HeroFanClipper(),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: palette.heroGradient,
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    left: -100,
                    top: -120,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [palette.heroGlowPrimary, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -60,
                    top: 20,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            palette.heroGlowSecondary,
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(16, topInset + headerTopSpacing, 16, 0),
                      // Invisible spacer — actual header is in outer Stack overlay
                      child: SizedBox(height: avatarSize),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (summary != null)
            Positioned(
              left: 16,
              right: 16,
              top: balanceCardTop,
              child: SizedBox(
                height: balanceCardHeight,
                child: _buildHeroBalanceCard(summary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeroBalanceCard(HomeSummary summary) {
    final palette = _HomePalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: palette.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: palette.cardGradient,
                  ),
                ),
              ),
            ),
            Positioned(
              right: -54,
              top: -32,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [palette.cardGlow, Colors.transparent],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.12),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '本月结余',
                        style: oneKeepManrope(
                          color: Colors.white.withValues(alpha: 0.72),
                          size: 14,
                          weight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _balanceVisible = !_balanceVisible),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            _balanceVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 15,
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _balanceVisible
                        ? '¥ ${oneKeepCurrency(summary.balance)}'
                        : '¥ ********',
                    style: oneKeepGrotesk(
                      color: Colors.white,
                      size: 30,
                      weight: FontWeight.w700,
                      letterSpacing: _balanceVisible ? 0.6 : 1.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _BalanceInlineMetric(
                          label: '收入',
                          amount: summary.income,
                          icon: Icons.south_west_rounded,
                          visible: _balanceVisible,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BalanceInlineMetric(
                          label: '支出',
                          amount: summary.expense,
                          icon: Icons.north_east_rounded,
                          visible: _balanceVisible,
                          alignEnd: true,
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
    );
  }

  Widget _buildContentSection(
    List<Transaction> items,
    Map<String, String?> categoryColors,
  ) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        8,
        8,
        8,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: _buildRecentSection(items, categoryColors),
    );
  }

  Widget _buildRecentSection(
    List<Transaction> items,
    Map<String, String?> categoryColors,
  ) {
    final palette = _HomePalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: palette.listAccent,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '最近记账',
              style: oneKeepGrotesk(
                color: palette.listPrimaryText,
                size: 16,
                weight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.go('/bills'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '全部',
                      style: oneKeepManrope(
                        color: palette.listSecondaryText,
                        size: 12,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 14,
                      color: palette.listSecondaryText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: const Center(
              child: OneKeepEmptyState(
                icon: Icons.receipt_long_rounded,
                message: '快去记一笔吧',
              ),
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < items.length; i++)
                _HomeTransactionRow(
                  transaction: items[i],
                  categoryColor: categoryColors[items[i].categoryId] ?? items[i].categoryColor,
                  onTap: () => _showTransactionSheet(
                    items[i],
                    categoryColors[items[i].categoryId] ?? items[i].categoryColor,
                  ),
                  isEven: i.isEven,
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _showTransactionSheet(Transaction tx, String? categoryColor) async {
    final action = await showModalBottomSheet<_TransactionDetailAction>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // IMPORTANT for glass effect
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => _HomeTransactionDetailSheet(
        transaction: tx,
        categoryColor: categoryColor,
      ),
    );
    if (!mounted || action == null) return;

    if (action == _TransactionDetailAction.edit) {
      await _editTransaction(tx);
    } else if (action == _TransactionDetailAction.delete) {
      await _deleteTransaction(tx);
    }
  }

  Future<void> _editTransaction(Transaction tx) async {
    final draft = await showModalBottomSheet<TransactionEditDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => OneKeepTransactionEditorSheet(transaction: tx),
    );
    if (!mounted || draft == null) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.dio.put(
        '/api/transactions/${tx.transactionId}',
        data: draft.toJson(),
      );
      ref.read(homeProvider.notifier).load();
      ref.read(billsProvider.notifier).load();
      ref.read(statsProvider.notifier).load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('记账已更新')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiClient.readableError(error, fallback: '更新失败')),
        ),
      );
    }
  }

  Future<void> _deleteTransaction(Transaction tx) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: oneKeepSurface(dialogContext),
        title: Text(
          '删除这条记账？',
          style: oneKeepManrope(
            color: oneKeepTextPrimary(dialogContext),
            size: 18,
            weight: FontWeight.w700,
          ),
        ),
        content: Text(
          '删除后将无法恢复。',
          style: oneKeepInter(
            color: oneKeepTextSecondary(dialogContext),
            size: 13,
            weight: FontWeight.w400,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              '取消',
              style: oneKeepInter(
                color: oneKeepTextSecondary(dialogContext),
                size: 14,
                weight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              '删除',
              style: oneKeepInter(
                color: AppColors.rose,
                size: 14,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;

    try {
      final api = ref.read(apiClientProvider);
      await api.dio.delete(
        '/api/transactions/${tx.transactionId}',
        data: const <String, dynamic>{},
      );
      ref.read(homeProvider.notifier).load();
      ref.read(billsProvider.notifier).load();
      ref.read(statsProvider.notifier).load();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('记账已删除')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ApiClient.readableError(error, fallback: '删除失败')),
        ),
      );
    }
  }
}

enum _TransactionDetailAction { edit, delete }

class _HeroFanClipper extends CustomClipper<Path> {
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

class _BalanceInlineMetric extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final bool visible;
  final bool alignEnd;

  const _BalanceInlineMetric({
    required this.label,
    required this.amount,
    required this.icon,
    required this.visible,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisAlignment: alignEnd
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 11, color: Colors.white),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: oneKeepManrope(
                color: Colors.white.withValues(alpha: 0.72),
                size: 12,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          visible ? '¥ ${oneKeepCurrency(amount)}' : '¥ ****',
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: oneKeepGrotesk(
            color: Colors.white,
            size: 19,
            weight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _HomeTransactionRow extends StatelessWidget {
  final Transaction transaction;
  final String? categoryColor;
  final VoidCallback onTap;
  final bool isEven;

  const _HomeTransactionRow({
    required this.transaction,
    required this.categoryColor,
    required this.onTap,
    this.isEven = true,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final palette = _HomePalette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountColor = isExpense
        ? (isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE84545))
        : AppColors.emerald;
    final rowColor = isEven
        ? (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02))
        : Colors.transparent;

    return OneKeepBouncingCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: rowColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            OneKeepCategoryBadge(
              title: transaction.title,
              categoryName: transaction.categoryName,
              categoryIcon: transaction.categoryIcon,
              categoryId: transaction.categoryId,
              colorHex: categoryColor,
              size: 42,
              iconSize: 20,
              radius: 13,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: oneKeepManrope(
                      color: palette.listPrimaryText,
                      size: 15,
                      weight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${transaction.categoryName} · ${oneKeepDayTime(transaction.occurredAt)}',
                    style: oneKeepInter(
                      color: palette.listSecondaryText,
                      size: 11,
                      weight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${isExpense ? '-' : '+'}¥${oneKeepCurrency(transaction.amount)}',
              style: oneKeepGrotesk(
                color: amountColor,
                size: 16,
                weight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;
  final String? categoryColor;

  const _HomeTransactionDetailSheet({
    required this.transaction,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tone = transaction.isExpense ? AppColors.rose : AppColors.emerald;

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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      OneKeepCategoryBadge(
                        title: transaction.title,
                        categoryName: transaction.categoryName,
                        categoryIcon: transaction.categoryIcon,
                        categoryId: transaction.categoryId,
                        colorHex: categoryColor,
                        size: 48,
                        iconSize: 24,
                        radius: 14,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              transaction.title,
                              style: oneKeepManrope(
                                color: oneKeepTextPrimary(context),
                                size: 20,
                                weight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              transaction.categoryName,
                              style: oneKeepInter(
                                color: oneKeepTextSecondary(context),
                                size: 13,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${transaction.isExpense ? '-' : '+'}¥${oneKeepCurrency(transaction.amount)}',
                        style: oneKeepGrotesk(
                          color: tone,
                          size: 26,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  
                  // Detail Info Block
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: '交易日期',
                          value: oneKeepDayTime(transaction.occurredAt),
                          isDark: isDark,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, thickness: 0.5),
                        ),
                        _DetailRow(
                          label: '商家名称',
                          value: transaction.merchant ?? '暂无商家',
                          isDark: isDark,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Divider(height: 1, thickness: 0.5),
                        ),
                        _DetailRow(
                          label: '交易备注',
                          value: transaction.note ?? '暂无备注',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _SheetActionButton(
                          label: '编辑',
                          icon: LucideIcons.edit3,
                          tone: AppColors.emerald,
                          onTap: () => Navigator.of(context).pop(_TransactionDetailAction.edit),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SheetActionButton(
                          label: '删除',
                          icon: LucideIcons.trash2,
                          tone: AppColors.rose,
                          onTap: () => Navigator.of(context).pop(_TransactionDetailAction.delete),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _DetailRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: oneKeepInter(
            color: oneKeepTextSecondary(context),
            size: 13,
            weight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: oneKeepInter(
            color: oneKeepTextPrimary(context),
            size: 14,
            weight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SheetActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color tone;
  final VoidCallback onTap;

  const _SheetActionButton({
    required this.label,
    required this.icon,
    required this.tone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OneKeepBouncingCard(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: tone,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: tone.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: oneKeepManrope(
                color: Colors.white,
                size: 15,
                weight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
