String aiChatCompletionsUrl(String input) {
  final base = _normalized(input);
  if (base.endsWith('/chat/completions')) return base;
  if (base.endsWith('/v1')) return '$base/chat/completions';
  return '$base/v1/chat/completions';
}

String aiModelsUrl(String input) {
  final base = _normalized(input);
  if (base.endsWith('/models')) return base;
  if (base.endsWith('/v1')) return '$base/models';
  return '$base/v1/models';
}

String aiAudioTranscriptionsUrl(String input) {
  final base = _normalized(input);
  if (base.endsWith('/audio/transcriptions')) return base;
  if (base.endsWith('/v1')) return '$base/audio/transcriptions';
  return '$base/v1/audio/transcriptions';
}

String _normalized(String input) => input.trim().replaceAll(RegExp(r'/+$'), '');
