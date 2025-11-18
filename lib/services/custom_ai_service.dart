import 'dart:convert';
import 'dart:math';
import '../models/ai_chat_model.dart';

/// Custom AI Service trained on Kundli and Lagna Chart data
/// This service uses a knowledge base of astrological interpretations
/// combined with pattern matching and contextual responses
class CustomAIService {
  // Knowledge base of Kundli interpretations
  final Map<String, List<String>> _kundliKnowledge = {
    'aries': [
      'Aries natives are natural leaders with strong willpower. Your ruling planet is Mars, giving you courage and determination.',
      'As an Aries, you excel in competitive environments. Your element is Fire, making you passionate and energetic.',
      'Aries individuals are known for their pioneering spirit. You are most compatible with Leo and Sagittarius.',
    ],
    'taurus': [
      'Taurus natives are grounded and practical. Ruled by Venus, you value beauty, comfort, and stability.',
      'Your element is Earth, making you reliable and patient. You excel in building long-term wealth and relationships.',
      'Taurus individuals are known for their determination. You are most compatible with Virgo and Capricorn.',
    ],
    'gemini': [
      'Gemini natives are curious and communicative. Ruled by Mercury, you have a quick mind and love learning.',
      'Your element is Air, making you adaptable and social. You excel in communication and networking.',
      'Gemini individuals are known for their versatility. You are most compatible with Libra and Aquarius.',
    ],
    'cancer': [
      'Cancer natives are intuitive and nurturing. Ruled by the Moon, you are deeply emotional and caring.',
      'Your element is Water, making you empathetic and protective. You excel in creating safe, comfortable spaces.',
      'Cancer individuals are known for their emotional depth. You are most compatible with Scorpio and Pisces.',
    ],
    'leo': [
      'Leo natives are confident and charismatic. Ruled by the Sun, you naturally attract attention and admiration.',
      'Your element is Fire, making you passionate and creative. You excel in leadership and artistic pursuits.',
      'Leo individuals are known for their generosity. You are most compatible with Aries and Sagittarius.',
    ],
    'virgo': [
      'Virgo natives are analytical and detail-oriented. Ruled by Mercury, you have a sharp mind and practical approach.',
      'Your element is Earth, making you reliable and hardworking. You excel in service and organization.',
      'Virgo individuals are known for their perfectionism. You are most compatible with Taurus and Capricorn.',
    ],
    'libra': [
      'Libra natives are diplomatic and balanced. Ruled by Venus, you value harmony and beauty in all things.',
      'Your element is Air, making you social and fair-minded. You excel in partnerships and creative endeavors.',
      'Libra individuals are known for their charm. You are most compatible with Gemini and Aquarius.',
    ],
    'scorpio': [
      'Scorpio natives are intense and transformative. Ruled by Mars and Pluto, you have deep emotional power.',
      'Your element is Water, making you intuitive and passionate. You excel in research and transformation.',
      'Scorpio individuals are known for their depth. You are most compatible with Cancer and Pisces.',
    ],
    'sagittarius': [
      'Sagittarius natives are adventurous and philosophical. Ruled by Jupiter, you seek truth and expansion.',
      'Your element is Fire, making you optimistic and freedom-loving. You excel in teaching and exploration.',
      'Sagittarius individuals are known for their wisdom. You are most compatible with Aries and Leo.',
    ],
    'capricorn': [
      'Capricorn natives are ambitious and disciplined. Ruled by Saturn, you value structure and achievement.',
      'Your element is Earth, making you practical and responsible. You excel in business and long-term planning.',
      'Capricorn individuals are known for their perseverance. You are most compatible with Taurus and Virgo.',
    ],
    'aquarius': [
      'Aquarius natives are innovative and independent. Ruled by Saturn and Uranus, you are forward-thinking.',
      'Your element is Air, making you intellectual and humanitarian. You excel in technology and social causes.',
      'Aquarius individuals are known for their originality. You are most compatible with Gemini and Libra.',
    ],
    'pisces': [
      'Pisces natives are intuitive and compassionate. Ruled by Jupiter and Neptune, you are deeply spiritual.',
      'Your element is Water, making you empathetic and artistic. You excel in creative and healing professions.',
      'Pisces individuals are known for their sensitivity. You are most compatible with Cancer and Scorpio.',
    ],
  };

