import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/env.dart';
import '../models/ai_chat_model.dart';

/// AWS-hosted AI Service Client
/// Connects to the AI service deployed on AWS
class AWSAIService {
  final String baseUrl;
  
  AWSAIService({String? baseUrl}) 
      : baseUrl = baseUrl ?? EnvConfig.aiServiceUrl;
  
  /// Send message to AWS AI service
  Future<String> sendMessage(
    String userMessage,
    List<Map<String, String>> conversationHistory,
    {String userId = 'anonymous'}
  ) async {
    try {
      final url = Uri.parse('$baseUrl/api/chat');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': userMessage,
          'conversation_history': conversationHistory,
          'user_id': userId,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data['response'] ?? 'I apologize, but I could not generate a response.';
        } else {
          return data['error'] ?? 'Error processing your request.';
        }
      } else {
        print('AWS AI Service Error: ${response.statusCode} - ${response.body}');
        return 'I apologize, but I am experiencing technical difficulties. Please try again.';
      }
    } catch (e) {
      print('Error calling AWS AI Service: $e');
      return 'I apologize, but I encountered an error. Please check your connection and try again.';
    }
  }
  
  /// Get welcome message from AWS AI service
  Future<String> getWelcomeMessage() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': 'Hello',
          'conversation_history': [],
          'user_id': 'welcome',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Welcome to Vedic Mate AI!';
      }
    } catch (e) {
      print('Error getting welcome message: $e');
    }
    
    return '''🙏 Namaste! Welcome to AI Pandit.

I am your spiritual guide powered by Vedic Astrology knowledge. I can help you with:

✨ Kundli and Lagna Chart interpretations
🔮 Planetary positions and their effects
🌟 Love, Career, Health, and Wealth guidance
🏠 Vastu Shastra advice
🔢 Numerology readings
💎 Astrological remedies

How may I assist you on your spiritual journey today?

Note: This session is charged at ₹25 per minute.''';
  }
  
  /// Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

