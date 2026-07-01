import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/widgets/onekeep_ui.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text('隐私政策', style: oneKeepInter(size: 17, weight: FontWeight.w700, color: oneKeepTextPrimary(context))),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: OneKeepBouncingCard(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.chevron_left_rounded, color: oneKeepTextPrimary(context)),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('更新日期', '2026 年 6 月 30 日'),
            _gap(),
            _section('1. 信息收集', '我们收集您在使用厘清过程中主动提供的信息，包括：\n\n'
                '• 账户信息：注册时的用户名、邮箱地址、昵称\n'
                '• 交易记录：您手动录入或通过 AI 辅助生成的每一笔收支数据\n'
                '• 个人设置：头像图片、卡片背景、主题偏好、AI 服务配置\n'
                '• 使用数据：应用功能使用频率、页面访问统计（用于产品优化）'),
            _gap(),
            _section('2. 信息使用', '收集的信息用于以下目的：\n\n'
                '• 提供和维持记账服务的正常运转\n'
                '• AI 辅助记账功能（语音转文字、智能分类）\n'
                '• 数据统计和分析功能的展示\n'
                '• 数据导出功能\n'
                '• 改善产品体验和技术支持'),
            _gap(),
            _section('3. 数据存储与安全', '您的数据存储在我们的服务器上，数据传输采用 HTTPS 加密。')
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
      ],
    );
  }

  Widget _gap() => const SizedBox(height: 24);
}