  // Lagna (Ascendant) interpretations
  final Map<String, String> _lagnaKnowledge = {
    'mesha': 'Mesha Lagna (Aries Ascendant): You have strong leadership qualities and are naturally assertive. Your ruling planet Mars gives you courage and drive.',
    'vrishabha': 'Vrishabha Lagna (Taurus Ascendant): You value stability and material comfort. Venus rules your ascendant, making you appreciate beauty and harmony.',
    'mithuna': 'Mithuna Lagna (Gemini Ascendant): You are curious and communicative. Mercury rules your ascendant, giving you a quick, adaptable mind.',
    'karka': 'Karka Lagna (Cancer Ascendant): You are emotional and nurturing. The Moon rules your ascendant, making you intuitive and protective.',
    'simha': 'Simha Lagna (Leo Ascendant): You are confident and charismatic. The Sun rules your ascendant, making you a natural leader.',
    'kanya': 'Kanya Lagna (Virgo Ascendant): You are analytical and detail-oriented. Mercury rules your ascendant, giving you a practical, service-oriented nature.',
    'tula': 'Tula Lagna (Libra Ascendant): You seek balance and harmony. Venus rules your ascendant, making you diplomatic and relationship-focused.',
    'vrischika': 'Vrischika Lagna (Scorpio Ascendant): You are intense and transformative. Mars and Pluto rule your ascendant, giving you deep emotional power.',
    'dhanu': 'Dhanu Lagna (Sagittarius Ascendant): You are adventurous and philosophical. Jupiter rules your ascendant, making you seek truth and expansion.',
    'makara': 'Makara Lagna (Capricorn Ascendant): You are ambitious and disciplined. Saturn rules your ascendant, giving you structure and perseverance.',
    'kumbha': 'Kumbha Lagna (Aquarius Ascendant): You are innovative and independent. Saturn and Uranus rule your ascendant, making you forward-thinking.',
    'meena': 'Meena Lagna (Pisces Ascendant): You are intuitive and compassionate. Jupiter and Neptune rule your ascendant, making you deeply spiritual.',
  };

  // Planetary positions and their meanings
  final Map<String, Map<String, String>> _planetaryKnowledge = {
    'sun': {
      'strong': 'A strong Sun in your chart indicates leadership, confidence, and vitality. You have natural authority and charisma.',
      'weak': 'A weak Sun may indicate issues with self-confidence or authority figures. Focus on building self-esteem.',
    },
    'moon': {
      'strong': 'A strong Moon indicates emotional stability, intuition, and nurturing qualities. You are in tune with your feelings.',
      'weak': 'A weak Moon may indicate emotional instability. Practice mindfulness and emotional regulation.',
    },
    'mars': {
      'strong': 'A strong Mars gives you courage, energy, and determination. You are action-oriented and competitive.',
      'weak': 'A weak Mars may indicate lack of motivation or energy. Regular exercise can help strengthen Mars.',
    },
    'mercury': {
      'strong': 'A strong Mercury indicates intelligence, communication skills, and adaptability. You learn quickly.',
      'weak': 'A weak Mercury may affect communication. Practice writing and speaking to strengthen Mercury.',
    },
    'jupiter': {
      'strong': 'A strong Jupiter brings wisdom, expansion, and good fortune. You have natural optimism and growth.',
      'weak': 'A weak Jupiter may affect wisdom and growth. Study spiritual texts and practice gratitude.',
    },
    'venus': {
      'strong': 'A strong Venus brings love, beauty, and harmony. You appreciate art, relationships, and luxury.',
      'weak': 'A weak Venus may affect relationships and creativity. Focus on self-love and artistic expression.',
    },
    'saturn': {
      'strong': 'A strong Saturn brings discipline, structure, and long-term success. You are patient and persistent.',
      'weak': 'A weak Saturn may affect discipline and structure. Develop routines and long-term goals.',
    },
    'rahu': {
      'strong': 'A strong Rahu brings ambition, material desires, and innovation. You are driven and unconventional.',
      'weak': 'A weak Rahu may affect ambition. Set clear goals and work towards material success.',
    },
    'ketu': {
      'strong': 'A strong Ketu brings spirituality, detachment, and intuition. You are drawn to spiritual practices.',
      'weak': 'A weak Ketu may affect spiritual growth. Practice meditation and detachment.',
    },
  };

  // Common astrological queries and responses
  final Map<String, List<String>> _commonQueries = {
    'love': [
      'For love matters, Venus plays a key role. Strengthen Venus by wearing white clothes on Fridays and offering prayers to Goddess Lakshmi.',
      'Your 7th house indicates marriage and partnerships. A strong 7th house lord brings harmonious relationships.',
      'For love compatibility, check the positions of Venus and the 7th house in both charts. Mutual aspects create strong bonds.',
    ],
    'career': [
      'Your 10th house indicates career. A strong 10th house lord brings professional success and recognition.',
      'The position of Saturn and Jupiter in your chart affects career growth. Saturn brings discipline, Jupiter brings expansion.',
      'For career success, strengthen your 10th house lord through remedies and focus on your natural talents.',
    ],
    'health': [
      'Your 6th house indicates health. A strong 6th house lord protects you from diseases.',
      'The position of the Sun and Mars affects vitality. Regular exercise and a balanced diet strengthen these planets.',
      'For good health, strengthen the 6th house lord and avoid negative planetary influences through remedies.',
    ],
    'wealth': [
      'Your 2nd and 11th houses indicate wealth. A strong 2nd house brings savings, 11th house brings income.',
      'Jupiter and Venus are wealth-giving planets. Strengthen them through prayers and remedies for financial growth.',
      'For wealth, focus on strengthening the 2nd and 11th house lords. Avoid negative aspects to these houses.',
    ],
    'marriage': [
      'Your 7th house indicates marriage. A strong 7th house lord brings a harmonious married life.',
      'The position of Venus and Jupiter affects marriage. Venus brings love, Jupiter brings wisdom in relationships.',
      'For a happy marriage, strengthen the 7th house lord and ensure Venus is well-placed in your chart.',
    ],
  };

