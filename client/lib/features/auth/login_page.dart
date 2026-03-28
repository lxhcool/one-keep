import 'dart:math' as math;

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

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscure = true;
  AnimationController? _flowController;

  final _identifierController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ensureFlowController();
  }

  @override
  void dispose() {
    _flowController?.dispose();
    _identifierController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  AnimationController get _resolvedFlowController {
    return _flowController ?? _ensureFlowController();
  }

  AnimationController _ensureFlowController() {
    return _flowController ??= AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  bool get _canSubmit {
    final password = _passwordController.text.trim();
    if (_isLogin) {
      return _identifierController.text.trim().isNotEmpty &&
          password.isNotEmpty;
    }

    return _usernameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _displayNameController.text.trim().isNotEmpty &&
        password.isNotEmpty;
  }

  void _submit() {
    final password = _passwordController.text.trim();
    if (_isLogin) {
      final identifier = _identifierController.text.trim();
      if (identifier.isEmpty || password.isEmpty) return;
      ref.read(authProvider.notifier).login(identifier, password);
      return;
    }

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final displayName = _displayNameController.text.trim();
    if (username.isEmpty ||
        email.isEmpty ||
        displayName.isEmpty ||
        password.isEmpty) {
      return;
    }

    ref
        .read(authProvider.notifier)
        .register(username, email, password, displayName);
  }

  void _switchMode(bool loginMode) {
    if (_isLogin == loginMode) return;
    setState(() {
      _isLogin = loginMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final contentWidth = math.min(MediaQuery.sizeOf(context).width, 560.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _resolvedFlowController,
                builder: (context, _) {
                  return _TopFlowBackground(
                    progress: _resolvedFlowController.value,
                  );
                },
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 88, 24, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeroBadge(),
                      const SizedBox(height: 28),
                      _ModeSwitch(
                        isLogin: _isLogin,
                        onLoginTap: () => _switchMode(true),
                        onRegisterTap: () => _switchMode(false),
                      ),
                      if (state.error != null) ...[
                        const SizedBox(height: 18),
                        _AuthErrorBanner(message: state.error!),
                      ],
                      const SizedBox(height: 18),
                      _AuthFormSection(
                        key: ValueKey(_isLogin),
                        isLogin: _isLogin,
                        obscure: _obscure,
                        identifierController: _identifierController,
                        usernameController: _usernameController,
                        emailController: _emailController,
                        displayNameController: _displayNameController,
                        passwordController: _passwordController,
                        canSubmit: _canSubmit,
                        isLoading: state.isLoading,
                        onChanged: () => setState(() {}),
                        onToggleObscure: () =>
                            setState(() => _obscure = !_obscure),
                        onSubmit: _submit,
                        onSwitchMode: () => _switchMode(!_isLogin),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.tealLight, Color(0xFF22D3EE)],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'OneKeep · 轻量记账',
            style: oneKeepInter(
              color: AppColors.lightTextPrimary,
              size: 12,
              weight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopFlowBackground extends StatelessWidget {
  final double progress;

  const _TopFlowBackground({required this.progress});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Colors.white),
      child: CustomPaint(
        painter: _TopAuroraPainter(progress: progress),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xA5D6FAFF),
                const Color(0x8FC7F9FF),
                Colors.white.withValues(alpha: 0.82),
                Colors.white,
              ],
              stops: const [0, 0.28, 0.68, 1],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopAuroraPainter extends CustomPainter {
  final double progress;

  const _TopAuroraPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final travel = progress * math.pi * 2;

    _drawBlob(
      canvas,
      size,
      color: const Color(0xFF22CFE3).withValues(alpha: 0.24),
      anchorX: 0.16 + 0.08 * math.sin(travel * 0.82),
      anchorY: 0.12 + 0.05 * math.cos(travel * 0.64),
      radius: size.width * 0.46,
    );
    _drawBlob(
      canvas,
      size,
      color: const Color(0xFF5FD79C).withValues(alpha: 0.18),
      anchorX: 0.76 + 0.07 * math.cos(travel * 0.90),
      anchorY: 0.22 + 0.06 * math.sin(travel * 0.78),
      radius: size.width * 0.40,
    );
    _drawBlob(
      canvas,
      size,
      color: const Color(0xFF8FC5FF).withValues(alpha: 0.18),
      anchorX: 0.48 + 0.05 * math.sin(travel * 1.12),
      anchorY: 0.42 + 0.05 * math.cos(travel * 0.70),
      radius: size.width * 0.44,
    );

    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Offset.zero & size);

    final path = Path()
      ..moveTo(
        -size.width * 0.08,
        size.height * (0.14 + 0.02 * math.sin(travel)),
      )
      ..cubicTo(
        size.width * 0.18,
        size.height * (0.02 + 0.02 * math.cos(travel * 0.8)),
        size.width * 0.54,
        size.height * (0.26 + 0.03 * math.sin(travel * 0.7)),
        size.width * 1.02,
        size.height * (0.10 + 0.03 * math.cos(travel * 0.9)),
      );
    canvas.drawPath(path, strokePaint);

    final path2 = Path()
      ..moveTo(
        -size.width * 0.04,
        size.height * (0.44 + 0.02 * math.cos(travel * 0.7)),
      )
      ..cubicTo(
        size.width * 0.20,
        size.height * (0.56 + 0.02 * math.sin(travel * 0.9)),
        size.width * 0.60,
        size.height * (0.30 + 0.03 * math.cos(travel * 0.8)),
        size.width * 1.00,
        size.height * (0.40 + 0.03 * math.sin(travel)),
      );
    canvas.drawPath(path2, strokePaint..strokeWidth = 0.9);
  }

  void _drawBlob(
    Canvas canvas,
    Size size, {
    required Color color,
    required double anchorX,
    required double anchorY,
    required double radius,
  }) {
    final center = Offset(size.width * anchorX, size.height * anchorY);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withValues(alpha: color.a * 0.45),
          Colors.transparent,
        ],
        stops: const [0, 0.46, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.18);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _TopAuroraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _ModeSwitch extends StatelessWidget {
  final bool isLogin;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const _ModeSwitch({
    required this.isLogin,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                alignment: isLogin
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ModeSwitchItem(
                  label: '登录',
                  selected: isLogin,
                  onTap: onLoginTap,
                ),
                _ModeSwitchItem(
                  label: '注册',
                  selected: !isLogin,
                  onTap: onRegisterTap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSwitchItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeSwitchItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 56,
          height: 30,
          child: Center(
            child: Text(
              label,
              style: oneKeepInter(
                color: selected ? Colors.white : AppColors.lightTextSecondary,
                size: 14,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthFormSection extends StatelessWidget {
  final bool isLogin;
  final bool obscure;
  final TextEditingController identifierController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController displayNameController;
  final TextEditingController passwordController;
  final bool canSubmit;
  final bool isLoading;
  final VoidCallback onChanged;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onSwitchMode;

  const _AuthFormSection({
    super.key,
    required this.isLogin,
    required this.obscure,
    required this.identifierController,
    required this.usernameController,
    required this.emailController,
    required this.displayNameController,
    required this.passwordController,
    required this.canSubmit,
    required this.isLoading,
    required this.onChanged,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onSwitchMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLogin) ...[
          _AuthField(
            controller: identifierController,
            hint: '用户名或邮箱',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 14),
        ] else ...[
          _AuthField(
            controller: usernameController,
            hint: '用户名',
            autofillHints: const [AutofillHints.username],
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 14),
          _AuthField(
            controller: emailController,
            hint: '邮箱',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 14),
          _AuthField(
            controller: displayNameController,
            hint: '昵称',
            autofillHints: const [AutofillHints.name],
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 14),
        ],
        _AuthField(
          controller: passwordController,
          hint: isLogin ? '密码' : '设置密码',
          obscure: obscure,
          autofillHints: [
            isLogin ? AutofillHints.password : AutofillHints.newPassword,
          ],
          suffix: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: onToggleObscure,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
              splashRadius: 18,
              icon: Icon(
                obscure ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 24),
        _AuthSubmitButton(
          label: isLogin ? '进入 OneKeep' : '创建并进入',
          loading: isLoading,
          enabled: canSubmit,
          onTap: onSubmit,
        ),
        const SizedBox(height: 16),
        Center(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                isLogin ? '还没有账号？' : '已经有账号了？',
                style: oneKeepInter(
                  color: AppColors.lightTextSecondary,
                  size: 14,
                  weight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: onSwitchMode,
                child: Text(
                  isLogin ? '立即注册' : '返回登录',
                  style: oneKeepInter(
                    color: AppColors.teal,
                    size: 14,
                    weight: FontWeight.w700,
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

class _AuthErrorBanner extends StatelessWidget {
  final String message;

  const _AuthErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xD9FFF5F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1AEF4444)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, size: 18, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: oneKeepInter(
                color: AppColors.error,
                size: 13,
                weight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;

  const _AuthField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.autofillHints,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        onChanged: onChanged,
        style: oneKeepInter(
          color: AppColors.lightTextPrimary,
          size: 15,
          weight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: oneKeepInter(
            color: AppColors.lightTextTertiary,
            size: 14,
            weight: FontWeight.w500,
          ),
          filled: false,
          fillColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          suffixIcon: suffix,
          suffixIconConstraints: const BoxConstraints(minWidth: 44),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 19,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _AuthSubmitButton extends StatelessWidget {
  final String label;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  const _AuthSubmitButton({
    required this.label,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !loading;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isEnabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.42),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: oneKeepManrope(
                  color: Colors.white,
                  size: 16,
                  weight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
