import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/onekeep_ui.dart';

const _brandLogoAsset = 'assets/images/app-logo.png';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  bool _obscure = true;
  late AnimationController _flowController;

  final _identifierController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _flowController.dispose();
    _identifierController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _displayNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final password = _passwordController.text.trim();
    if (_isLogin) {
      return _identifierController.text.trim().isNotEmpty && password.isNotEmpty;
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
    if (username.isEmpty || email.isEmpty || displayName.isEmpty || password.isEmpty) {
      return;
    }

    ref.read(authProvider.notifier).register(username, email, password, displayName);
  }

  void _switchMode(bool loginMode) {
    if (_isLogin == loginMode) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isLogin = loginMode;
      if (ref.read(authProvider).error != null) {
        ref.read(authProvider.notifier).clearError();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(authProvider);
    final contentWidth = math.min(MediaQuery.sizeOf(context).width, 420.0);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _flowController,
                  builder: (context, _) {
                    return _NordicAuroraBackground(
                      progress: _flowController.value,
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ),
            
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentWidth),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _BrandHeader(isDark: isDark, isLogin: _isLogin),
                        const SizedBox(height: 40),

                        ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? Colors.black.withValues(alpha: 0.35) 
                                    : Colors.white.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: isDark ? 0.05 : 0.4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (isDark ? Colors.black : AppColors.emerald).withValues(alpha: isDark ? 0.5 : 0.05),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ModeSwitch(
                                    isLogin: _isLogin,
                                    isDark: isDark,
                                    onLoginTap: () => _switchMode(true),
                                    onRegisterTap: () => _switchMode(false),
                                  ),
                                  const SizedBox(height: 24),
                                  
                                  if (state.error != null) ...[
                                    _AuthErrorBanner(message: state.error!),
                                    const SizedBox(height: 16),
                                  ],
                                  
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOutCubic,
                                    alignment: Alignment.topCenter,
                                    child: _AuthFormSection(
                                      isLogin: _isLogin,
                                      isDark: isDark,
                                      obscure: _obscure,
                                      identifierController: _identifierController,
                                      usernameController: _usernameController,
                                      emailController: _emailController,
                                      displayNameController: _displayNameController,
                                      passwordController: _passwordController,
                                      canSubmit: _canSubmit,
                                      isLoading: state.isLoading,
                                      onChanged: () => setState(() {}),
                                      onToggleObscure: () => setState(() => _obscure = !_obscure),
                                      onSubmit: _submit,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        Center(
                          child: Text(
                            'OneKeep · 极简你的财务生活',
                            style: oneKeepInter(
                              color: isDark ? Colors.white30 : AppColors.lightTextTertiary,
                              size: 12,
                              weight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
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
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final bool isDark;
  final bool isLogin;

  const _BrandHeader({required this.isDark, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.emerald.withValues(alpha: isDark ? 0.3 : 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            _brandLogoAsset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            isLogin ? '欢迎回来' : '开始旅程',
            key: ValueKey(isLogin),
            style: oneKeepGrotesk(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              size: 32,
              weight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _NordicAuroraBackground extends StatelessWidget {
  final double progress;
  final bool isDark;

  const _NordicAuroraBackground({required this.progress, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AuroraPainter(progress: progress, isDark: isDark),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  const _AuroraPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final travel = progress * math.pi * 2;

    final color1 = isDark ? AppColors.emeraldDark : AppColors.emeraldSoft;
    final color2 = isDark ? const Color(0xFF064E3B) : const Color(0xFFA7F3D0);
    final color3 = isDark ? const Color(0xFF047857) : const Color(0xFF6EE7B7);

    _drawBlob(
      canvas,
      size,
      color: color1.withValues(alpha: isDark ? 0.6 : 0.8),
      anchorX: 0.2 + 0.15 * math.sin(travel),
      anchorY: 0.2 + 0.1 * math.cos(travel * 0.8),
      radius: size.width * 0.6,
    );
    
    _drawBlob(
      canvas,
      size,
      color: color2.withValues(alpha: isDark ? 0.5 : 0.7),
      anchorX: 0.8 + 0.1 * math.cos(travel * 1.2),
      anchorY: 0.8 + 0.15 * math.sin(travel * 0.9),
      radius: size.width * 0.7,
    );

    _drawBlob(
      canvas,
      size,
      color: color3.withValues(alpha: isDark ? 0.4 : 0.6),
      anchorX: 0.5 + 0.2 * math.sin(travel * 0.7),
      anchorY: 0.5 + 0.2 * math.cos(travel * 1.1),
      radius: size.width * 0.5,
    );
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
        colors: [color, color.withValues(alpha: 0)],
        stops: const [0, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) => oldDelegate.progress != progress;
}

class _ModeSwitch extends StatelessWidget {
  final bool isLogin;
  final bool isDark;
  final VoidCallback onLoginTap;
  final VoidCallback onRegisterTap;

  const _ModeSwitch({
    required this.isLogin,
    required this.isDark,
    required this.onLoginTap,
    required this.onRegisterTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04);
    final thumbColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final unselectedTextColor = isDark ? Colors.white54 : AppColors.lightTextTertiary;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: thumbColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onLoginTap,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: oneKeepInter(
                        color: isLogin ? textColor : unselectedTextColor,
                        size: 15,
                        weight: isLogin ? FontWeight.w700 : FontWeight.w600,
                      ),
                      child: const Text('登录'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onRegisterTap,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: oneKeepInter(
                        color: !isLogin ? textColor : unselectedTextColor,
                        size: 15,
                        weight: !isLogin ? FontWeight.w700 : FontWeight.w600,
                      ),
                      child: const Text('注册'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AuthFormSection extends StatelessWidget {
  final bool isLogin;
  final bool isDark;
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

  const _AuthFormSection({
    required this.isLogin,
    required this.isDark,
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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (isLogin) ...[
          _PremiumTextField(
            controller: identifierController,
            hint: '邮箱或用户名',
            icon: LucideIcons.user,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 16),
        ] else ...[
          _PremiumTextField(
            controller: usernameController,
            hint: '用户名',
            icon: LucideIcons.user,
            isDark: isDark,
            autofillHints: const [AutofillHints.username],
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 16),
          _PremiumTextField(
            controller: emailController,
            hint: '邮箱',
            icon: LucideIcons.mail,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 16),
          _PremiumTextField(
            controller: displayNameController,
            hint: '昵称',
            icon: LucideIcons.smile,
            isDark: isDark,
            autofillHints: const [AutofillHints.name],
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 16),
        ],
        _PremiumTextField(
          controller: passwordController,
          hint: isLogin ? '密码' : '设置密码',
          icon: LucideIcons.lock,
          isDark: isDark,
          obscure: obscure,
          autofillHints: [isLogin ? AutofillHints.password : AutofillHints.newPassword],
          suffix: IconButton(
            onPressed: onToggleObscure,
            splashRadius: 20,
            icon: Icon(
              obscure ? LucideIcons.eyeOff : LucideIcons.eye,
              size: 18,
              color: isDark ? Colors.white54 : AppColors.lightTextTertiary,
            ),
          ),
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 32),
        
        _AuthSubmitButton(
          label: isLogin ? '进入 OneKeep' : '创建并进入',
          loading: isLoading,
          enabled: canSubmit,
          onTap: onSubmit,
        ),
      ],
    );
  }
}

class _PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;

  const _PremiumTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
    this.autofillHints,
    this.onChanged,
  });

  @override
  State<_PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<_PremiumTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 强制背景在未聚焦时完全透明，确保与毛玻璃卡片背景 100% 统一
    final bgColor = Colors.transparent;
    final focusedBgColor = widget.isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white;
    final borderColor = widget.isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06);
    final iconColor = _isFocused ? AppColors.emerald : (widget.isDark ? Colors.white54 : AppColors.lightTextTertiary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        color: _isFocused ? focusedBgColor : bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused ? AppColors.emerald.withValues(alpha: 0.5) : borderColor,
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused ? [
          BoxShadow(
            color: AppColors.emerald.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ] : null,
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(widget.icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: widget.obscure,
              keyboardType: widget.keyboardType,
              autofillHints: widget.autofillHints,
              onChanged: widget.onChanged,
              cursorColor: AppColors.emerald,
              style: oneKeepInter(
                color: widget.isDark ? Colors.white : AppColors.lightTextPrimary,
                size: 15,
                weight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: oneKeepInter(
                  color: widget.isDark ? Colors.white30 : AppColors.lightTextTertiary,
                  size: 15,
                  weight: FontWeight.w500,
                ),
                filled: false,
                fillColor: Colors.transparent, // 强制 TextField 内部背景透明
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          if (widget.suffix != null) widget.suffix!,
        ],
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

    return OneKeepBouncingCard(
      onTap: isEnabled ? () {
        HapticFeedback.heavyImpact();
        onTap();
      } : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isEnabled ? const LinearGradient(
            colors: [AppColors.emeraldLight, AppColors.emerald],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: isEnabled ? null : AppColors.emerald.withValues(alpha: 0.3),
          boxShadow: isEnabled ? [
            BoxShadow(
              color: AppColors.emerald.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ] : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: oneKeepManrope(
                    color: isEnabled ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    size: 16,
                    weight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
        ),
      ),
    );
  }
}

class _AuthErrorBanner extends StatelessWidget {
  final String message;

  const _AuthErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.rose.withValues(alpha: 0.15) : AppColors.rose.withValues(alpha: 0.08);
    final borderColor = isDark ? AppColors.rose.withValues(alpha: 0.3) : AppColors.rose.withValues(alpha: 0.15);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.alertCircle, size: 18, color: AppColors.rose),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: oneKeepInter(
                color: isDark ? const Color(0xFFFDA4AF) : AppColors.rose,
                size: 13,
                weight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
