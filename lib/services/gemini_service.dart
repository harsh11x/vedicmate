import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  // Google Gemini API Key
  static const String _apiKey = 'AIzaSyD5xwXaJbKIq_HzDSFhHY3ZaLQ_FvjS4Xw';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  
  // AI Pandit System Prompt with Multi-language Support
  static String _getSystemPrompt(String? detectedLanguage) {
    final basePrompt = '''
You are an AI Vedic Astrology Pandit with deep knowledge of:
- Vedic Astrology (Jyotish)
- Hindu scriptures and philosophy
- Palmistry (Hasta Samudrika)
- Numerology
- Vastu Shastra
- Spiritual guidance and counseling

Provide helpful, compassionate, and insightful advice based on Vedic principles.
Be respectful, professional, and culturally sensitive.
If asked about topics outside your expertise, politely redirect to relevant spiritual guidance.
Keep responses concise but meaningful (2-4 paragraphs maximum).
Use respectful language and traditional greetings when appropriate.

IMPORTANT: Respond in the same language the user is using. Support multiple languages including:
- English
- Hindi (हिंदी)
- Urdu (اردو)
- Chinese (中文)
- Arabic (العربية)
- Bengali (বাংলা)
- Tamil (தமிழ்)
- Telugu (తెలుగు)
- Marathi (मराठी)
- Gujarati (ગુજરાતી)
- Punjabi (ਪੰਜਾਬੀ)
- And other regional/international languages

Always match the user's language preference naturally and fluently.
''';
    return basePrompt;
  }

  // Detect language from text (simple heuristic)
  static String? _detectLanguage(String text) {
    // Check for Hindi (Devanagari script)
    if (RegExp(r'[\u0900-\u097F]').hasMatch(text)) return 'hi';
    // Check for Urdu (Arabic script)
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return 'ur';
    // Check for Chinese
    if (RegExp(r'[\u4E00-\u9FFF]').hasMatch(text)) return 'zh';
    // Check for Arabic
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) return 'ar';
    // Check for Bengali
    if (RegExp(r'[\u0980-\u09FF]').hasMatch(text)) return 'bn';
    // Check for Tamil
    if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(text)) return 'ta';
    // Check for Telugu
    if (RegExp(r'[\u0C00-\u0C7F]').hasMatch(text)) return 'te';
    // Default to English
    return 'en';
  }

  Future<String> sendMessage(String userMessage, List<Map<String, String>> conversationHistory) async {
    try {
      // Detect language from user message
      final detectedLanguage = _detectLanguage(userMessage);
      final systemPrompt = _getSystemPrompt(detectedLanguage);
      
      // Build conversation context
      final List<Map<String, dynamic>> contents = [];
      
      // Add system instruction in the first user message
      final firstUserMessage = '$systemPrompt\n\nUser: $userMessage';
      
      // Add conversation history (limit to last 10 messages to avoid token limits)
      final recentHistory = conversationHistory.length > 10 
          ? conversationHistory.sublist(conversationHistory.length - 10)
          : conversationHistory;
      
      for (var message in recentHistory) {
        contents.add({
          'role': message['isUser'] == 'true' ? 'user' : 'model',
          'parts': [{'text': message['message'] ?? ''}]
        });
      }
      
      // Add current user message with system prompt if it's the first message
      if (conversationHistory.isEmpty) {
        contents.add({
          'role': 'user',
          'parts': [{'text': firstUserMessage}]
        });
      } else {
        contents.add({
          'role': 'user',
          'parts': [{'text': userMessage}]
        });
      }

      // Use gemini-pro which is available in v1beta API
      final model = 'gemini-pro';
      final url = '$_baseUrl/$model:generateContent?key=$_apiKey';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': contents,
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final content = data['candidates'][0]['content'];
          if (content['parts'] != null && content['parts'].isNotEmpty) {
            final text = content['parts'][0]['text'];
            if (text != null && text.isNotEmpty) {
              return text;
            }
          }
        }
        // Check for blocked content
        if (data['promptFeedback'] != null && 
            data['promptFeedback']['blockReason'] != null) {
          return 'I apologize, but your message was blocked by safety filters. Please rephrase your question.';
        }
        return 'I apologize, but I could not generate a response. Please try again.';
      } else {
        final errorBody = response.body;
        print('Gemini API Error: ${response.statusCode} - $errorBody');
        
        // Try to parse error message
        try {
          final errorData = jsonDecode(errorBody);
          if (errorData['error'] != null && errorData['error']['message'] != null) {
            return 'Error: ${errorData['error']['message']}';
          }
        } catch (e) {
          // If error parsing fails, use default message
        }
        
        if (response.statusCode == 401) {
          return 'API authentication failed. Please contact support.';
        } else if (response.statusCode == 429) {
          return 'Too many requests. Please wait a moment and try again.';
        } else if (response.statusCode >= 500) {
          return 'Server error. Please try again later.';
        }
        
        return 'I apologize, but I am experiencing technical difficulties. Please try again in a moment.';
      }
    } catch (e) {
      print('Error calling Gemini API: $e');
      return 'I apologize, but I encountered an error. Please check your connection and try again.';
    }
  }

  Future<String> getWelcomeMessage() async {
    return '''🙏 Namaste! Welcome to AI Pandit.

I am your spiritual guide powered by ancient Vedic wisdom. I can help you with:

✨ Vedic Astrology insights
🔮 Spiritual guidance
🌟 Life counseling based on Hindu philosophy
🏠 Vastu Shastra advice
🔢 Numerology readings

How may I assist you on your spiritual journey today?

Note: This session is charged at ₹25 per minute.''';
  }
}
