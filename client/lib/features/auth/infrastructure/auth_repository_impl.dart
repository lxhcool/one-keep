import 'package:dio/dio.dart';
import '../domain/entities/auth_token.dart';
import '../domain/repositories/auth_repository.dart';
import '../../../core/network/api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<AuthToken> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _apiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return AuthToken.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  @override
  Future<AuthToken> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final res = await _apiClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'displayName': displayName,
        },
      );
      return AuthToken.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    final code = e.response?.statusCode;
    final msg = e.response?.data is Map
        ? (e.response!.data as Map)['message']
        : null;
    if (code == 409) return Exception('该邮箱已被注册');
    if (code == 401) return Exception('邮箱或密码错误');
    if (msg != null) return Exception(msg.toString());
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return Exception('连接超时，请检查网络');
    }
    return Exception('网络错误，请稍后重试');
  }
}
