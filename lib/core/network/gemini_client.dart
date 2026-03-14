import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../data/models/llm_response_model.dart';

class GeminiClient {
  late final Dio _dio;
  final SharedPreferences _prefs;

  GeminiClient({required SharedPreferences prefs}) : _prefs = prefs {
    _dio = Dio(BaseOptions(
      baseUrl: AppConstants.geminiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final apiKey = _prefs.getString(AppConstants.prefKeyApiKey) ?? '';
          if (apiKey.isEmpty) {
            handler.reject(DioException(
              requestOptions: options,
              type: DioExceptionType.unknown,
              error: 'API_KEY_MISSING',
            ));
            return;
          }
          options.queryParameters['key'] = apiKey;
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
        onResponse: (response, handler) {
          handler.next(response);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) {},
    ));
  }

  Future<GeminiResponseModel> generateContent(
      GeminiRequestModel request) async {
    try {
      final response = await _dio.post(
        '/models/${AppConstants.geminiModel}:generateContent',
        data: request.toJson(),
      );
      return GeminiResponseModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Exception _mapError(DioException e) {
    if (e.error?.toString() == 'API_KEY_MISSING') {
      return Exception('Gemini API key not set. Go to Settings → Gemini API Key to configure it.');
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Request timed out. Please try again.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 400) {
          return Exception('Invalid API key or request (400). Please check your Gemini API key in Settings.');
        }
        if (code == 401 || code == 403) {
          return Exception('Unauthorized (${code}). Please check your Gemini API key in Settings.');
        }
        if (code == 429) {
          return Exception('Rate limit exceeded. Please wait a moment and try again.');
        }
        return Exception('Server error ($code). Please try again.');
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return Exception('Network error. Please check your internet connection.');
      default:
        return Exception('Unexpected error. Please try again.');
    }
  }
}
