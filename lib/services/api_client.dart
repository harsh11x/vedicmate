import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';

class ApiClient {
  final Dio _dio;

  ApiClient() : _dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint('API GET Error: ${e.message}');
      throw _handleError(e);
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      throw Exception('Unexpected error occurred');
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      return Exception('API Error: ${e.response?.statusCode} - ${e.response?.statusMessage}');
    } else {
      return Exception('Network Error: ${e.message}');
    }
  }
}
