import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/repositories/auth_repository.dart';
import '../infrastructure/auth_repository_impl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

// ─── Providers ───────────────────────────────────────────────────────────────

final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.read(tokenStorageProvider);
  return ApiClient(
    storage,
    onAuthExpired: () =>
        ref.read(authProvider.notifier)._forceUnauthenticated(),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(apiClientProvider));
});

// ─── Notifier ────────────────────────────────────────────────────────────────

/// `null` = 初始化中（检查本地 token）
/// `true`  = 已登录
/// `false` = 未登录
class AuthNotifier extends Notifier<bool?> {
  @override
  bool? build() {
    _checkAuth();
    return null;
  }

  Future<void> _checkAuth() async {
    final has = await ref.read(tokenStorageProvider).hasTokens();
    state = has;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final token = await repo.login(email: email, password: password);
    await ref.read(tokenStorageProvider).saveTokens(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
        );
    state = true;
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final repo = ref.read(authRepositoryProvider);
    final token = await repo.register(
        email: email, password: password, displayName: displayName);
    await ref.read(tokenStorageProvider).saveTokens(
          accessToken: token.accessToken,
          refreshToken: token.refreshToken,
        );
    state = true;
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).deleteTokens();
    state = false;
  }

  // 由 ApiClient 的 onAuthExpired 回调触发
  void _forceUnauthenticated() => state = false;
}

final authProvider = NotifierProvider<AuthNotifier, bool?>(AuthNotifier.new);
