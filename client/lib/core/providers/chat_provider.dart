import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/data_providers.dart';
import '../../core/providers/preferences_provider.dart';
import '../../shared/models/models.dart';

/// 聊天消息模型
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<ParsedTransaction>? transactions;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.transactions,
  });
}

/// AI 解析出的交易记录
class ParsedTransaction {
  final String title;
  final double amount;
  final String direction;
  final String? categoryName;
  final String? note;

  const ParsedTransaction({
    required this.title,
    required this.amount,
    required this.direction,
    this.categoryName,
    this.note,
  });

  factory ParsedTransaction.fromJson(Map<String, dynamic> json) =>
      ParsedTransaction(
        title: json['title'] as String? ?? '未命名',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        direction: json['direction'] as String? ?? 'expense',
        categoryName: json['categoryName'] as String?,
        note: json['note'] as String?,
      );
}

/// 聊天状态
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._ref) : super(const ChatState());

  final Ref _ref;

  /// 添加用户消息并获取 AI 响应
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: _uuid(),
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updatedMessages = [...state.messages, userMessage];
    state = state.copyWith(messages: updatedMessages, isLoading: true, error: null);

    try {
      final categories = _ref.read(categoriesProvider).valueOrNull ?? [];
      final aiResponse = await _callAiForBookkeeping(content, categories);

      final assistantMessage = ChatMessage(
        id: _uuid(),
        content: aiResponse['reply'] as String? ?? '抱歉，我没能理解你的记账内容。',
        isUser: false,
        timestamp: DateTime.now(),
        transactions: (aiResponse['transactions'] as List<dynamic>?)
            ?.map((e) => ParsedTransaction.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMessage],
        isLoading: false,
      );
    } catch (e) {
      // 添加错误提示消息
      final errorMsg = ChatMessage(
        id: _uuid(),
        content: e.toString().replaceFirst('Exception: ', ''),
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// 确认并提交 AI 解析出的交易记录
  Future<void> confirmTransactions(List<ParsedTransaction> transactions) async {
    final categories = _ref.read(categoriesProvider).valueOrNull ?? [];

    for (final tx in transactions) {
      String? categoryId;
      if (tx.categoryName != null) {
        final match = categories.where(
          (c) => c.name == tx.categoryName || c.name.contains(tx.categoryName!),
        ).firstOrNull;
        categoryId = match?.id;
      }
      if (categoryId == null) {
        final fallback = categories
            .where((c) => c.type == tx.direction)
            .firstOrNull;
        categoryId = fallback?.id;
      }
      if (categoryId == null) continue;

      try {
        final api = _ref.read(apiClientProvider);
        await api.dio.post('/api/transactions', data: {
          'title': tx.title,
          'amount': tx.amount,
          'direction': tx.direction,
          'categoryId': categoryId,
          'occurredAt': DateTime.now().toUtc().toIso8601String(),
          if (tx.note != null) 'note': tx.note,
        });
      } catch (_) {
        // 静默跳过失败的提交
      }
    }

    _ref.read(homeProvider.notifier).load();
    _ref.read(billsProvider.notifier).load();

    final confirmMsg = ChatMessage(
      id: _uuid(),
      content: '已成功记录 ${transactions.length} 笔交易！',
      isUser: false,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, confirmMsg]);
  }

  /// 清空聊天记录
  void clearChat() {
    state = const ChatState();
  }

  Future<Map<String, dynamic>> _callAiForBookkeeping(
    String userMessage,
    List<Category> categories,
  ) async {
    final prefs = _ref.read(preferencesProvider);
    if (!prefs.hasAiConfigured) {
      throw Exception('请先在「我的 → AI 设置」中配置 AI 服务');
    }

    final modelName = prefs.aiModelName.isNotEmpty ? prefs.aiModelName : 'gpt-4o-mini';

    try {

    final categoryList = categories
        .map((c) => '  - ${c.name}（${c.type == 'expense' ? '支出' : '收入'}）')
        .join('\n');

    final systemPrompt = '''你是一个智能记账助手。用户会用自然语言描述他们的收支，你需要从中提取出交易信息。

用户的分类列表如下：
$categoryList

请严格按以下 JSON 格式回复，不要输出任何其他内容（不要输出思考过程、解释或markdown代码块）：
{"reply":"简短的确认回复","transactions":[{"title":"交易名称","amount":金额数字,"direction":"expense或income","categoryName":"匹配的分类名","note":"可选备注"}]}

注意事项：
1. amount 必须是数字，不含货币符号
2. direction 只能是 "expense" 或 "income"
3. categoryName 必须从上面的分类列表中选择最匹配的
4. 如果用户描述了多笔交易，transactions 数组中放多条记录
5. 如果无法理解用户的意图，reply 中说明，transactions 设为空数组
6. 只输出纯 JSON，不要输出思考过程，不要用markdown代码块包裹''';

    var baseUrl = prefs.aiApiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    // 如果 baseUrl 以 /v1 结尾，去掉后统一拼接
    if (baseUrl.endsWith('/v1')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 3);
    }

    final dio = Dio();
    final response = await dio.post(
      '$baseUrl/v1/chat/completions',
      data: {
        'model': modelName,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          // 发送完整对话上下文，AI 回复中清理掉 <think/> 等推理标签
          ...state.messages
              .take(20)
              .map((m) => {
                    'role': m.isUser ? 'user' : 'assistant',
                    'content': m.isUser ? m.content : _stripThinkTags(m.content),
                  }),
        ],
        'temperature': 0.2,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer ${prefs.aiApiKey}',
          'Content-Type': 'application/json',
        },
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    // 解析 AI 响应
    final body = response.data as Map<String, dynamic>;
    final choices = body['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw Exception('AI 服务返回了空响应');
    }

    // 检查 finish_reason
    final finishReason = choices[0]['finish_reason'] as String? ?? 'stop';
    if (finishReason == 'content_filter' || finishReason == 'length') {
      throw Exception('AI 响应被截断（$finishReason），请尝试简化输入');
    }

    var content = choices[0]['message']?['content'] as String?;

    // 处理 content 为 null 的情况（推理模型可能只返回 reasoning_content）
    if (content == null || content.trim().isEmpty) {
      final reasoning = choices[0]['message']?['reasoning_content'] as String?;
      if (reasoning != null && reasoning.trim().isNotEmpty) {
        // 推理模型只返回了思考过程，没有实际回复内容
        // 尝试从推理内容中提取 JSON
        content = reasoning;
      } else {
        throw Exception('模型 "$modelName" 返回了空内容，请检查模型是否支持此请求方式，或在「我的 → AI 设置」中更换模型');
      }
    }

    // 尝试解析 JSON，失败则返回原始文本作为回复
    Map<String, dynamic> result;
    try {
      final jsonStr = _extractJson(content);
      result = jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      result = {'reply': content, 'transactions': <dynamic>[]};
    }

    return result;
  } on DioException catch (e) {
      String errorMsg;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMsg = '连接超时，请检查网络或稍后重试';
      } else if (e.response?.statusCode != null) {
        final code = e.response!.statusCode!;
        switch (code) {
          case 401:
            errorMsg = 'API Key 无效，请在「我的 → AI 设置」中检查配置';
            break;
          case 403:
            errorMsg = 'API 访问被拒绝，请检查权限或余额';
            break;
          case 404:
            errorMsg = 'API 地址不正确，模型 "$modelName" 可能不存在';
            break;
          case 429:
            errorMsg = '请求过于频繁，请稍后重试';
            break;
          case 500:
          case 502:
          case 503:
          case 504:
            errorMsg = 'AI 服务暂时不可用（HTTP $code），请稍后重试';
            break;
          default:
            errorMsg = 'AI 服务请求失败（HTTP $code）';
        }
      } else {
        errorMsg = '无法连接到 AI 服务，请检查网络和 API 配置';
      }
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('AI 服务异常：${e.toString().split('\n').first}');
    }
  }

  String _extractJson(String text) {
    // 先去掉推理模型的 <think...</think*> 标签内容
    var cleaned = text.replaceAll(RegExp(r'<think[\s\S]*?</think\s*>'), '');
    // 去掉 <think... 开头但没有闭合标签的情况（截断的推理内容）
    cleaned = cleaned.replaceAll(RegExp(r'<think[\s\S]*'), '');
    cleaned = cleaned.trim();

    // 尝试提取 markdown 代码块中的 JSON
    final codeBlockRegex = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```');
    final match = codeBlockRegex.firstMatch(cleaned);
    if (match != null) {
      return match.group(1)!.trim();
    }

    // 提取最外层的 { ... } JSON 对象
    final braceStart = cleaned.indexOf('{');
    final braceEnd = cleaned.lastIndexOf('}');
    if (braceStart != -1 && braceEnd != -1 && braceEnd > braceStart) {
      return cleaned.substring(braceStart, braceEnd + 1);
    }

    return cleaned;
  }

  /// 清理 AI 回复中的 <think/> 推理标签，用于构建上下文时保持干净
  String _stripThinkTags(String text) {
    var cleaned = text.replaceAll(RegExp(r'<think[\s\S]*?</think\s*>'), '');
    cleaned = cleaned.replaceAll(RegExp(r'<think[\s\S]*'), '');
    return cleaned.trim();
  }

  String _uuid() => DateTime.now().microsecondsSinceEpoch.toString();
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});
