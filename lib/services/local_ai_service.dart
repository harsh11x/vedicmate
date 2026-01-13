import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class LocalAIService {
  Future<String> sendMessage(
    String message, 
    List<Map<String, String>> history, {
    String? panditId,
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ai-pandit/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId ?? 'guest', // Should be passed from UI/Provider
          'message': message,
          'panditId': panditId,
          'history': history, // Optional, depending on backend implementation
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['error'] ?? 'Unknown AI error');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to AI Pandit: $e');
    }
  }

  Future<void> clearHistory(String userId) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/ai-pandit/clear-history'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );
    } catch (e) {
      print('Error clearing history: $e');
    }
  }
}
