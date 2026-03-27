import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const _tokenKey = 'jwt_token';
  static final _storage = FlutterSecureStorage();

  late final Dio dio;

  ApiClient({String baseUrl = 'http://localhost:3000'}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          final method = options.method.toUpperCase();
          if (options.data == null &&
              (method == 'GET' || method == 'DELETE' || method == 'HEAD')) {
            options.contentType = null;
            options.headers.remove('Content-Type');
          } else if (options.data != null && options.contentType == null) {
            options.contentType = Headers.jsonContentType;
            options.headers['Content-Type'] = Headers.jsonContentType;
          }
          handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token 过期，清除本地 token
            _storage.delete(key: _tokenKey);
          }
          handler.next(error);
        },
      ),
    );
  }

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  static Future<void> clearToken() => _storage.delete(key: _tokenKey);

  static Future<String?> getToken() => _storage.read(key: _tokenKey);

  static String readableError(Object error, {String fallback = '请求失败'}) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
      final statusCode = error.response?.statusCode;
      if (statusCode != null) {
        return '$fallback（HTTP $statusCode）';
      }
    }
    return fallback;
  }
}
