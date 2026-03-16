class AppConstants {
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String geminiModel = 'gemini-2.5-flash';

  static const String prefKeyApiKey = 'gemini_api_key';
  static const String prefKeyThemeMode = 'theme_mode';
  static const String prefKeyAuthToken = 'auth_token';

  static const String hiveCacheBox = 'llm_cache';
  static const Duration hiveCacheTtl = Duration(hours: 24);

  static const int minMerchantNameLength = 1;
  static const int maxMerchantNameLength = 255;
  static const double minAmount = 0.01;

  static const List<String> defaultCategories = [
    'food',
    'transport',
    'shopping',
    'entertainment',
    'health',
    'education',
    'utilities',
    'other',
  ];
}
