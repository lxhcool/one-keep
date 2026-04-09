/// 移动端（iOS/Android）权限实现 - 使用 permission_handler

import 'package:permission_handler/permission_handler.dart';

/// 请求麦克风权限
Future<bool> requestMicPermission() async {
  final status = await Permission.microphone.request();
  if (status.isGranted) return true;
  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }
  return false;
}

/// 检查麦克风权限
Future<bool> checkMicPermission() async {
  final status = await Permission.microphone.status;
  return status.isGranted;
}
