/// Native platform export download — save to temp file & share via system sheet.

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> exportDownload(
  List<int> bytes,
  String filename,
  String ext,
) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes);

  final exists = await file.exists();
  if (!exists) {
    throw Exception('文件写入失败');
  }

  // Note: share requires BuildContext for sharePositionOrigin on iPad.
  // For a context-free version, call Share.shareXFiles without it.
  await Share.shareXFiles(
    [XFile(file.path)],
    subject: 'OneKeep 记账数据导出',
  );
}
