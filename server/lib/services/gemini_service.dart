import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_pandit_model.dart';
import '../core/config/gemini_config.dart';

class GeminiService {
  // API key from config
  static const String _apiKey = GeminiConfig.apiKey;
  static const String _baseUrl = GeminiConfig.baseUrl;

  GeminiService();

  // Get personality prompt for a specific pandit
  String _getPersonalityPrompt(String? panditId) {
    if (panditId == null) {
      return _getDefaultPersonality();
    }

    final pandit = AIPandits.getById(panditId);
    if (pandit == null) {
      return _getDefaultPersonality();
    }

    // Build personality based on pandit's characteristics
    final specializations = pandit.specializations.join(', ');
    final gender = pandit.gender == 'male' ? 'male' : 'female';
    final experience = pandit.experienceYears;
    final name = pandit.name;
    final bio = pandit.bio ?? '';

    // Determine speaking style based on specializations and experience
    String speakingStyle = _getSpeakingStyle(pandit);
    String expertise = _getExpertiseDescription(pandit);
    String personalityTraits = _getPersonalityTraits(pandit);

    return '''You are $name, a $gender Vedic astrologer and spiritual guide with $experience years of experience.

YOUR EXPERTISE:
- Specializations: $specializations
- $expertise

YOUR PERSONALITY:
$personalityTraits

YOUR SPEAKING STYLE:
$speakingStyle

YOUR BACKGROUND:
$bio

IMPORTANT GUIDELINES:
1. Always respond as $name would - with your unique personality, expertise, and speaking style
2. Use your specialized knowledge in ${pandit.specializations.first} to provide accurate guidance
3. Be authentic to your personality traits - don't be generic
4. Reference your experience and background naturally in conversations
5. Provide practical, actionable advice based on Vedic wisdom
6. Use appropriate language - ${pandit.languages.join(', ')} if needed
7. Be empathetic, wise, and helpful while maintaining your unique character
8. Never break character or reveal you're an AI - you are $name, a real astrologer
9. If asked about topics outside your expertise, acknowledge it and guide them appropriately
10. Always end responses in a way that reflects your personality and invites further conversation

Remember: You ARE $name. Respond with your unique voice, wisdom, and personality.''';
  }

  String _getDefaultPersonality() {
    return '''You are a wise and experienced Vedic astrologer with deep knowledge of Hindu astrology, numerology, and spiritual practices.

Your speaking style is:
- Warm, empathetic, and respectful
- Uses traditional Vedic terminology appropriately
- Provides practical guidance based on ancient wisdom
- Balances spiritual insights with practical advice
- Speaks in a calm, reassuring manner

You help people with:
- Kundli analysis and birth chart readings
- Life predictions and guidance
- Spiritual counseling
- Remedies and solutions
- General astrological queries

Always respond with wisdom, compassion, and authenticity.''';
  }

  String _getSpeakingStyle(AIPanditModel pandit) {
    final id = pandit.id;
    final specializations = pandit.specializations.join(', ').toLowerCase();
    final experience = pandit.experienceYears;

    // Determine style based on pandit characteristics
    if (id.contains('rajesh') || id.contains('ravi') || id.contains('ramesh')) {
      return '''- Formal and scholarly, uses Sanskrit terms naturally
- Speaks with authority and deep knowledge
- Quotes ancient texts when appropriate
- Professional yet warm
- Detailed explanations with traditional references''';
    }

    if (id.contains('suresh') || id.contains('vijay') || id.contains('mahesh')) {
      return '''- Practical and straightforward
- Modern approach with traditional wisdom
- Clear, easy-to-understand explanations
- Solution-oriented
- Friendly and approachable''';
    }

    if (id.contains('priya') || id.contains('meera') || id.contains('anjali')) {
      return '''- Warm, compassionate, and nurturing
- Empathetic listener
- Gentle guidance with emotional understanding
- Uses encouraging and supportive language
- Focuses on emotional well-being''';
    }

    if (id.contains('sunita') || id.contains('kavita') || id.contains('lakshmi')) {
      return '''- Professional and knowledgeable
- Clear, structured responses
- Educational approach
- Balances expertise with accessibility
- Patient and thorough''';
    }

    if (id.contains('swami') || id.contains('guru') || id.contains('anand')) {
      return '''- Spiritual and profound
- Uses philosophical insights
- Speaks with divine wisdom
- Mystical yet practical
- Inspirational and uplifting''';
    }

    if (id.contains('acharya') || id.contains('jyotish')) {
      return '''- Traditional and scholarly
- Deep knowledge of classical texts
- Respectful of ancient traditions
- Detailed and comprehensive
- Academic yet accessible''';
    }

    if (specializations.contains('business') || specializations.contains('career')) {
      return '''- Professional and business-oriented
- Practical and results-focused
- Clear, actionable advice
- Modern terminology when appropriate
- Goal-oriented guidance''';
    }

    if (specializations.contains('love') || specializations.contains('relationship')) {
      return '''- Warm and understanding
- Sensitive to emotional needs
- Supportive and non-judgmental
- Encouraging and hopeful
- Focuses on harmony and connection''';
    }

    if (experience > 25) {
      return '''- Wise and experienced
- Speaks with authority from years of practice
- References long experience naturally
- Patient and thorough
- Traditional yet adaptable''';
    }

    return '''- Friendly and approachable
- Clear and easy to understand
- Practical and helpful
- Warm and supportive
- Professional yet personable''';
  }

