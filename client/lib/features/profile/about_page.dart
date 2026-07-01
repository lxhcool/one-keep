import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../shared/widgets/onekeep_ui.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text('关于系统', style: oneKeepInter(size: 17, weight: FontWeight.w700, color: oneKeepTextPrimary(context))),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: OneKeepBouncingCard(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.chevron_left_rounded, color: oneKeepTextPrimary(context)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 80, height: 80,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset('assets/images/login-logo.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 20),
            Text('厘清', style: oneKeepGrotesk(size: 28, weight: FontWeight.w900, color: oneKeepTextPrimary(context))),
            const SizedBox(height: 4),
            Text('v1.0.0', style: oneKeepInter(size: 14, color: oneKeepTextTertiary(context))),
            const SizedBox(height: 8),
            Text('极简你的财务生活', style: oneKeepInter(size: 14, color: oneKeepTextSecondary(context))),
            const Spacer(flex: 2),
            _linkItem(context, LucideIcons.fileText, '用户协议', () => context.push('/legal/terms'), isDark),
            const SizedBox(height: 12),
            _linkItem(context, LucideIcons.shield, '隐私政策', () => context.push('/legal/privacy'), isDark),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _complianceItem(context, 'AI 功能说明', '本应用的语音记账和智能分类功能使用第三方 AI 服务进行处理。AI 生成的内容仅供参考，最终交易记录以用户确认为准。'),
                  const SizedBox(height: 12),
                  _complianceItem(context, '未成年人保护', '本应用不向未成年人提供注册服务。如您是未成年人，请在监护人指导下使用。'),
                  const SizedBox(height: 12),
                  _complianceItem(context, '数据安全', '数据传输采用 HTTPS 加密，账户信息使用安全存储。我们不会将您的数据用于记账服务以外的任何目的。'),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _complianceItem(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: oneKeepTextPrimary(context))),
        const SizedBox(height: 4),
        Text(content, style: TextStyle(fontSize: 12, height: 1.5, color: oneKeepTextTertiary(context))),
      ],
    );
  }

  Widget _linkItem(BuildContext context, IconData icon, String label, VoidCallback onTap, bool isDark) {
    return OneKeepBouncingCard(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: oneKeepTextSecondary(context)),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: oneKeepInter(size: 15, weight: FontWeight.w600, color: oneKeepTextPrimary(context)))),
            Icon(Icons.chevron_right_rounded, size: 20, color: isDark ? const Color(0xFF48484A) : const Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }
}
