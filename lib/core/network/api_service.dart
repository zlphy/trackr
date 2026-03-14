import 'package:dio/dio.dart';
import 'dart:convert';

import 'dio_client.dart';

class ApiService {
  final DioClient _dioClient;

  ApiService(this._dioClient);

  // LLM API for expense categorization
  Future<Map<String, dynamic>> categorizeExpense({
    required String receiptText,
    required double amount,
    required String merchantName,
  }) async {
    try {
      final response = await _dioClient.post(
        '/api/categorize-expense',
        data: {
          'receipt_text': receiptText,
          'amount': amount,
          'merchant_name': merchantName,
        },
      );
      
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Get expense categories
  Future<List<String>> getExpenseCategories() async {
    try {
      final response = await _dioClient.get('/api/expense-categories');
      return List<String>.from(response.data['categories']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Sync expenses to cloud
  Future<bool> syncExpenses(List<Map<String, dynamic>> expenses) async {
    try {
      final response = await _dioClient.post(
        '/api/expenses/sync',
        data: {'expenses': expenses},
      );
      return response.data['success'] ?? false;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              return 'Bad request. Please check your input.';
            case 401:
              return 'Unauthorized. Please login again.';
            case 403:
              return 'Forbidden. You don\'t have permission.';
            case 404:
              return 'Not found. The requested resource doesn\'t exist.';
            case 500:
              return 'Internal server error. Please try again later.';
            default:
              return 'Server error: $statusCode';
          }
        }
        return 'Unknown server error occurred.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
        return 'Network error. Please check your internet connection.';
      default:
        return 'An unexpected error occurred.';
    }
  }
}