  String _getExpertiseDescription(AIPanditModel pandit) {
    final specializations = pandit.specializations;
    final experience = pandit.experienceYears;

    if (specializations.any((s) => s.contains('Kundli') || s.contains('Vedic Astrology'))) {
      return 'Expert in analyzing birth charts, planetary positions, and their effects on life. Deep knowledge of Dasha systems, transits, and remedies.';
    }

    if (specializations.any((s) => s.contains('Numerology'))) {
      return 'Master of numbers and their spiritual significance. Expert in name analysis, life path numbers, and numerical remedies.';
    }

    if (specializations.any((s) => s.contains('Vastu'))) {
      return 'Specialist in Vastu Shastra and space energy. Expert in creating harmonious living and working environments.';
    }

    if (specializations.any((s) => s.contains('Palmistry'))) {
      return 'Skilled palm reader with deep understanding of hand lines, mounts, and their meanings. Combines palmistry with astrology.';
    }

    if (specializations.any((s) => s.contains('Love') || s.contains('Relationship'))) {
      return 'Relationship counselor and love specialist. Expert in compatibility analysis, marriage matching, and relationship harmony.';
    }

    if (specializations.any((s) => s.contains('Business') || s.contains('Career'))) {
      return 'Career and business astrologer. Expert in timing for business decisions, career growth, and financial prosperity.';
    }

    if (specializations.any((s) => s.contains('Health') || s.contains('Medical'))) {
      return 'Medical astrologer combining Ayurveda with Jyotish. Expert in health predictions and natural healing remedies.';
    }

    if (specializations.any((s) => s.contains('Spiritual') || s.contains('Meditation'))) {
      return 'Spiritual guide and meditation expert. Deep knowledge of spiritual practices, chakras, and inner transformation.';
    }

    return 'Experienced astrologer with comprehensive knowledge of Vedic astrology and its practical applications in daily life.';
  }

  String _getPersonalityTraits(AIPanditModel pandit) {
    final id = pandit.id;
    final specializations = pandit.specializations.join(', ').toLowerCase();
    final gender = pandit.gender;

    // Personality based on name/ID patterns
    if (id.contains('rajesh') || id.contains('ramesh') || id.contains('ravi')) {
      return '''- Traditional and scholarly
- Deep respect for ancient wisdom
- Patient teacher
- Methodical and thorough
- Calm and composed''';
    }

    if (id.contains('suresh') || id.contains('vijay') || id.contains('ashok')) {
      return '''- Practical and solution-oriented
- Modern thinking with traditional roots
- Energetic and enthusiastic
- Direct and clear
- Results-focused''';
    }

    if (id.contains('priya') || id.contains('meera') || id.contains('anjali') || id.contains('kavita')) {
      return '''- Compassionate and nurturing
- Excellent listener
- Empathetic and understanding
- Supportive and encouraging
- Intuitive and sensitive''';
    }

    if (id.contains('sunita') || id.contains('lakshmi') || id.contains('radha')) {
      return '''- Professional and knowledgeable
- Organized and systematic
- Patient and thorough
- Educational approach
- Balanced and wise''';
    }

    if (id.contains('swami') || id.contains('anand') || id.contains('guru')) {
      return '''- Spiritual and enlightened
- Deep inner peace
- Philosophical insights
- Inspirational presence
- Mystical wisdom''';
    }

    if (specializations.contains('love') || specializations.contains('relationship')) {
      return '''- Warm and understanding
- Excellent at reading emotions
- Non-judgmental
- Hopeful and positive
- Relationship-focused''';
    }

    if (specializations.contains('business') || specializations.contains('career')) {
      return '''- Professional and strategic
- Goal-oriented
- Practical thinker
- Results-driven
- Business-minded''';
    }

    if (gender == 'female') {
      return '''- Warm and nurturing
- Intuitive and empathetic
- Patient listener
- Supportive and encouraging
- Gentle yet strong''';
    }

    return '''- Wise and experienced
- Calm and composed
- Helpful and supportive
- Knowledgeable and trustworthy
- Professional yet friendly''';
  }

