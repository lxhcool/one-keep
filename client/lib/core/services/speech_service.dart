import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb, kReleaseMode;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'ai_endpoint_utils.dart';
import 'permission_helper_stub.dart'
    if (dart.library.io) 'permission_helper_io.dart';

/// Release 模式下不输出 debug 日志
void _log(String message) {
  if (!kReleaseMode) debugPrint(message);
}

/// 语音识别状态
enum SpeechState {
  notInitialized,
  ready,
  listening,
  processing,
  noPermission,
  error,
}

/// 语音识别服务 - 优先使用系统语音识别，不可用时降级到 Whisper API
class SpeechService {
  static SpeechService? _instance;
  static SpeechService get instance => _instance ??= SpeechService._();

  SpeechService._();

  // 系统语音识别
  final SpeechToText _speech = SpeechToText();

  // Whisper 降级
  final AudioRecorder _recorder = AudioRecorder();
  String? _recordingPath;
  String? _aiBaseUrl;
  String? _aiApiKey;

  bool _useSystemSpeech = false; // 是否使用系统语音
  bool _triedSystemSpeech = false; // 是否已尝试过系统语音
  bool _systemSpeechFailed = false; // 系统语音是否已确认不可用

  SpeechState _state = SpeechState.notInitialized;
  SpeechState get state => _state;

  String _lastRecognized = '';
  String get lastRecognized => _lastRecognized;

  String _partialResult = '';
  String get partialResult => _partialResult;

  final _stateController = StreamController<SpeechState>.broadcast();
  Stream<SpeechState> get onStateChanged => _stateController.stream;

  final _resultController = StreamController<String>.broadcast();
  Stream<String> get onResult => _resultController.stream;

  final _partialController = StreamController<String>.broadcast();
  Stream<String> get onPartialResult => _partialController.stream;

  final _errorController = StreamController<String>.broadcast();
  Stream<String> get onError => _errorController.stream;

  /// 请求麦克风权限，返回是否授予
  Future<bool> requestPermission() => requestMicPermission();

  /// 检查麦克风权限
  Future<bool> get hasPermission => checkMicPermission();

  /// 配置 Whisper API
  void configureWhisper({required String baseUrl, required String apiKey}) {
    _aiBaseUrl = baseUrl;
    _aiApiKey = apiKey;
  }

  /// 检查是否可用：系统语音可用，或已配置音频转写 API。
  Future<bool> get isAvailable async {
    // 移动端检查权限
    if (!kIsWeb) {
      final micGranted = await hasPermission;
      if (!micGranted) return false;
    }
    if (!_triedSystemSpeech) {
      await _initializeSystemSpeech();
    }
    return (_useSystemSpeech && !_systemSpeechFailed) ||
        (_hasWhisperConfig && _supportsAudioTranscription);
  }

  /// 开始录音识别
  Future<void> startListening({String localeId = 'zh_CN'}) async {
    if (_state == SpeechState.listening || _state == SpeechState.processing) {
      return;
    }

    // 移动端检查权限
    if (!kIsWeb) {
      final micGranted = await hasPermission;
      if (!micGranted) {
        final granted = await requestPermission();
        if (!granted) {
          _setState(SpeechState.noPermission);
          _errorController.add('麦克风权限被拒绝，请在系统设置中开启');
          return;
        }
      }
    }

    _lastRecognized = '';
    _partialResult = '';

    if (!_triedSystemSpeech) {
      await _initializeSystemSpeech();
    }

    if (_useSystemSpeech && !_systemSpeechFailed) {
      await _startSystemListening(localeId);
    } else {
      await _startWhisperRecording();
    }
  }

  /// 停止录音
  Future<void> stopListening() async {
    if (_useSystemSpeech && !_systemSpeechFailed) {
      if (_state != SpeechState.listening) return;
      await _speech.stop();
      _setState(SpeechState.ready);
    } else {
      await _stopWhisperAndRecognize();
    }
  }

  /// 取消录音
  Future<void> cancelListening() async {
    if (_useSystemSpeech && !_systemSpeechFailed) {
      if (_state != SpeechState.listening) return;
      await _speech.cancel();
    } else {
      if (_state != SpeechState.listening) return;
      try {
        await _recorder.stop();
      } catch (_) {}
    }
    _lastRecognized = '';
    _partialResult = '';
    _setState(SpeechState.ready);
  }

