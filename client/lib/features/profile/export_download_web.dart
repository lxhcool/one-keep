/// Web platform export download — trigger browser native download via Blob URL.
///
/// Uses dart:html (available in Flutter 3.x) for DOM / download APIs.

import 'dart:html' as html;

Future<void> exportDownload(
  List<int> bytes,
  String filename,
  String ext,
) async {
  final mime = ext == 'xlsx'
      ? 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      : 'text/csv;charset=utf-8';

  final blob = html.Blob([bytes], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..download = filename;

  // Add to body so click works, then immediately remove
  html.document.body!.nodes.add(anchor);
  anchor.click();
  anchor.remove();
  Future.delayed(const Duration(seconds: 10), () {
    html.Url.revokeObjectUrl(url);
  });
}
