import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

const _defaultApiBaseUrl = 'https://onekeep.lxhcoool.cn';
const _androidEmulatorApiBaseUrl = 'http://10.0.2.2:3001';
const _localApiBaseUrl = 'http://127.0.0.1:3001';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: _resolveApiBaseUrl());
});

String _resolveApiBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;

  if (kReleaseMode || kIsWeb) return _defaultApiBaseUrl;

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return _androidEmulatorApiBaseUrl;
    default:
      return _localApiBaseUrl;
  }
}
