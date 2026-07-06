import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

const _defaultApiBaseUrl = 'https://liqing.eatdesk.net';
const _localApiBaseUrl = 'http://192.168.10.231:3002';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(baseUrl: _resolveApiBaseUrl());
});

String _resolveApiBaseUrl() {
  const override = String.fromEnvironment('API_BASE_URL');
  if (override.isNotEmpty) return override;

  if (kIsWeb) {
    final origin = Uri.base.origin;
    final isLocalHost =
        Uri.base.host == 'localhost' || Uri.base.host == '127.0.0.1';
    if (kReleaseMode || !isLocalHost) {
      return origin;
    }
  }

  if (kReleaseMode) return _defaultApiBaseUrl;

  return _localApiBaseUrl;
}
