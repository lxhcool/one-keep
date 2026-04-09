import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/providers/chat_provider.dart';
import '../../core/providers/preferences_provider.dart';
import '../../core/services/speech_service.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/onekeep_ui.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  // 语音相关
  final _speech = SpeechService.instance;
  bool _isListening = false;
  bool _isProcessing = false;
  String _partialSpeech = '';
  StreamSubscription? _stateSub;
  StreamSubscription? _resultSub;
  StreamSubscription? _partialSub;
  StreamSubscription? _errorSub;

  @override
  void initState() {
    super.initState();

    // 每次进入聊天页面，清空历史记录，开启全新会话
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).clearChat();
    });

    _stateSub = _speech.onStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isListening = state == SpeechState.listening;
        _isProcessing = state == SpeechState.processing;
        if (!_isListening && !_isProcessing) _partialSpeech = '';
      });
    });

    _resultSub = _speech.onResult.listen((text) {
      if (!mounted || text.trim().isEmpty) return;
      _textController.text = text.trim();
      setState(() {});
      _sendMessage();
    });

    _partialSub = _speech.onPartialResult.listen((text) {
      if (!mounted) return;
      setState(() => _partialSpeech = text);
    });

    _errorSub = _speech.onError.listen((msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.shade700,
        ),
      );
    });
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _resultSub?.cancel();
    _partialSub?.cancel();
    _errorSub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    HapticFeedback.lightImpact();
    ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prefs = ref.watch(preferencesProvider);
    final chatState = ref.watch(chatProvider);

    // 自动滚动到底部
    ref.listen<ChatState>(chatProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            if (!prefs.hasAiConfigured) _buildConfigBanner(isDark),
            Expanded(child: _buildMessageList(isDark, chatState)),
            _buildInputBar(isDark, chatState),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 聊天记账',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(chatProvider.notifier).clearChat();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                LucideIcons.trash2,
                size: 16,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.amber.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '请先在「我的 → AI 设置」中配置 AI 服务',
              style: TextStyle(
                color: AppColors.amber,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(bool isDark, ChatState chatState) {
    if (chatState.messages.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        return _ChatBubble(
          message: message,
          isDark: isDark,
          onConfirm: message.transactions != null && message.transactions!.isNotEmpty
              ? () => ref.read(chatProvider.notifier).confirmTransactions(message.transactions!)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.emeraldLight, AppColors.emerald],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.emerald.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            '告诉我你的消费',
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightTextPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '试试说：「午餐花了35」「打车18块」\n长按右侧麦克风按钮即可录音',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark, ChatState chatState) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 实时语音识别文字提示
          if ((_isListening || _isProcessing) && _partialSpeech.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.emerald.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  if (_isProcessing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.emerald,
                      ),
                    )
                  else
                    _buildVoiceWave(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _partialSpeech,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                        fontSize: 14,
                        fontStyle: _isProcessing ? null : FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          // 语音录音中/处理中状态条
          if ((_isListening || _isProcessing) && _partialSpeech.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.emerald.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  if (_isProcessing)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.emerald,
                      ),
                    )
                  else
                    _buildVoiceWave(),
                  const SizedBox(width: 10),
                  Text(
                    _isProcessing ? '正在识别语音...' : '松手结束录音...',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 输入框
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 120),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: !_isListening && !_isProcessing,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: _isProcessing ? '语音识别中...' : (_isListening ? '松手结束...' : '说点什么...'),
                      hintStyle: TextStyle(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 语音按钮（长按录音，松手发送）— 右侧
              GestureDetector(
                onLongPressStart: chatState.isLoading || _isProcessing ? null : (_) => _startVoiceRecord(),
                onLongPressEnd: _isListening ? (_) => _stopVoiceRecord() : null,
                onTapDown: (_) {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isListening
                        ? AppColors.emerald.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: _isListening
                        ? Border.all(color: AppColors.emerald.withValues(alpha: 0.3), width: 1)
                        : null,
                  ),
                  child: Icon(
                    LucideIcons.mic,
                    size: 22,
                    color: _isListening ? AppColors.emerald : AppColors.emerald.withValues(alpha: 0.6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 发送按钮
              GestureDetector(
                onTap: chatState.isLoading || _isListening || _isProcessing ? null : _sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: chatState.isLoading
                        ? AppColors.emerald.withValues(alpha: 0.3)
                        : AppColors.emerald,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: chatState.isLoading
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.emerald.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: chatState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(LucideIcons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 语音波形动画指示器
  Widget _buildVoiceWave() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _VoiceWavePainter()),
    );
  }

  /// 长按开始录音
  Future<void> _startVoiceRecord() async {
    if (_isProcessing) return;

    // 传入 AI 配置（Whisper 降级需要）
    final prefs = ref.read(preferencesProvider);
    _speech.configureWhisper(
      baseUrl: prefs.aiApiBaseUrl,
      apiKey: prefs.aiApiKey,
    );

    // 先检查权限
    final hasPerm = await _speech.hasPermission;
    if (!hasPerm) {
      final granted = await _speech.requestPermission();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('需要麦克风权限才能使用语音记账，请在设置中开启'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    final available = await _speech.isAvailable;
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('语音识别不可用，请检查设备是否支持'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // 开始录音
    HapticFeedback.mediumImpact();
    _focusNode.unfocus();
    await _speech.startListening();

    if (!mounted) return;
    if (_speech.state != SpeechState.listening) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('语音识别启动失败，请重试'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// 松手结束录音，自动识别并发送
  Future<void> _stopVoiceRecord() async {
    HapticFeedback.lightImpact();
    await _speech.stopListening();
    // stopListening 后会触发 onResult 流 → 自动填入文本并调用 _sendMessage()
  }
}

/// 聊天气泡组件
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;
  final VoidCallback? onConfirm;

  const _ChatBubble({
    required this.message,
    required this.isDark,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // 头像 + 气泡
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment:
                message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.emeraldLight, AppColors.emerald],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.emerald
                        : (isDark ? AppColors.darkElevated : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: message.isUser
                          ? const Radius.circular(18)
                          : const Radius.circular(4),
                      bottomRight: message.isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                    ),
                    boxShadow: message.isUser
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : (isDark ? Colors.white : AppColors.lightTextPrimary),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkElevated : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ],
          ),

          // 交易确认卡片
          if (message.transactions != null && message.transactions!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _TransactionConfirmCard(
              transactions: message.transactions!,
              isDark: isDark,
              onConfirm: onConfirm,
            ),
          ],
        ],
      ),
    );
  }
}

/// 交易确认卡片
class _TransactionConfirmCard extends StatelessWidget {
  final List<ParsedTransaction> transactions;
  final bool isDark;
  final VoidCallback? onConfirm;

  const _TransactionConfirmCard({
    required this.transactions,
    required this.isDark,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 42),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.emerald.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt_long_rounded, size: 14, color: AppColors.emerald),
              const SizedBox(width: 6),
              Text(
                '识别到 ${transactions.length} 笔交易',
                style: TextStyle(
                  color: AppColors.emerald,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...transactions.map((tx) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (tx.direction == 'expense' ? AppColors.expense : AppColors.emerald)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    tx.direction == 'expense'
                        ? Icons.north_east_rounded
                        : Icons.south_west_rounded,
                    size: 14,
                    color: tx.direction == 'expense' ? AppColors.expense : AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (tx.categoryName != null)
                        Text(
                          tx.categoryName!,
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  '${tx.direction == 'expense' ? '-' : '+'}¥${tx.amount.toStringAsFixed(2)}',
                  style: oneKeepGrotesk(
                    color: tx.direction == 'expense' ? AppColors.expense : AppColors.emerald,
                    size: 16,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '确认记账',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 语音波形动画指示器
class _VoiceWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.emerald
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final barWidth = 2.5;
    final gap = 2.5;
    final bars = 5;

    for (var i = 0; i < bars; i++) {
      final x = center.dx - ((bars - 1) * (barWidth + gap)) / 2 + i * (barWidth + gap);
      final h = 4.0 + (i % 3) * 3.0 + (i == 2 ? 6.0 : 0.0);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, center.dy), width: barWidth, height: h),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
