import 'package:flutter/material.dart';
import '../../shared/widgets/onekeep_ui.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text('用户协议', style: oneKeepInter(size: 17, weight: FontWeight.w700, color: oneKeepTextPrimary(context))),
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
            _h1('厘清用户协议'),
            _p('欢迎使用厘清。请您在登录和使用本服务前仔细阅读以下内容。'),
            _gap(),
            _h2('1. 服务条款的接受'),
            _p('当您勾选并使用邮箱验证码完成登录，即视为您已阅读并同意受本协议及《隐私政策》约束。'),
            _gap(),
            _h2('2. 账户与登录'),
            _p('本服务当前采用邮箱验证码登录方式。您应保证所使用邮箱真实、有效，并自行保管邮箱访问权限。因邮箱失管导致的风险由您自行承担。'),
            _gap(),
            _h2('3. 用户行为规范'),
            _p('您不得利用本服务从事违法违规活动，不得上传、生成、传播侵害他人合法权益或违反法律法规的内容，不得干扰、攻击或滥用本服务。'),
            _gap(),
            _h2('4. 服务内容'),
            _p('厘清提供记账录入、账单浏览、统计分析、分类管理、数据导出及 AI 辅助记账等功能。具体功能以当前发布版本实际提供能力为准。'),
            _gap(),
            _h2('5. 数据与责任'),
            _p('您对自行录入、导入、导出的数据内容负责。对于因您主动配置第三方 AI 服务或向第三方分享导出文件所产生的后果，由您依据相关服务规则自行承担。'),
            _gap(),
            _h2('6. 服务可用性'),
            _p('我们会持续维护服务稳定性，但不对网络故障、第三方服务异常、不可抗力或系统维护期间导致的暂时不可用承担绝对连续可用义务。'),
            _gap(),
            _h2('7. 账户终止'),
            _p('您可以通过应用内“个人设置”中的“注销账号”功能终止使用本服务。注销后，相关账户数据将按照《隐私政策》说明进行删除处理。'),
            _gap(),
            _h2('8. 协议更新'),
            _p('当产品功能、法律要求或运营规则发生变化时，我们有权更新本协议。更新后的协议发布后继续使用本服务，即视为您接受更新内容。'),
            _gap(),
          ],
        ),
      ),
    );
  }

  Widget _h1(String t) => Text(t, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800));
  Widget _h2(String t) => Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));
  Widget _p(String t) => Text(t, style: const TextStyle(fontSize: 14, height: 1.6));
  Widget _gap() => const SizedBox(height: 24);
}
