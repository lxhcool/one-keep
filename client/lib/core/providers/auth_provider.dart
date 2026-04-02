import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_client.dart';
import '../../shared/models/models.dart';
import 'api_provider.dart';

/// 认证状态
enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserInfo? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserInfo? user,
    bool? isLoading,
    String? error,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _api;
  static const _storage = FlutterSecureStorage();
  static const _currentUserKey = 'auth_current_user';

  AuthNotifier(this._api) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ApiClient.getToken();
    if (token == null) {
      await _storage.delete(key: _currentUserKey);
      state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      return;
    }

    try {
      final res = await _api.dio.get('/api/auth/me');
      final data = res.data as Map<String, dynamic>;
      final user = UserInfo.fromJson(
        Map<String, dynamic>.from(data['user'] as Map<String, dynamic>),
      );
      await _writeStoredUser(user);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      );
    } catch (_) {
      await ApiClient.clearToken();
      await _storage.delete(key: _currentUserKey);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    }
  }

  Future<void> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.dio.post(
        '/api/auth/login',
        data: {'identifier': identifier, 'password': password},
      );
      final data = res.data as Map<String, dynamic>;
      final user = Map<String, dynamic>.from(
        data['user'] as Map<String, dynamic>,
      );
      user['name'] ??= user['displayName'];
      final userInfo = UserInfo.fromJson(user);
      await ApiClient.saveToken(data['token'] as String);
      await _writeStoredUser(userInfo);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userInfo,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiClient.readableError(e, fallback: '登录失败'),
      );
    }
  }

  Future<void> register(
    String username,
    String email,
    String password,
    String displayName,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.dio.post(
        '/api/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'displayName': displayName,
        },
      );
      final data = res.data as Map<String, dynamic>;
      final user = Map<String, dynamic>.from(
        data['user'] as Map<String, dynamic>,
      );
      user['name'] ??= user['displayName'];
      final userInfo = UserInfo.fromJson(user);
      await ApiClient.saveToken(data['token'] as String);
      await _writeStoredUser(userInfo);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userInfo,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiClient.readableError(e, fallback: '注册失败'),
      );
    }
  }

  Future<void> logout() async {
    await ApiClient.clearToken();
    await _storage.delete(key: _currentUserKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void updateLocalUser({String? name}) {
    if (state.user == null) return;
    final user = state.user!.copyWith(name: name);
    state = state.copyWith(user: user);
    _writeStoredUser(user);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> _writeStoredUser(UserInfo user) {
    return _storage.write(
      key: _currentUserKey,
      value: jsonEncode({
        'id': user.id,
        'username': user.username,
        'name': user.name,
        'email': user.email,
      }),
    );
  }

}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiClientProvider));
});