  // Remedies database
  final Map<String, List<String>> _remedies = {
    'sun': [
      'Wear copper or gold jewelry',
      'Donate wheat, jaggery, or red clothes on Sundays',
      'Chant Surya Mantra: "Om Suryaya Namah"',
      'Fast on Sundays',
      'Wear red or orange colors',
    ],
    'moon': [
      'Wear silver or pearl jewelry',
      'Donate white items, rice, or milk on Mondays',
      'Chant Chandra Mantra: "Om Chandraya Namah"',
      'Fast on Mondays',
      'Wear white or light colors',
    ],
    'mars': [
      'Wear red coral or copper',
      'Donate red items, lentils, or copper on Tuesdays',
      'Chant Mangal Mantra: "Om Mangalaya Namah"',
      'Fast on Tuesdays',
      'Wear red colors',
    ],
    'mercury': [
      'Wear emerald or green stones',
      'Donate green items, moong dal, or books on Wednesdays',
      'Chant Budh Mantra: "Om Budhaya Namah"',
      'Fast on Wednesdays',
      'Wear green colors',
    ],
    'jupiter': [
      'Wear yellow sapphire or gold',
      'Donate yellow items, turmeric, or yellow clothes on Thursdays',
      'Chant Guru Mantra: "Om Gurave Namah"',
      'Fast on Thursdays',
      'Wear yellow colors',
    ],
    'venus': [
      'Wear diamond or white stones',
      'Donate white items, silver, or flowers on Fridays',
      'Chant Shukra Mantra: "Om Shukraya Namah"',
      'Fast on Fridays',
      'Wear white or light colors',
    ],
    'saturn': [
      'Wear blue sapphire or iron',
      'Donate black items, sesame seeds, or oil on Saturdays',
      'Chant Shani Mantra: "Om Shanaye Namah"',
      'Fast on Saturdays',
      'Wear black or dark blue colors',
    ],
  };

  /// Generate response based on user message and conversation history
  Future<String> sendMessage(
    String userMessage,
    List<Map<String, String>> conversationHistory,
  ) async {
    final message = userMessage.toLowerCase().trim();
    
    // Extract keywords from user message
    final keywords = _extractKeywords(message);
    
    // Determine response type
    if (_isGreeting(message)) {
      return _getGreetingResponse();
    }
    
    if (_isQuestionAboutSign(message, keywords)) {
      return _getSignInterpretation(message, keywords);
    }
    
    if (_isQuestionAboutLagna(message, keywords)) {
      return _getLagnaInterpretation(message, keywords);
    }
    
    if (_isQuestionAboutPlanet(message, keywords)) {
      return _getPlanetaryInterpretation(message, keywords);
    }
    
    if (_isQuestionAboutTopic(message, keywords)) {
      return _getTopicResponse(message, keywords);
    }
    
    if (_isQuestionAboutRemedy(message, keywords)) {
      return _getRemedyResponse(message, keywords);
    }
    
    // Default contextual response
    return _getContextualResponse(message, keywords, conversationHistory);
  }

  /// Get welcome message
  Future<String> getWelcomeMessage() async {
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

  // Helper methods
  List<String> _extractKeywords(String message) {
    final words = message.split(' ');
    final keywords = <String>[];
    
    for (var word in words) {
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
      if (cleanWord.length > 2) {
        keywords.add(cleanWord);
      }
    }
    
    return keywords;
  }

  bool _isGreeting(String message) {
    final greetings = ['hi', 'hello', 'namaste', 'hey', 'good morning', 'good evening'];
    return greetings.any((g) => message.contains(g));
  }

  String _getGreetingResponse() {
    final responses = [
      '🙏 Namaste! How may I help you with your astrological queries today?',
      '🙏 Hello! I am here to guide you through Vedic Astrology. What would you like to know?',
      '🙏 Welcome! I can help you understand your Kundli, Lagna chart, and provide spiritual guidance.',
    ];
    return responses[Random().nextInt(responses.length)];
  }

  bool _isQuestionAboutSign(String message, List<String> keywords) {
    final signs = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 
                   'libra', 'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces',
                   'mesha', 'vrishabha', 'mithuna', 'karka', 'simha', 'kanya',
                   'tula', 'vrischika', 'dhanu', 'makara', 'kumbha', 'meena'];
    return signs.any((sign) => keywords.contains(sign) || message.contains(sign));
  }

