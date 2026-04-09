/// Web/Desktop 端的权限 stub - 不调用 permission_handler

/// 请求麦克风权限
Future<bool> requestMicPermission() async => true;

/// 检查麦克风权限
Future<bool> checkMicPermission() async => true;
