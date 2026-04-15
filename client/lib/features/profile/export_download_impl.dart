/// Platform-aware export download.
///
/// On native platforms (default): saves to temp dir & shares via system sheet.
/// On Web (dart.library.html): triggers browser download via Blob URL + anchor click.
///
/// Uses Dart's conditional import to select at compile time:
///   - [export_download_native.dart] for native (iOS/Android/macOS/Windows/Linux)
///   - [export_download_web.dart] for web

export 'export_download_native.dart'
    if (dart.library.html) 'export_download_web.dart';