  String _getSignInterpretation(String message, List<String> keywords) {
    for (var sign in _kundliKnowledge.keys) {
      if (message.contains(sign)) {
        final interpretations = _kundliKnowledge[sign]!;
        return interpretations[Random().nextInt(interpretations.length)];
      }
    }
    return 'I can help you understand your zodiac sign. Which sign are you interested in?';
  }

  bool _isQuestionAboutLagna(String message, List<String> keywords) {
    return keywords.contains('lagna') || keywords.contains('ascendant') || 
           message.contains('lagna') || message.contains('ascendant');
  }

  String _getLagnaInterpretation(String message, List<String> keywords) {
    for (var lagna in _lagnaKnowledge.keys) {
      if (message.contains(lagna)) {
        return _lagnaKnowledge[lagna]!;
      }
    }
    return 'Lagna (Ascendant) is the rising sign at the time of your birth. It represents your outer personality and how others see you. Which Lagna are you interested in?';
  }

  bool _isQuestionAboutPlanet(String message, List<String> keywords) {
    final planets = ['sun', 'moon', 'mars', 'mercury', 'jupiter', 'venus', 
                     'saturn', 'rahu', 'ketu', 'planet', 'planets'];
    return planets.any((p) => keywords.contains(p) || message.contains(p));
  }

  String _getPlanetaryInterpretation(String message, List<String> keywords) {
    for (var planet in _planetaryKnowledge.keys) {
      if (message.contains(planet)) {
        final isStrong = message.contains('strong') || message.contains('good');
        final isWeak = message.contains('weak') || message.contains('bad');
        
        if (isStrong) {
          return _planetaryKnowledge[planet]!['strong']!;
        } else if (isWeak) {
          return _planetaryKnowledge[planet]!['weak']!;
        } else {
          return '${_planetaryKnowledge[planet]!['strong']!}\n\n${_planetaryKnowledge[planet]!['weak']!}';
        }
      }
    }
    return 'Planets in your chart influence different aspects of life. Which planet would you like to know about? (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Rahu, Ketu)';
  }

  bool _isQuestionAboutTopic(String message, List<String> keywords) {
    return _commonQueries.keys.any((topic) => 
      keywords.contains(topic) || message.contains(topic));
  }

  String _getTopicResponse(String message, List<String> keywords) {
    for (var topic in _commonQueries.keys) {
      if (message.contains(topic)) {
        final responses = _commonQueries[topic]!;
        return responses[Random().nextInt(responses.length)];
      }
    }
    return 'I can help you with love, career, health, wealth, and marriage matters. What specific area would you like guidance on?';
  }

  bool _isQuestionAboutRemedy(String message, List<String> keywords) {
    return keywords.contains('remedy') || keywords.contains('remedies') || 
           keywords.contains('upay') || message.contains('how to strengthen');
  }

  String _getRemedyResponse(String message, List<String> keywords) {
    for (var planet in _remedies.keys) {
      if (message.contains(planet)) {
        final planetRemedies = _remedies[planet]!;
        return 'Remedies for ${planet.toUpperCase()}:\n\n${planetRemedies.map((r) => '• $r').join('\n')}';
      }
    }
    return 'I can provide remedies for all planets. Which planet would you like remedies for? (Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn)';
  }

  String _getContextualResponse(
    String message,
    List<String> keywords,
    List<Map<String, String>> conversationHistory,
  ) {
    // Try to understand context from conversation history
    if (conversationHistory.isNotEmpty) {
      final lastMessage = conversationHistory.last['message']?.toLowerCase() ?? '';
      if (lastMessage.contains('sign') || lastMessage.contains('zodiac')) {
        return 'Based on our conversation, I can provide more detailed insights about your zodiac sign and its effects on your life. What specific aspect would you like to explore?';
      }
    }
    
    // Default intelligent response
    if (message.contains('?') || message.contains('what') || message.contains('how') || message.contains('why')) {
      return 'That\'s an interesting question! In Vedic Astrology, this relates to planetary positions and their influences. Could you provide more details about your specific situation or birth chart?';
    }
    
    return 'I understand you\'re seeking guidance. In Vedic Astrology, every aspect of life is influenced by planetary positions. Could you tell me more about what specific area you\'d like guidance on? (Love, Career, Health, Wealth, Marriage, or Kundli interpretation)';
  }
}

