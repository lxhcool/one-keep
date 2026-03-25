import 'package:dio/dio.dart';
import '../env.dart';
import '../storage/token_storage.dart';

/// 全局 Dio 实例，附带 JWT 自动刷新拦截器。
class ApiClient {
  late final Dio dio;

  ApiClient(TokenStorage tokenStorage, {VoidCallback? onAuthExpired}) {
    dio = Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.add(
      _AuthInterceptor(dio, tokenStorage, Env.baseUrl,
          onAuthExpired: onAuthExpired),
    );
  }
}

/// QueuedInterceptorsWrapper 保证并发 401 只触发一次 refresh。
class _AuthInterceptor extends QueuedInterceptorsWrapper {
  final Dio _dio;
  final TokenStorage _storage;
  final VoidCallback? onAuthExpired;

  /// 独立 Dio 实例，用于刷新请求，避免循环拦截。
  late final Dio _refreshDio;

  _AuthInterceptor(this._dio, this._storage, String baseUrl,
      {this.onAuthExpired}) {
    _refreshDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    // 只处理 401，且不是 refresh 接口本身
    final isRefreshRoute =
        err.requestOptions.path.contains('/auth/refresh');
    if (err.response?.statusCode == 401 && !isRefreshRoute) {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken != null) {
        try {
          final res = await _refreshDio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );
          final newAccess = res.data['accessToken'] as String;
          final newRefresh = res.data['refreshToken'] as String;
          await _storage.saveTokens(
              accessToken: newAccess, refreshToken: newRefresh);
          // 用新 token 重试原始请求
          err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
          final retried = await _dio.fetch(err.requestOptions);
          handler.resolve(retried);
          return;
        } catch (_) {
          await _storage.deleteTokens();
          onAuthExpired?.call();
        }
      } else {
        onAuthExpired?.call();
      }
    }
    handler.next(err);
  }
}

typedef VoidCallback = void Function();
