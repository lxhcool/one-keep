import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

const _defaultApiBaseUrl = 'https://onekeep.lxhcoool.cn';
const _localApiBaseUrl = 'http://192.168.10.231:3002';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: _resolveApiBaseUrl());
});

String _resolveApiBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;

  if (kReleaseMode) return _defaultApiBaseUrl;

  return _localApiBaseUrl;
}
