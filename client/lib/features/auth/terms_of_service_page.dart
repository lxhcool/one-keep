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
            _p('欢迎使用厘清。请您仔细阅读以下协议。'),
            _gap(),
            _h2('1. 服务条款的接受'),
            _p('通过注册和使用厘清，即表示您同意受本用户协议的约束。'),
            _gap(),
            _h2('2. 账户注册'),
            _p('您需要提供真实、准确的注册信息，并负责维护账户安全。'),
            _gap(),
            _h2('3. 用户行为规范'),
            _p('您同意不利用本服务从事任何违法或违规活动。'),
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
