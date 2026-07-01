import 'dart:convert';

import 'package:dio/dio.dart';

/// AI 服务 - 封装 OpenAI 兼容 API 的聊天补全调用
class AiService {
  final String baseUrl;
  final String apiKey;
  final String model;

  AiService({
    required this.baseUrl,
    required this.apiKey,
    this.model = 'deepseek-v4-flash',
  });

  /// 发送聊天消息，以流式方式返回 AI 响应
  Stream<String> chatStream({
    required List<Map<String, String>> messages,
  }) async* {
    var base = baseUrl.replaceAll(RegExp(r'/+$'), '');
    if (base.endsWith('/v1')) {
      base = base.substring(0, base.length - 3);
    }
    final url = '$base/v1/chat/completions';
    final dio = Dio();
    dio.options.headers = {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    };
    dio.options.sendTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(minutes: 5);

    final body = jsonEncode({
      'model': model,
      'messages': messages,
      'stream': true,
      'temperature': 0.3,
    });

    try {
      final response = await dio.post<ResponseBody>(
        url,
        data: body,
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data?.stream;
      if (stream == null) {
        yield* Stream.error('响应流为空');
        return;
      }

      final buffer = StringBuffer();
      await for (final chunk in stream) {
        final text = utf8.decode(chunk, allowMalformed: true);
        buffer.write(text);

        // 按行解析 SSE 数据
        final lines = buffer.toString().split('\n');
        buffer.clear();

        for (var i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') return;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List<dynamic>?;
            if (choices == null || choices.isEmpty) continue;
            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            if (delta == null) continue;
            final content = delta['content'] as String?;
            if (content != null && content.isNotEmpty) {
              yield content;
            }
          } catch (_) {
            // 跳过无法解析的行
          }
        }

        // 保留最后一行（可能不完整）
        if (lines.isNotEmpty) {
          buffer.write(lines.last);
        }
      }
    } on DioException catch (e) {
      String msg;
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        msg = '连接超时，请检查网络或稍后重试';
      } else if (e.response?.statusCode != null) {
        final code = e.response!.statusCode!;
        switch (code) {
          case 401: msg = 'API Key 无效'; break;
          case 403: msg = 'API 访问被拒绝'; break;
          case 404: msg = '接口不存在，请检查 API 地址和模型名'; break;
          case 429: msg = '请求过于频繁，请稍后重试'; break;
          case 500: case 502: case 503: case 504:
            msg = 'AI 服务暂时不可用（HTTP $code），请稍后重试';
            break;
          default:
            msg = 'AI 服务请求失败（HTTP $code）';
        }
      } else {
        msg = '无法连接到 AI 服务，请检查网络';
      }
      yield* Stream.error(msg);
    } catch (e) {
      yield* Stream.error('AI 服务异常：${e.toString().split('\n').first}');
    }
  }

  /// 非流式聊天 - 等待完整响应
  Future<String> chat({
    required List<Map<String, String>> messages,
  }) async {
    final buffer = StringBuffer();
    await for (final chunk in chatStream(messages: messages)) {
      buffer.write(chunk);
    }
    return buffer.toString();
  }
}
