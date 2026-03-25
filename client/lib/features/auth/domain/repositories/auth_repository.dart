import '../entities/auth_token.dart';

abstract interface class AuthRepository {
  Future<AuthToken> login({
    required String email,
    required String password,
  });

  Future<AuthToken> register({
    required String email,
    required String password,
    required String displayName,
  });
}