  // ==================== 系统语音识别 ====================

  bool get _hasWhisperConfig =>
      _aiBaseUrl != null &&
      _aiBaseUrl!.isNotEmpty &&
      _aiApiKey != null &&
      _aiApiKey!.isNotEmpty;

  bool get _supportsAudioTranscription {
    final baseUrl = (_aiBaseUrl ?? '').toLowerCase();
    if (baseUrl.contains('deepseek.com')) return false;
    return true;
  }

  String get _transcriptionModel {
    final baseUrl = (_aiBaseUrl ?? '').toLowerCase();
    if (baseUrl.contains('openai.com')) return 'whisper-1';
    return 'FunAudioLLM/SenseVoiceSmall';
  }

  Future<void> _initializeSystemSpeech() async {
    _triedSystemSpeech = true;
    try {
      final available = await _speech.initialize(
        onError: _onSystemError,
        onStatus: _onSystemStatus,
        debugLogging: false,
      );
      if (available) {
        _useSystemSpeech = true;
        _systemSpeechFailed = false;
        _log('[SpeechService] using system speech recognition');
      } else {
        _systemSpeechFailed = true;
        _log('[SpeechService] system speech not available, will use Whisper');
      }
    } catch (e) {
      _systemSpeechFailed = true;
      _log('[SpeechService] system speech init failed: $e, will use Whisper');
    }
  }

  Future<void> _startSystemListening(String localeId) async {
    _setState(SpeechState.listening);

    try {
      await _speech.listen(
        onResult: _onSystemSpeechResult,
        localeId: localeId,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      );

      if (!_speech.isListening) {
        await _fallbackToWhisperOrError('系统语音未能开始监听');
      }
    } catch (e) {
      _log('[SpeechService] system listen failed: $e');
      await _fallbackToWhisperOrError('系统语音启动失败');
    }
  }

  void _onSystemSpeechResult(SpeechRecognitionResult result) {
    _partialResult = result.recognizedWords;

    if (result.finalResult) {
      _lastRecognized = result.recognizedWords;
      if (_lastRecognized.trim().isEmpty) {
        _errorController.add('语音识别结果为空，请再试一次');
      } else {
        _resultController.add(_lastRecognized);
      }
      _setState(SpeechState.ready);
    } else {
      _partialController.add(_partialResult);
    }
  }

  void _onSystemStatus(String status) {
    switch (status) {
      case 'listening':
        _setState(SpeechState.listening);
        break;
      case 'notListening':
        if (_state == SpeechState.listening) {
          _setState(SpeechState.ready);
        }
        break;
      case 'done':
        _setState(SpeechState.ready);
        break;
    }
  }

  void _onSystemError(SpeechRecognitionError error) {
    _log(
      '[SpeechService] system error: ${error.errorMsg}, permanent: ${error.permanent}',
    );

    final canFallback =
        error.permanent &&
        error.errorMsg != 'error_no_speech' &&
        error.errorMsg != 'error_no_match';

    if (canFallback) {
      _systemSpeechFailed = true;
      _useSystemSpeech = false;
      if (_hasWhisperConfig) {
        unawaited(_startWhisperRecording());
        return;
      }
    }

    final msg = _friendlyErrorMsg(error.errorMsg);
    _errorController.add(msg);

    if (error.permanent) {
      _setState(SpeechState.ready);
    } else {
      _setState(SpeechState.ready);
    }
  }

  Future<void> _fallbackToWhisperOrError(String reason) async {
    _systemSpeechFailed = true;
    _useSystemSpeech = false;
    _log('[SpeechService] $reason, will use Whisper if configured');
    if (_hasWhisperConfig) {
      await _startWhisperRecording();
      return;
    }
    _errorController.add('$reason，请检查设备语音服务或在 AI 设置中配置支持音频转写的服务');
    _setState(SpeechState.error);
  }

  // ==================== Whisper API 识别 ====================

