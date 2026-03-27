import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  AuthNotifier(this._api) : super(const AuthState()) {
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await ApiClient.getToken();
    state = state.copyWith(
      status: token != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated,
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = res.data as Map<String, dynamic>;
      await ApiClient.saveToken(data['token'] as String);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserInfo.fromJson(data['user'] as Map<String, dynamic>),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiClient.readableError(e, fallback: '登录失败'),
      );
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _api.dio.post(
        '/api/auth/register',
        data: {'email': email, 'password': password, 'name': name},
      );
      final data = res.data as Map<String, dynamic>;
      await ApiClient.saveToken(data['token'] as String);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: UserInfo.fromJson(data['user'] as Map<String, dynamic>),
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
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void updateLocalUser({String? name}) {
    if (state.user == null) return;
    state = state.copyWith(user: state.user!.copyWith(name: name));
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(apiClientProvider));
});
