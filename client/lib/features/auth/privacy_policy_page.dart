import 'package:flutter/material.dart';
import '../../shared/widgets/onekeep_ui.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF000000)
          : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text(
          '隐私政策',
          style: oneKeepInter(
            size: 17,
            weight: FontWeight.w700,
            color: oneKeepTextPrimary(context),
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: OneKeepBouncingCard(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.chevron_left_rounded,
            color: oneKeepTextPrimary(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _section('更新日期', '2026 年 7 月 2 日'),
            _gap(),
            _section(
              '1. 我们收集的信息',
              '为了向您提供记账、同步和账户管理能力，我们会在您使用服务时处理以下信息：\n\n'
                  '• 账户信息：邮箱地址、用户名、昵称，以及用于登录验证的必要信息\n'
                  '• 记账数据：您录入或编辑的交易标题、金额、分类、时间、备注、商户等内容\n'
                  '• 个性化设置：主题偏好、头像、分类排序、自定义分类等\n'
                  '• 设备与日志信息：基础设备信息、接口访问日志、错误日志，用于排查故障和保障服务稳定',
            ),
            _gap(),
            _section(
              '2. 我们如何使用这些信息',
              '我们处理上述信息的目的包括：\n\n'
                  '• 完成账号注册、密码登录、账号识别和多端数据同步\n'
                  '• 提供首页汇总、账单浏览、统计分析、分类管理等核心功能\n'
                  '• 进行故障排查、服务监控、安全审计和体验优化',
            ),
            _gap(),
            _section(
              '3. 权限说明',
              '应用仅在相关功能被您主动使用时申请必要权限：\n\n'
                  '• 相册权限（iOS）：用于从相册选择头像图片\n\n'
                  '您可以在系统设置中关闭相关权限，但关闭后对应功能可能无法使用。',
            ),
            _gap(),
            _section(
              '4. 数据存储、传输与安全',
              '您的账户数据和记账数据存储在服务端数据库中，客户端与服务端之间默认通过 HTTPS 传输。'
                  '我们会采取访问控制、日志审计、错误监控等合理措施降低数据被未经授权访问、披露或丢失的风险。'
                  '但互联网传输和存储无法保证绝对安全，请您妥善保管自己的登录邮箱和设备。',
            ),
            _gap(),
            _section(
              '5. 数据共享与对外提供',
              '除以下情形外，我们不会擅自向无关第三方出售您的个人信息：\n\n'
                  '• 为履行法律法规要求、响应监管或司法机关的合法请求\n'
                  '• 为保障系统安全、处理欺诈、攻击或严重故障等必要场景',
            ),
            _gap(),
            _section(
              '6. 数据保存与删除',
              '在您正常使用服务期间，我们会保存实现产品功能所必需的数据。'
                  '如果您不再使用本服务，可在应用“个人设置”中使用“注销账号”功能。注销后，账户、交易记录、分类和个人设置将被删除，且通常无法恢复。'
                  '如因法律法规或审计要求需要保留部分日志，我们将在必要期限届满后删除或匿名化处理。',
            ),
            _gap(),
            _section(
              '7. 您的权利',
              '您可以访问、更正和删除自己的主要记账数据，也可以通过注销账号停止继续使用服务。'
                  '如您对隐私处理有异议，建议在正式上架版本提供并公示专用支持邮箱后，通过该渠道提交申请。',
            ),
            _gap(),
            _section(
              '8. 政策更新',
              '当业务功能、适用法律或数据处理方式发生变化时，我们可能更新本隐私政策。'
                  '更新后的内容将在应用内或相关站点页面发布，并以页面标注的更新日期为准。',
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
      ],
    );
  }

  Widget _gap() => const SizedBox(height: 24);
}
