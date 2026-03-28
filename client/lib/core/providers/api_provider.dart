import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

const _defaultApiBaseUrl = 'https://onekeep.lxhcoool.cn';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: _resolveApiBaseUrl());
});

String _resolveApiBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;

  // Local development now targets the deployed API by default.
  if (kIsWeb) return _defaultApiBaseUrl;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    default:
      return _defaultApiBaseUrl;
  }
}