  Future<void> _startWhisperRecording() async {
    if (_aiBaseUrl == null ||
        _aiBaseUrl!.isEmpty ||
        _aiApiKey == null ||
        _aiApiKey!.isEmpty) {
      _errorController.add('未配置 AI 服务，无法使用语音输入');
      _setState(SpeechState.error);
      return;
    }

    if (!_supportsAudioTranscription) {
      _errorController.add(
        '当前 AI 服务不支持语音转写，请在 AI 设置切换到硅基流动或 OpenAI 等支持音频转写的服务',
      );
      _setState(SpeechState.error);
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      _recordingPath = '${dir.path}/speech_recording.m4a';

      // 删除旧文件
      final oldFile = File(_recordingPath!);
      if (await oldFile.exists()) {
        await oldFile.delete();
      }

      _setState(SpeechState.listening);

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: _recordingPath!,
      );

      _log('[SpeechService] Whisper recording started');
    } catch (e) {
      _log('[SpeechService] whisper recording start failed: $e');
      _errorController.add('录音启动失败：$e');
      _setState(SpeechState.error);
    }
  }

  Future<void> _stopWhisperAndRecognize() async {
    if (_state != SpeechState.listening) return;

    try {
      // 停止录音
      final path = await _recorder.stop();
      _log('[SpeechService] recording stopped, path: $path');

      _setState(SpeechState.processing);

      if (path == null) {
        _errorController.add('录音失败');
        _setState(SpeechState.ready);
        return;
      }

      // 检查文件
      final file = File(path);
      if (!await file.exists()) {
        _errorController.add('录音文件不存在');
        _setState(SpeechState.ready);
        return;
      }

      final fileSize = await file.length();
      _log('[SpeechService] audio file size: $fileSize bytes');

      if (fileSize < 100) {
        _errorController.add('录音时间太短，请再说一次');
        _setState(SpeechState.ready);
        return;
      }

      // 调用 Whisper API
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 60);

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(path, filename: 'audio.m4a'),
        'model': _transcriptionModel,
      });

      final apiUrl = aiAudioTranscriptionsUrl(_aiBaseUrl!);
      _log('[SpeechService] calling API: $apiUrl');

      final response = await dio.post(
        apiUrl,
        data: formData,
        options: Options(headers: {'Authorization': 'Bearer $_aiApiKey'}),
      );

      final text = response.data['text'] as String? ?? '';
      _log('[SpeechService] Whisper result: "$text"');

      if (text.trim().isEmpty) {
        _errorController.add('语音识别结果为空，请再试一次');
      } else {
        _lastRecognized = text.trim();
        _resultController.add(_lastRecognized);
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final respBody = e.response?.data?.toString() ?? '';
      _log(
        '[SpeechService] API error: $statusCode ${e.message}, body: $respBody',
      );
      if (statusCode == 404) {
        _errorController.add('语音识别接口不存在(404)，请确认 AI Base URL 是否为支持音频转写的服务');
      } else if (statusCode == 401) {
        _errorController.add('API Key 无效(401)，请检查 AI 设置');
      } else if (statusCode == 400) {
        _errorController.add('请求参数错误(400)：$respBody');
      } else {
        _errorController.add('语音识别失败($statusCode)：${e.message ?? "网络错误"}');
      }
    } catch (e) {
      _log('[SpeechService] whisper recognize failed: $e');
      _errorController.add('语音识别失败：$e');
    }

    _setState(SpeechState.ready);
  }

  // ==================== 工具方法 ====================

  static String _friendlyErrorMsg(String code) {
    switch (code) {
      case 'error_permission':
      case 'error_audio_error':
        return '麦克风权限被拒绝，请在系统设置中开启';
      case 'error_no_speech':
        return '没有检测到语音，请靠近麦克风再试';
      case 'error_no_match':
        return '未能识别语音内容，请说清楚一点再试';
      case 'error_speech_timeout':
        return '语音超时，请在点击后立即开始说话';
      case 'error_network':
        return '网络不可用，语音识别需要网络连接';
      case 'error_busy':
        return '语音服务繁忙，请稍后再试';
      case 'error_server':
        return '语音服务暂时不可用，请稍后再试';
      case 'error_client':
        return '语音识别客户端错误，请重试';
      default:
        return '语音识别出错：$code';
    }
  }

  void _setState(SpeechState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  void dispose() {
    _stateController.close();
    _resultController.close();
    _partialController.close();
    _errorController.close();
    _recorder.dispose();
  }
}
