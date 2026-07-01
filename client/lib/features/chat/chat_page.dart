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

// 聊天页配色常量
const _chatHeroGradient = [Color(0xFF065F46), Color(0xFF047857)];
const _chatDarkHeroGradient = [Color(0xFF064E3B), Color(0xFF0D1111)];

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

  // 输入模式：voice = 语音优先，text = 键盘输入
  bool _textMode = false;

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
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: Column(
        children: [
          _buildHeader(isDark),
          if (!prefs.hasAiConfigured) _buildConfigBanner(isDark),
          Expanded(child: _buildMessageList(isDark, chatState)),
          _buildInputBar(isDark, chatState),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    final topPadding = MediaQuery.of(context).padding.top;
    final gradient = isDark ? _chatDarkHeroGradient : _chatHeroGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topPadding),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                // 返回按钮
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // 标题区
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.smart_toy_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI 聊天记账',
                            style: oneKeepManrope(
                              color: Colors.white,
                              size: 18,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '说出消费，AI 智能识别',
                        style: oneKeepInter(
                          color: Colors.white.withValues(alpha: 0.65),
                          size: 12,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // 清空按钮
                GestureDetector(
                  onTap: () => ref.read(chatProvider.notifier).clearChat(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      LucideIcons.trash2,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.amber.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '请先在「我的 → AI 设置」中配置 AI 服务',
              style: oneKeepInter(
                color: AppColors.amber,
                size: 13,
                weight: FontWeight.w600,
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final message = chatState.messages[index];
        final isConfirming = chatState.isTransactionConfirming(message.id);
        final isConfirmed = chatState.isTransactionConfirmed(message.id);
        return _ChatBubble(
          message: message,
          isDark: isDark,
          isConfirming: isConfirming,
          isConfirmed: isConfirmed,
          onConfirm:
              message.transactions != null &&
                  message.transactions!.isNotEmpty &&
                  !isConfirming &&
                  !isConfirmed
              ? () => ref
                    .read(chatProvider.notifier)
                    .confirmTransactions(message.id, message.transactions!)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    final suggestions = ['午餐花了35元', '打车18块', '收到工资5000', '买咖啡28'];
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.emeraldLight, AppColors.emerald],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emerald.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '告诉我你的消费',
              style: oneKeepManrope(
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                size: 22,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '用自然语言描述，AI 自动识别金额与分类\n长按麦克风即可语音输入',
              textAlign: TextAlign.center,
              style: oneKeepInter(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                size: 14,
                weight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: suggestions
                  .map(
                    (s) => GestureDetector(
                      onTap: () {
                        _textController.text = s;
                        setState(() {});
                        _sendMessage();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.2 : 0.04,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          s,
                          style: oneKeepInter(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            size: 13,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool isDark, ChatState chatState) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBg.withValues(alpha: 0.85)
                : AppColors.lightSurface.withValues(alpha: 0.9),
            border: Border(
              top: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.5,
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(16, 14, 16, 14 + bottomInset),
          child: _textMode
              ? _buildTextInputRow(isDark, chatState)
              : _buildVoiceInputRow(isDark, chatState),
        ),
      ),
    );
  }

  // ── 语音模式主视图 ──────────────────────────────────────────
  Widget _buildVoiceInputRow(bool isDark, ChatState chatState) {
    final isActive = _isListening || _isProcessing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 录音状态/识别文字提示
        if (isActive)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.emerald.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                if (_isProcessing)
                  SizedBox(
                    width: 18,
                    height: 18,
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
                    _partialSpeech.isNotEmpty
                        ? _partialSpeech
                        : (_isProcessing ? '正在识别语音...' : '松手结束录音...'),
                    style: oneKeepInter(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      size: 13,
                      weight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        Row(
          children: [
            // 切换到键盘模式
            GestureDetector(
              onTap: () {
                setState(() => _textMode = true);
                Future.delayed(const Duration(milliseconds: 80), () {
                  _focusNode.requestFocus();
                });
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurface
                      : AppColors.lightInputBg,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightInputBorder,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  LucideIcons.keyboard,
                  size: 19,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── 主麦克风按钮（核心） ──
            Expanded(
              child: GestureDetector(
                onLongPressStart: chatState.isLoading || _isProcessing
                    ? null
                    : (_) => _startVoiceRecord(),
                onLongPressEnd: _isListening ? (_) => _stopVoiceRecord() : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? null
                        : const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.emeraldLight, AppColors.emerald],
                          ),
                    color: isActive
                        ? AppColors.emerald.withValues(alpha: 0.12)
                        : null,
                    borderRadius: BorderRadius.circular(17),
                    border: isActive
                        ? Border.all(
                            color: AppColors.emerald.withValues(alpha: 0.35),
                            width: 1.5,
                          )
                        : null,
                    boxShadow: isActive
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.emerald.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isProcessing) ...[
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: isActive ? AppColors.emerald : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '识别中...',
                          style: oneKeepManrope(
                            color: AppColors.emerald,
                            size: 15,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ] else if (_isListening) ...[
                        _buildVoiceWave(),
                        const SizedBox(width: 10),
                        Text(
                          '松手发送',
                          style: oneKeepManrope(
                            color: AppColors.emerald,
                            size: 15,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ] else ...[
                        Icon(LucideIcons.mic, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          '长按说话',
                          style: oneKeepManrope(
                            color: Colors.white,
                            size: 15,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── 文字输入模式 ──────────────────────────────────────────
  Widget _buildTextInputRow(bool isDark, ChatState chatState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 切换回语音
        GestureDetector(
          onTap: () {
            _focusNode.unfocus();
            setState(() => _textMode = false);
          },
          child: Container(
            width: 44,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightInputBg,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightInputBorder,
                width: 0.5,
              ),
            ),
            child: Icon(LucideIcons.mic, size: 19, color: AppColors.emerald),
          ),
        ),
        const SizedBox(width: 10),

        // 输入框
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 120, minHeight: 48),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightInputBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppColors.darkBorder
                    : AppColors.lightInputBorder,
                width: 0.5,
              ),
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: oneKeepInter(
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                size: 15,
                weight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: '说点什么，AI 来记账...',
                hintStyle: oneKeepInter(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                  size: 15,
                  weight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // 发送按钮
        GestureDetector(
          onTap: chatState.isLoading ? null : _sendMessage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: chatState.isLoading
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.emeraldLight, AppColors.emerald],
                    ),
              color: chatState.isLoading
                  ? AppColors.emerald.withValues(alpha: 0.3)
                  : null,
              borderRadius: BorderRadius.circular(14),
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
                ? const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : const Icon(LucideIcons.send, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  /// 语音波形动画指示器
  Widget _buildVoiceWave() {
    return SizedBox(
      width: 18,
      height: 18,
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
  final bool isConfirming;
  final bool isConfirmed;

  const _ChatBubble({
    required this.message,
    required this.isDark,
    this.onConfirm,
    this.isConfirming = false,
    this.isConfirmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: message.isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              // AI 头像
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
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              // 气泡
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.emeraldLight, AppColors.emerald],
                          )
                        : null,
                    color: message.isUser
                        ? null
                        : (isDark ? AppColors.darkSurface : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(message.isUser ? 18 : 5),
                      bottomRight: Radius.circular(message.isUser ? 5 : 18),
                    ),
                    border: message.isUser
                        ? null
                        : Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            width: 0.5,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.05,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: oneKeepInter(
                      color: message.isUser
                          ? Colors.white
                          : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary),
                      size: 15,
                      weight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              // 用户头像
              if (message.isUser) ...[
                const SizedBox(width: 10),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightInputBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ],
          ),

          // 交易确认卡片
          if (message.transactions != null &&
              message.transactions!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _TransactionConfirmCard(
              transactions: message.transactions!,
              isDark: isDark,
              onConfirm: onConfirm,
              isConfirming: isConfirming,
              isConfirmed: isConfirmed,
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
  final bool isConfirming;
  final bool isConfirmed;

  const _TransactionConfirmCard({
    required this.transactions,
    required this.isDark,
    this.onConfirm,
    this.isConfirming = false,
    this.isConfirmed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 42),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 卡片标题行
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 13,
                    color: AppColors.emerald,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '识别到 ${transactions.length} 笔交易',
                  style: oneKeepManrope(
                    color: AppColors.emerald,
                    size: 13,
                    weight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          // 交易列表
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                ...transactions.map(
                  (tx) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color:
                                (tx.direction == 'expense'
                                        ? AppColors.expense
                                        : AppColors.emerald)
                                    .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            tx.direction == 'expense'
                                ? Icons.north_east_rounded
                                : Icons.south_west_rounded,
                            size: 15,
                            color: tx.direction == 'expense'
                                ? AppColors.expense
                                : AppColors.emerald,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.title,
                                style: oneKeepManrope(
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                  size: 14,
                                  weight: FontWeight.w600,
                                ),
                              ),
                              if (tx.categoryName != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  tx.categoryName!,
                                  style: oneKeepInter(
                                    color: isDark
                                        ? AppColors.darkTextTertiary
                                        : AppColors.lightTextTertiary,
                                    size: 11,
                                    weight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          '${tx.direction == 'expense' ? '-' : '+'}¥${tx.amount.toStringAsFixed(2)}',
                          style: oneKeepGrotesk(
                            color: tx.direction == 'expense'
                                ? AppColors.expense
                                : AppColors.emerald,
                            size: 16,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 确认按钮
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isConfirming || isConfirmed ? null : onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: isConfirming
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            isConfirmed ? '已记账' : '确认记账',
                            style: oneKeepManrope(
                              color: Colors.white,
                              size: 15,
                              weight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
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
      final x =
          center.dx -
          ((bars - 1) * (barWidth + gap)) / 2 +
          i * (barWidth + gap);
      final h = 4.0 + (i % 3) * 3.0 + (i == 2 ? 6.0 : 0.0);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, center.dy),
          width: barWidth,
          height: h,
        ),
        Radius.circular(barWidth / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
