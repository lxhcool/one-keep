/// 内置默认 AI 配置（开箱即用）
/// 把下面的 apiKey 替换成你的 DeepSeek API Key 即可
class AiDefaults {
  static const String baseUrl = 'https://api.deepseek.com/v1';

  /// TODO: 替换成你的 DeepSeek API Key
  /// 可以从 https://platform.deepseek.com/api_keys 获取
  static const String apiKey = 'sk-f664ab9d4ec14bdfac4e281104808d6f';

  static const String modelName = 'deepseek-v4-flash';
}