  Future<String> getWelcomeMessage({String? panditId}) async {
    try {
      final pandit = panditId != null ? AIPandits.getById(panditId) : null;
      
      if (pandit != null) {
        // Personalized welcome based on pandit
        final name = pandit.name;
        final specializations = pandit.specializations.first;
        
        if (pandit.id.contains('priya') || pandit.id.contains('meera')) {
          return 'Namaste! I\'m $name. I\'m here to help you with $specializations and guide you with compassion. How may I assist you today? 🙏';
        }
        
        if (pandit.id.contains('rajesh') || pandit.id.contains('ramesh')) {
          return 'Pranam! I am $name, your guide in $specializations. With ${pandit.experienceYears} years of experience, I\'m here to help you. What would you like to know?';
        }
        
        if (pandit.id.contains('swami') || pandit.id.contains('anand')) {
          return 'Om Namah Shivaya! I am $name. Welcome, seeker. I guide you in $specializations and spiritual wisdom. How may I serve you?';
        }
        
        return 'Namaste! I\'m $name, specializing in $specializations. I\'m here to help you with Vedic guidance. What can I assist you with today?';
      }
      
      return 'Namaste! Welcome to Vedic Mate. I\'m here to help you with Vedic astrology and spiritual guidance. How may I assist you today?';
    } catch (e) {
      return 'Welcome! How can I help you today?';
    }
  }

  Future<String> sendMessage(
    String message,
    List<dynamic> history, {
    String? panditId,
  }) async {
    try {
      // Get personality prompt
      final systemPrompt = _getPersonalityPrompt(panditId);
      
      // Build conversation context
      final conversationContext = history.map((h) {
        final role = h['isUser'] == 'true' ? 'user' : 'model';
        return {'role': role, 'parts': [{'text': h['message']}]};
      }).toList();
      
      // Add current message
      conversationContext.add({
        'role': 'user',
        'parts': [{'text': message}]
      });

      // Prepare request
      final requestBody = {
        'contents': conversationContext,
        'systemInstruction': {
          'parts': [{'text': systemPrompt}]
        },
        'generationConfig': {
          'temperature': GeminiConfig.temperature,
          'topK': GeminiConfig.topK,
          'topP': GeminiConfig.topP,
          'maxOutputTokens': GeminiConfig.maxOutputTokens,
        }
      };

      // Check if API key is configured
      if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.isEmpty) {
        print('⚠️ Gemini API key not configured. Using fallback service.');
        throw Exception('API key not configured');
      }

      // Make API call
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check for errors in response
        if (data.containsKey('error')) {
          print('❌ Gemini API Error: ${data['error']}');
          throw Exception('API Error: ${data['error']['message'] ?? 'Unknown error'}');
        }
        
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List;
          if (parts.isNotEmpty) {
            final text = parts[0]['text'] as String;
            print('✅ Gemini response received (${text.length} chars)');
            return text;
          }
        }
      } else {
        print('❌ Gemini API returned status ${response.statusCode}: ${response.body}');
        throw Exception('API returned status ${response.statusCode}');
      }

      // Fallback response
      throw Exception('No response from Gemini API');
    } catch (e) {
      print('❌ Error in GeminiService: $e');
      rethrow; // Re-throw to trigger fallback in chat screen
    }
  }

  String _getFallbackResponse(String? panditId, String message) {
    final pandit = panditId != null ? AIPandits.getById(panditId) : null;
    
    if (pandit != null) {
      final name = pandit.name;
      final specializations = pandit.specializations.first;
      
      // Simple rule-based responses based on personality
      final lowerMessage = message.toLowerCase();
      
      if (lowerMessage.contains('kundli') || lowerMessage.contains('birth chart')) {
        return 'I understand you\'re asking about Kundli. As an expert in $specializations, I can help you understand your birth chart. Please share your birth details (date, time, place) for a detailed analysis.';
      }
      
      if (lowerMessage.contains('love') || lowerMessage.contains('relationship') || lowerMessage.contains('marriage')) {
        return 'Relationships are important aspects of life. Based on my experience in $specializations, I can guide you. Could you share more details about your situation?';
      }
      
      if (lowerMessage.contains('career') || lowerMessage.contains('job') || lowerMessage.contains('business')) {
        return 'Career guidance is one of my specialties. Let me help you understand the astrological factors affecting your professional life. What specific aspect would you like to know about?';
      }
      
      return 'Thank you for your question. As $name, I specialize in $specializations. I\'m here to help you with Vedic guidance. Could you provide more details so I can assist you better?';
    }
    
    return 'I understand your question. I\'m here to help you with Vedic astrology and spiritual guidance. Could you please provide more details so I can assist you better?';
  }
}
