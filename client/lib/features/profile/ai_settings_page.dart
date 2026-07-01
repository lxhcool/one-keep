import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/preferences_provider.dart';
import '../../core/theme/app_colors.dart';

class AiSettingsPage extends ConsumerStatefulWidget {
  const AiSettingsPage({super.key});

  @override
  ConsumerState<AiSettingsPage> createState() => _AiSettingsPageState();
}

class _AiSettingsPageState extends ConsumerState<AiSettingsPage> {
  late final TextEditingController _baseUrlController;
  late final TextEditingController _apiKeyController;
  late final TextEditingController _modelNameController;
  bool _obscureApiKey = true;
  bool _isTesting = false;
  String? _testResult;

  // 模型列表相关
  List<String> _availableModels = [];
  bool _isLoadingModels = false;

  // 预设 API 地址
  static const _presets = [
    ('OpenAI 官方', 'https://api.openai.com/v1', 'gpt-4o-mini'),
    ('硅基流动', 'https://api.siliconflow.cn/v1', 'Qwen/Qwen3-Omni-30B-A3B-Instruct'),
    ('DeepSeek', 'https://api.deepseek.com/v1', 'deepseek-v4-flash'),
    ('Moonshot', 'https://api.moonshot.cn/v1', 'moonshot-v1-8k'),
    ('GLM (智谱)', 'https://open.bigmodel.cn/api/paas/v4', 'glm-4-flash'),
    ('通义千问', 'https://dashscope.aliyuncs.com/compatible-mode/v1', 'qwen-turbo'),
  ];

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesProvider);
    _baseUrlController = TextEditingController(text: prefs.aiApiBaseUrl);
    _apiKeyController = TextEditingController(text: prefs.aiApiKey);
    _modelNameController = TextEditingController(text: prefs.aiModelName);
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _apiKeyController.dispose();
    _modelNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prefs = ref.watch(preferencesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(isDark)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: _buildStatusCard(isDark, prefs),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildPresetSection(isDark),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildBaseUrlField(isDark),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildApiKeyField(isDark),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: _buildModelNameField(isDark),
              ),
            ),
            if (_testResult != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: _buildTestResult(isDark),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: _buildActions(isDark, prefs),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'AI 服务设置',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isDark, PreferencesState prefs) {
    final configured = prefs.hasAiConfigured;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: configured
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.emeraldLight, AppColors.emerald],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF1F5F9),
                  isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE2E8F0),
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: configured
            ? [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: configured ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              configured ? Icons.smart_toy_rounded : Icons.psychology_outlined,
              color: configured ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF64748B)),
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  configured ? 'AI 服务已配置' : '尚未配置 AI 服务',
                  style: TextStyle(
                    color: configured ? Colors.white : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  configured
                      ? '聊天记账功能已就绪'
                      : '配置后可使用 AI 聊天记账',
                  style: TextStyle(
                    color: configured ? Colors.white.withValues(alpha: 0.8) : (isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (configured)
            Icon(Icons.check_circle_rounded, color: Colors.white.withValues(alpha: 0.9), size: 24),
        ],
      ),
    );
  }

  Widget _buildPresetSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '常用服务',
            style: TextStyle(
              color: isDark ? Colors.white60 : const Color(0xFF64748B),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _presets.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final name = _presets[index].$1;
              final url = _presets[index].$2;
              final model = _presets[index].$3;
              final isSelected = _baseUrlController.text.trim() == url;
              return GestureDetector(
                onTap: () {
                  _baseUrlController.text = url;
                  _modelNameController.text = model;
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.emerald.withValues(alpha: 0.15)
                        : isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.emerald : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    name,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.emerald
                          : isDark ? Colors.white70 : const Color(0xFF374151),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBaseUrlField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API 地址',
          style: TextStyle(
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: TextField(
            controller: _baseUrlController,
            keyboardType: TextInputType.url,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: '例如 https://api.openai.com/v1',
              hintStyle: TextStyle(
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.language_rounded,
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'API Key',
          style: TextStyle(
            color: isDark ? Colors.white60 : const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.4),
              width: 0.8,
            ),
          ),
          child: TextField(
            controller: _apiKeyController,
            obscureText: _obscureApiKey,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: '输入你的 API Key',
              hintStyle: TextStyle(
                color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.key_rounded,
                color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: () => setState(() => _obscureApiKey = !_obscureApiKey),
                child: Icon(
                  _obscureApiKey ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Key 仅保存在本地设备，不会上传到服务器',
          style: TextStyle(
            color: isDark ? Colors.white24 : const Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildModelNameField(bool isDark) {
    final canFetch = _baseUrlController.text.trim().isNotEmpty &&
        _apiKeyController.text.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '模型名称',
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (canFetch)
              GestureDetector(
                onTap: _fetchModels,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _isLoadingModels
                          ? SizedBox(
                              width: 14,
                              height: 14,
                              child:
                                  CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.emerald),
                            )
                          : Icon(
                              Icons.sync_rounded,
                              size: 14,
                              color: AppColors.emerald,
                            ),
                      const SizedBox(width: 4),
                      Text(
                        '获取模型',
                        style: TextStyle(
                          color: AppColors.emerald,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // 如果有可用模型列表，显示选择器
        if (_availableModels.isNotEmpty)
          _buildModelPicker(isDark)
        else
          _buildModelInputField(isDark),
        const SizedBox(height: 8),
        Text(
          _availableModels.isEmpty
              ? '选择预设服务时自动填充，也可手动输入或点击"获取模型"'
              : '已获取 ${_availableModels.length} 个可用模型',
          style: TextStyle(
            color: isDark ? Colors.white24 : const Color(0xFF94A3B8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// 模型输入框（无模型列表时显示）
  Widget _buildModelInputField(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder.withValues(alpha: 0.4),
          width: 0.8,
        ),
      ),
      child: TextField(
        controller: _modelNameController,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.lightTextPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: '例如 gpt-4o-mini',
          hintStyle: TextStyle(
            color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.psychology_rounded,
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  /// 模型选择器（有模型列表时显示）
  Widget _buildModelPicker(bool isDark) {
    return GestureDetector(
      onTap: () => _showModelSheet(isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.emerald.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.psychology_rounded,
              color: AppColors.emerald.withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _modelNameController.text.trim().isEmpty
                    ? '点击选择模型'
                    : _modelNameController.text.trim(),
                style: TextStyle(
                  color: _modelNameController.text.trim().isNotEmpty
                      ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                      : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取可用模型列表
  Future<void> _fetchModels() async {
    setState(() => _isLoadingModels = true);

    try {
      var baseUrl = _baseUrlController.text.trim().replaceAll(RegExp(r'/+$'), '');
      if (baseUrl.endsWith('/v1')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 3);
      }
      final apiKey = _apiKeyController.text.trim();
      final dio = Dio();

      final response = await dio.get(
        '$baseUrl/v1/models',
        options: Options(
          headers: {'Authorization': 'Bearer $apiKey'},
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final rawModels = data['data'] as List<dynamic>? ?? [];
        // 提取模型 ID 并去重排序
        final ids = <String>{};
        for (final m in rawModels) {
          final id = m['id'] as String? ?? '';
          if (id.isNotEmpty && !id.contains(':') && !id.startsWith('/')) {
            ids.add(id);
          }
        }
        _availableModels = ids.toList()..sort();

        // 自动选中第一个（如果当前为空）且高亮提示
        if (_modelNameController.text.trim().isEmpty && _availableModels.isNotEmpty) {
          // 不自动填充，让用户自己选
        }
      } else {
        throw Exception('HTTP ${response.statusCode}');
      }
    } on DioException catch (e) {
      final msg = e.response?.statusCode != null
          ? '获取失败（HTTP ${e.response?.statusCode}）'
          : '连接失败：${e.message?.split('\n').first ?? "网络错误"}';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('获取模型列表失败：${e.toString().split("\n").first}'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() => _isLoadingModels = false);
    }
  }

  /// 显示模型选择弹窗
  void _showModelSheet(bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (_) => _ModelPickerSheet(
        models: _availableModels,
        currentSelection: _modelNameController.text.trim(),
        onSelect: (model) {
          _modelNameController.text = model;
          setState(() {});
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildTestResult(bool isDark) {
    final isSuccess = _testResult == '连接成功';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess
            ? AppColors.emerald.withValues(alpha: 0.08)
            : AppColors.expense.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSuccess
              ? AppColors.emerald.withValues(alpha: 0.2)
              : AppColors.expense.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            color: isSuccess ? AppColors.emerald : AppColors.expense,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _testResult!,
              style: TextStyle(
                color: isSuccess ? AppColors.emerald : AppColors.expense,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(bool isDark, PreferencesState prefs) {
    final hasInput = _baseUrlController.text.trim().isNotEmpty && _apiKeyController.text.trim().isNotEmpty;
    final hasChanged = _baseUrlController.text.trim() != prefs.aiApiBaseUrl ||
        _apiKeyController.text.trim() != prefs.aiApiKey ||
        _modelNameController.text.trim() != prefs.aiModelName;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: hasInput && hasChanged ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              disabledBackgroundColor: AppColors.emerald.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              '保存配置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        if (prefs.hasAiConfigured) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _isTesting ? null : _testConnection,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.emerald,
                side: BorderSide(color: AppColors.emerald.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isTesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald),
                    )
                  : const Text(
                      '测试连接',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _clearConfig,
            child: Text(
              '清除配置',
              style: TextStyle(
                color: AppColors.expense.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _save() async {
    final baseUrl = _baseUrlController.text.trim();
    final apiKey = _apiKeyController.text.trim();
    final modelName = _modelNameController.text.trim();
    if (baseUrl.isEmpty || apiKey.isEmpty) return;

    await ref.read(preferencesProvider.notifier).setAiApiBaseUrl(baseUrl);
    await ref.read(preferencesProvider.notifier).setAiApiKey(apiKey);
    await ref.read(preferencesProvider.notifier).setAiModelName(modelName);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI 服务配置已保存'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      final prefs = ref.read(preferencesProvider);
      var baseUrl = prefs.aiApiBaseUrl.replaceAll(RegExp(r'/+$'), '');
      if (baseUrl.endsWith('/v1')) {
        baseUrl = baseUrl.substring(0, baseUrl.length - 3);
      }
      final dio = Dio();
      final response = await dio.get(
        '$baseUrl/v1/models',
        options: Options(
          headers: {'Authorization': 'Bearer ${prefs.aiApiKey}'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        setState(() => _testResult = '连接成功');
      } else {
        setState(() => _testResult = '连接失败（HTTP ${response.statusCode}）');
      }
    } on DioException catch (e) {
      final msg = e.response?.statusCode != null
          ? '连接失败（HTTP ${e.response?.statusCode}）'
          : '连接失败：${e.message?.split('\n').first ?? '网络错误'}';
      setState(() => _testResult = msg);
    } catch (e) {
      setState(() => _testResult = '连接失败：${e.toString().split('\n').first}');
    } finally {
      setState(() => _isTesting = false);
    }
  }

  Future<void> _clearConfig() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            '清除 AI 配置',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '确定清除已保存的 API 地址和 Key？',
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                '取消',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                '清除',
                style: TextStyle(color: AppColors.expense, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await ref.read(preferencesProvider.notifier).clearAiConfig();
      _baseUrlController.text = '';
      _apiKeyController.text = '';
      _modelNameController.text = '';
      setState(() => _testResult = null);
    }
  }
}

/// 模型选择弹窗
class _ModelPickerSheet extends StatefulWidget {
  final List<String> models;
  final String currentSelection;
  final ValueChanged<String> onSelect;

  const _ModelPickerSheet({
    required this.models,
    required this.currentSelection,
    required this.onSelect,
  });

  @override
  State<_ModelPickerSheet> createState() => _ModelPickerSheetState();
}

class _ModelPickerSheetState extends State<_ModelPickerSheet> {
  late TextEditingController _searchController;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(() {
        setState(() => _searchController.text.toLowerCase());
      });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get filtered {
    if (_filter.isEmpty) return widget.models;
    final f = _filter.toLowerCase();
    return widget.models.where((m) => m.toLowerCase().contains(f)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = filtered;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          decoration: BoxDecoration(
            color:
                isDark ? const Color(0xFF1C1C1E).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.88),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.65,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示条
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 4),
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // 标题栏 + 搜索框
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Text(
                      '选择模型',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${items.length} 个可用',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // 搜索框
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _filter = v),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: '搜索模型...',
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white24 : const Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ),
              // 模型列表
              Flexible(
                child: items.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          '无匹配的模型',
                          style: TextStyle(color: isDark ? Colors.white38 : const Color(0xFF94A3B8)),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final model = items[i];
                          final isSelected = model == widget.currentSelection;
                          return GestureDetector(
                            onTap: () => widget.onSelect(model),
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.emerald.withValues(alpha: 0.08)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                                    size: 22,
                                    color: isSelected ? AppColors.emerald : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      model,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.emerald
                                            : (isDark ? Colors.white.withValues(alpha: 0.87) : AppColors.lightTextPrimary),
                                        fontSize: 15,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.emerald.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '当前',
                                        style: TextStyle(
                                          color: AppColors.emerald,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
