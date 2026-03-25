class AuthToken {
  final String accessToken;
  final String refreshToken;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthToken.fromJson(Map<String, dynamic> json) => AuthToken(
        accessToken: json['accessToken'] as String,
        refreshToken: json['refreshToken'] as String,
      );
}
