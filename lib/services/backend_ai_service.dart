// Backend AI Service - Connects to AWS server
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/env.dart';

class BackendAIService {
  final String baseUrl;

  BackendAIService({String? customUrl})
      : baseUrl = customUrl ?? EnvConfig.aiServiceUrl;

  /// Get welcome message from backend
  Future<String> getWelcomeMessage({String? panditId}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/ai/welcome'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'panditId': panditId}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['message'] as String;
        }
      }

      throw Exception('Failed to get welcome message');
    } catch (e) {
      print('❌ Backend AI welcome error: $e');
      rethrow;
    }
  }

  /// Send message to backend AI
  Future<String> sendMessage(
    String message,
    List<dynamic> history, {
    String? panditId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/ai/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': message,
          'history': history,
          'panditId': panditId,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['response'] as String;
        }
      }

      throw Exception('Failed to get AI response: ${response.statusCode}');
    } catch (e) {
      print('❌ Backend AI chat error: $e');
      rethrow;
    }
  }

  /// Check if backend is available
  Future<bool> isAvailable() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

