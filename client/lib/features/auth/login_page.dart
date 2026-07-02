import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/onekeep_ui.dart';

const _brandLogoAsset = 'assets/images/login-logo.png';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _flowController;

  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _agreedToTerms = true;
  bool _codeSent = false;

  int _countdown = 0;
  Timer? _countdownTimer;

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
    _emailController.dispose();
    _codeController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  bool get _canSendCode =>
      _emailController.text.trim().isNotEmpty &&
      _countdown == 0 &&
      !ref.read(authProvider).isSendingCode;

  bool get _canSubmit =>
      _emailController.text.trim().isNotEmpty &&
      _codeController.text.trim().length == 6 &&
      _agreedToTerms;

  bool _isValidEmail(String email) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email);
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (!_canSendCode) return;
    if (!_isValidEmail(email)) {
      ref.read(authProvider.notifier).setError('请输入正确的邮箱地址');
      return;
    }

    HapticFeedback.lightImpact();
    final sent = await ref.read(authProvider.notifier).sendCode(email);
    if (!mounted || !sent) return;
    _startCountdown();
  }

  void _startCountdown() {
    _codeSent = true;
    _countdown = 60;
    _countdownTimer?.cancel();
    setState(() {});
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _countdown = 0);
      } else {
        if (mounted) setState(() => _countdown = _countdown - 1);
      }
    });
  }

  void _submit() {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    if (email.isEmpty || code.length != 6 || !_agreedToTerms) return;
    HapticFeedback.heavyImpact();
    ref.read(authProvider.notifier).verifyCode(email, code);
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 200,
                ),
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _BrandHeader(isDark: isDark),
                            const SizedBox(height: 10),
                            const _SectionDivider(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.black.withValues(alpha: 0.35)
                                  : Colors.white.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: Colors.white.withValues(
                                  alpha: isDark ? 0.05 : 0.4,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isDark
                                              ? Colors.black
                                              : AppColors.emerald)
                                          .withValues(
                                            alpha: isDark ? 0.5 : 0.05,
                                          ),
                                  blurRadius: 40,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (state.error != null) ...[
                                  _AuthErrorBanner(message: state.error!),
                                  const SizedBox(height: 16),
                                ],

                                _buildEmailSection(isDark),
                                const SizedBox(height: 16),
                                _buildCodeField(isDark),
                                const SizedBox(height: 20),
                                _AgreementCheckbox(
                                  agreed: _agreedToTerms,
                                  onToggle: () => setState(
                                    () => _agreedToTerms = !_agreedToTerms,
                                  ),
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 20),
                                _AuthSubmitButton(
                                  label: '登录',
                                  loading: state.isLoading,
                                  enabled: _canSubmit,
                                  onTap: _submit,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '厘清',
                                style: oneKeepInter(
                                  color: AppColors.emerald,
                                  size: 12,
                                  weight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                              TextSpan(
                                text: ' · 极简记账',
                                style: oneKeepInter(
                                  color: isDark
                                      ? Colors.white30
                                      : AppColors.lightTextTertiary,
                                  size: 12,
                                  weight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            ],
        ),
      ),
    );
  }

  Widget _buildEmailSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PremiumTextField(
          controller: _emailController,
          hint: '邮箱',
          icon: LucideIcons.mail,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) => setState(() {}),
        ),
      ],
    );
  }

  Widget _buildCodeField(bool isDark) {
    return _PremiumTextField(
      controller: _codeController,
      hint: '输入 6 位验证码',
      icon: LucideIcons.shield,
      isDark: isDark,
      keyboardType: TextInputType.number,
      autofillHints: const [],
      maxLength: 6,
      onChanged: (_) => setState(() {}),
      suffix: _buildCodeSuffix(isDark),
    );
  }

  Widget _buildCodeSuffix(bool isDark) {
    final emailEmpty = _emailController.text.trim().isEmpty;

    if (_countdown > 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 8, right: 4),
        child: Text(
          '${_countdown}s',
          style: oneKeepInter(
            color: isDark ? Colors.white38 : AppColors.lightTextTertiary,
            size: 13,
            weight: FontWeight.w700,
          ),
        ),
      );
    }

    final isSendingCode = ref.watch(authProvider).isSendingCode;
    final enabled = !emailEmpty && _countdown == 0 && !isSendingCode;
    final color = enabled
        ? AppColors.emerald
        : (isDark ? Colors.white30 : AppColors.lightTextTertiary);

    if (isSendingCode) {
      return const Padding(
        padding: EdgeInsets.only(left: 8, right: 4),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.emerald,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: enabled ? _sendCode : null,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 4),
        child: Text(
          _codeSent ? '重新发送' : '发送验证码',
          style: oneKeepInter(color: color, size: 13, weight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final bool isDark;

  const _BrandHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 28,
          child: Image.asset(
            _brandLogoAsset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          gradient: const LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.emeraldLight,
              AppColors.emerald,
              AppColors.emerald,
              AppColors.emeraldLight,
              Colors.transparent,
            ],
            stops: [0.0, 0.3, 0.45, 0.55, 0.7, 1.0],
          ),
        ),
      ),
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
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _PremiumTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const _PremiumTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.suffix,
    this.keyboardType,
    this.autofillHints,
    this.maxLength,
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
    final bgColor = Colors.transparent;
    final focusedBgColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white;
    final borderColor = widget.isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.black.withValues(alpha: 0.06);
    final iconColor = _isFocused
        ? AppColors.emerald
        : (widget.isDark ? Colors.white54 : AppColors.lightTextTertiary);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      decoration: BoxDecoration(
        color: _isFocused ? focusedBgColor : bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isFocused
              ? AppColors.emerald.withValues(alpha: 0.5)
              : borderColor,
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            autofillHints: widget.autofillHints,
            maxLength: widget.maxLength,
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
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 16, right: 12),
                child: Icon(widget.icon, size: 20, color: iconColor),
              ),
              filled: false,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.only(
                right: widget.suffix != null ? 80.0 : 0,
                top: 12,
                bottom: 12,
              ),
              counterText: '',
            ),
          ),
          if (widget.suffix != null)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(child: widget.suffix),
            ),
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
      onTap: isEnabled
          ? () {
              HapticFeedback.heavyImpact();
              onTap();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isEnabled
              ? const LinearGradient(
                  colors: [AppColors.emeraldLight, AppColors.emerald],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEnabled ? null : AppColors.emerald.withValues(alpha: 0.3),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
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
                    color: isEnabled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
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
    final bgColor = isDark
        ? AppColors.rose.withValues(alpha: 0.15)
        : AppColors.rose.withValues(alpha: 0.08);
    final borderColor = isDark
        ? AppColors.rose.withValues(alpha: 0.3)
        : AppColors.rose.withValues(alpha: 0.15);

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

class _AgreementCheckbox extends StatelessWidget {
  final bool agreed;
  final VoidCallback onToggle;
  final bool isDark;

  const _AgreementCheckbox({
    required this.agreed,
    required this.onToggle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white54 : const Color(0xFF6B7280);

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: agreed
                  ? AppColors.emerald
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: agreed
                    ? AppColors.emerald
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.15)),
                width: 1.5,
              ),
            ),
            child: agreed
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: textColor, height: 1.4),
                children: [
                  const TextSpan(text: '我已阅读并同意 '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => context.push('/legal/terms'),
                      child: Text(
                        '《用户协议》',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.emerald,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  const TextSpan(text: ' 和 '),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => context.push('/legal/privacy'),
                      child: Text(
                        '《隐私政策》',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.emerald,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
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
    );
  }
}
