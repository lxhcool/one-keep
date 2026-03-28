import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/onekeep_ui.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isLogin = true;
  bool _obscure = true;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    if (_isLogin) {
      ref.read(authProvider.notifier).login(email, password);
      return;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(authProvider.notifier).register(email, password, name);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: OneKeepPageBackground(
        variant: OneKeepPageVariant.auth,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.fabGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.teal.withValues(
                            alpha: isDark ? 0.28 : 0.18,
                          ),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'OneKeep',
                    style: oneKeepGrotesk(
                      color: oneKeepTextPrimary(context),
                      size: 30,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '更轻盈的记账方式',
                    style: oneKeepManrope(
                      color: oneKeepTextSecondary(context),
                      size: 14,
                      weight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  OneKeepGlassCard(
                    radius: 28,
                    blurSigma: 28,
                    fillColor: oneKeepSurface(context),
                    borderColor: oneKeepBorderStrong(context),
                    shadows: oneKeepCardShadows(context, prominent: true),
                    gradient: oneKeepPanelGradient(context),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLogin ? '欢迎回来' : '创建账户',
                          style: oneKeepGrotesk(
                            color: oneKeepTextPrimary(context),
                            size: 24,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isLogin ? '继续管理你的账本、账单与统计' : '几秒钟开始新的财务空间',
                          style: oneKeepManrope(
                            color: oneKeepTextSecondary(context),
                            size: 13,
                            weight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (state.error != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Text(
                              state.error!,
                              style: oneKeepInter(
                                color: AppColors.error,
                                size: 13,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        if (!_isLogin) ...[
                          _AuthField(
                            controller: _nameController,
                            hint: '昵称',
                            icon: LucideIcons.user,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        _AuthField(
                          controller: _emailController,
                          hint: '邮箱',
                          icon: LucideIcons.mail,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _AuthField(
                          controller: _passwordController,
                          hint: '密码',
                          icon: LucideIcons.lock,
                          obscure: _obscure,
                          suffix: IconButton(
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                              size: 18,
                              color: oneKeepTextTertiary(context),
                            ),
                          ),
                        ),
                        if (_isLogin) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {},
                              child: Text(
                                '忘记密码？',
                                style: oneKeepInter(
                                  color: AppColors.teal,
                                  size: 13,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: state.isLoading ? null : _submit,
                            child: state.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _isLogin ? '登录' : '注册',
                                    style: oneKeepManrope(
                                      color: Colors.white,
                                      size: 16,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? '还没有账户？' : '已经有账户？',
                              style: oneKeepInter(
                                color: oneKeepTextSecondary(context),
                                size: 14,
                                weight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _isLogin = !_isLogin),
                              child: Text(
                                _isLogin ? '立即注册' : '返回登录',
                                style: oneKeepInter(
                                  color: AppColors.teal,
                                  size: 14,
                                  weight: FontWeight.w700,
                                ),
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
          ),
        ),
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: oneKeepInter(
        color: oneKeepTextPrimary(context),
        size: 14,
        weight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: oneKeepInter(
          color: oneKeepTextTertiary(context),
          size: 14,
          weight: FontWeight.w500,
        ),
        filled: true,
        fillColor: oneKeepGlassStrong(context),
        prefixIcon: Icon(icon, size: 18, color: oneKeepTextTertiary(context)),
        suffixIcon: suffix,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
      ),
    );
  }
}
