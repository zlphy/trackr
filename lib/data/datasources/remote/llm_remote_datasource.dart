import '../../../core/network/gemini_client.dart';
import '../../../data/models/llm_response_model.dart';
import '../local/hive_cache_datasource.dart';

abstract class LLMRemoteDataSource {
  Future<Map<String, dynamic>> categorizeExpense({
    required String receiptText,
    required double amount,
    required String merchantName,
  });
}

class LLMRemoteDataSourceImpl implements LLMRemoteDataSource {
  final GeminiClient geminiClient;
  final HiveCacheDataSource cacheDataSource;

  LLMRemoteDataSourceImpl(this.geminiClient, this.cacheDataSource);

  @override
  Future<Map<String, dynamic>> categorizeExpense({
    required String receiptText,
    required double amount,
    required String merchantName,
  }) async {
    final cacheKey = '$merchantName-$amount';

    final cached = await cacheDataSource.getCachedCategory(cacheKey);
    if (cached != null) {
      return {'category': cached, 'source': 'cache'};
    }

    final prompt = '''
คุณเป็นผู้ช่วยจัดหมวดหมู่ค่าใช้จ่าย กรุณาวิเคราะห์ข้อมูลใบเสร็จต่อไปนี้และตอบกลับด้วย JSON เท่านั้น

ชื่อร้านค้า: $merchantName
จำนวนเงิน: $amount บาท
ข้อความจากใบเสร็จ: $receiptText

จัดหมวดหมู่เป็นหนึ่งในหมวดหมู่เหล่านี้เท่านั้น: food, transport, shopping, entertainment, health, education, utilities, other

ตอบกลับในรูปแบบ JSON: {"category": "<หมวดหมู่>", "reasoning": "<เหตุผลสั้นๆ>"}
''';

    final request = GeminiRequestModel(
      contents: [
        GeminiContent(parts: [GeminiPart(text: prompt)])
      ],
    );

    final response = await geminiClient.generateContent(request);
    final rawText = response.text ?? '';

    String category = 'other';
    String reasoning = '';
    try {
      final jsonStart = rawText.indexOf('{');
      final jsonEnd = rawText.lastIndexOf('}');
      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonStr = rawText.substring(jsonStart, jsonEnd + 1);
        final decoded = _parseJsonString(jsonStr);
        category = decoded['category'] as String? ?? 'other';
        reasoning = decoded['reasoning'] as String? ?? '';
      }
    } catch (_) {
      category = _fallbackCategory(merchantName, receiptText);
    }

    final validCategories = [
      'food', 'transport', 'shopping', 'entertainment',
      'health', 'education', 'utilities', 'other'
    ];
    if (!validCategories.contains(category)) {
      category = 'other';
    }

    await cacheDataSource.cacheCategory(cacheKey, category);

    return {'category': category, 'reasoning': reasoning, 'source': 'gemini'};
  }

  Map<String, dynamic> _parseJsonString(String json) {
    final result = <String, dynamic>{};
    final categoryMatch = RegExp(r'"category"\s*:\s*"([^"]+)"').firstMatch(json);
    final reasoningMatch =
        RegExp(r'"reasoning"\s*:\s*"([^"]+)"').firstMatch(json);
    if (categoryMatch != null) result['category'] = categoryMatch.group(1);
    if (reasoningMatch != null) result['reasoning'] = reasoningMatch.group(1);
    return result;
  }

  String _fallbackCategory(String merchantName, String text) {
    final lower = '${merchantName.toLowerCase()} ${text.toLowerCase()}';
    if (RegExp(r'restaurant|food|cafe|coffee|pizza|burger|sushi|ร้านอาหาร|กาแฟ').hasMatch(lower)) return 'food';
    if (RegExp(r'grab|taxi|uber|bts|mrt|bus|fuel|gas|เดินทาง|รถ').hasMatch(lower)) return 'transport';
    if (RegExp(r'mall|shop|market|store|lazada|shopee|ช้อปปิ้ง').hasMatch(lower)) return 'shopping';
    if (RegExp(r'cinema|movie|game|netflix|บันเทิง').hasMatch(lower)) return 'entertainment';
    if (RegExp(r'hospital|clinic|pharmacy|drug|โรงพยาบาล|ยา').hasMatch(lower)) return 'health';
    if (RegExp(r'school|university|course|book|การศึกษา').hasMatch(lower)) return 'education';
    if (RegExp(r'electric|water|internet|phone|ไฟฟ้า|น้ำ').hasMatch(lower)) return 'utilities';
    return 'other';
  }
}
